_ = require('underscore')
fs = require('fs')
pathLib = require('path')
async = require('async')
passport = require('passport')

DropboxStrategy = require('passport-dropbox').Strategy
DropboxClient = require('dropbox-node').DropboxClient
BasePlugin = require('./base')
File = require('../lib/file')
models = require('../models')

class DropboxPlugin extends BasePlugin

  routes: (app) ->
    app.get '/auth/dropbox', @config, @auth
    app.get '/auth/dropbox/callback', @auth, @redirect

  config: (req, res, next) =>
    config =
      consumerKey: CONFIG.keys.dropbox.key
      consumerSecret: CONFIG.keys.dropbox.secret
      callbackURL: "http://#{req.headers.host}/auth/dropbox/callback"
    passport.use 'dropbox-authz', new DropboxStrategy(config, @build)
    next()

  auth: passport.authorize('dropbox-authz')

  build: (token, secret, profile, done) =>
    models.account.buildFromOAuth profile, token, secret, done

  client: (account) =>
    @_clients ?= {}
    @_clients[account.id] ?=
      new DropboxClient(
        CONFIG.keys.dropbox.key, CONFIG.keys.dropbox.secret,
        account.token, account.secret
      )

  backup: (account, cb) =>
    models.backup.start account, (err, backup) =>
      @snapshot account, (err, snapshot) =>
        if err then throw err
        @_backup account, snapshot, (err, cursor) =>
          @cleanup account, (err) =>
            if err then throw err
            account.cursor = cursor
            account.save().complete (err) =>
              backup.finish(cb)

  _backup: (account, snapshot, cb) =>
    @client(account).delta account.cursor, (err, data) =>
      async.forEachSeries data.entries, _.bind(@_save, @, account, snapshot), (err) =>
        if err
          cb(err)
        else if data.has_more
          @_backup(account, snapshot, cb)
        else
          cb(null, data.cursor)

  _save: (account, snapshot, path, cb) =>
    meta = path[1]
    path = path[0]
    if meta
      stream = !meta.is_dir && @client(account).getFile(path)
      file = new File account, snapshot, meta.path, meta.is_dir, stream,
        rev: meta.rev
      file.save (err) =>
        if err
          console.log "#{path} - error - #{err}"
        else
          console.log "#{path} - saved"
        cb(err)
    else
      @_findFile account, snapshot, path, (err, actual) =>
        console.log "#{path} - removing"
        file = new File account, snapshot, actual
        file.delete(cb)

  # cannot remove file when the case is mixed (not lowercase)
  # so we have to find the file first :(
  _findFile: (account, snapshot, path, cb) =>
    full = pathLib.join CONFIG.path('account', account), snapshot, path
    name = pathLib.basename(path)
    fs.readdir pathLib.dirname(full), (err, list) =>
      if err then return cb(err)
      for file in list
        if file.toLowerCase() == name.toLowerCase()
          return cb(null, file)
      cb('not found')


module.exports = DropboxPlugin
