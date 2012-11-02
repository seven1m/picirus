_ = require('underscore')
fs = require('fs')
pathLib = require('path')
async = require('async')
passport = require('passport')

DropboxStrategy = require('passport-dropbox').Strategy
DropboxClient = require('dropbox-node').DropboxClient
base = require('./base')
BasePlugin = base.BasePlugin
PluginBackup = base.PluginBackup
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

  backup: (account, cb) =>
    new DropboxBackup(account).run(cb)


class DropboxBackup extends PluginBackup

  constructor: (@account) ->
    super(@account)
    @client = new DropboxClient(
      CONFIG.keys.dropbox.key, CONFIG.keys.dropbox.secret,
      @account.token, @account.secret
    )

  backup: (cb) =>
    @client.delta @account.cursor, (err, data) =>
      async.forEachSeries data.entries, @save, (err) =>
        if err
          cb(err)
        else if data.has_more
          @backup(cb)
        else
          @account.cursor = data.cursor
          @account.save().complete(cb)

  save: (path, cb) =>
    meta = path[1]
    path = path[0]
    if meta
      stream = !meta.is_dir && @client.getFile(path)
      file = new File @account, @snapshot, meta.path, meta.is_dir, stream,
        rev: meta.rev
      file.save (err) =>
        if err
          console.log "#{path} - error - #{err}"
        else
          console.log "#{path} - saved"
          @incCount('added') if file.added
          @incCount('updated') if file.updated
        cb(err)
    else
      @findFile path, (err, actual) =>
        console.log "#{path} - removing"
        file = new File @account, @snapshot, actual
        @rotation.remove file.fullPath(), (err) =>
          @incCount('deleted') unless err
          cb(err)

  # cannot remove file when the case is mixed (not lowercase)
  # so we have to find the file first :(
  findFile: (path, cb) =>
    full = pathLib.join CONFIG.path('account', @account), @snapshot, path
    name = pathLib.basename(path)
    fs.readdir pathLib.dirname(full), (err, list) =>
      if err then return cb(err)
      for file in list
        if file.toLowerCase() == name.toLowerCase()
          return cb(null, file)
      cb('not found')


module.exports = DropboxPlugin
