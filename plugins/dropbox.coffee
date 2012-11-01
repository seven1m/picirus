_ = require('underscore')
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
    console.log 'backing up dropbox', new Date()
    @_backup account, (err, cursor) =>
      console.log 'cursor end:', cursor
      account.cursor = cursor
      account.save().complete (err) =>
        console.log 'finished backing up dropbox', new Date()
        if cb then cb(err)

  _backup: (account, cb) =>
    console.log 'cursor start:', account.cursor
    @client(account).delta account.cursor, (err, data) =>
      async.forEachSeries data.entries, _.bind(@_save, @, account), (err) =>
        if err
          cb(err)
        else if data.has_more
          @_backup(account, cb)
        else
          cb(null, data.cursor)

  _save: (account, path, cb) =>
    meta = path[1]
    path = path[0]
    if meta
      stream = !meta.is_dir && @client(account).getFile(path)
      file = new File account, meta.path, meta.is_dir, stream,
        rev: meta.rev
      save = =>
        console.log "#{path} - saving..."
        file.save (err) =>
          if err
            console.log "#{path} - error"
          else
            console.log "#{path} - finished"
          cb()
      file.exists (ex) =>
        if ex
          file.getMeta (err, attrs) =>
            if attrs.rev and attrs.rev != meta.rev
              # TODO save old rev of file
              save()
            else
              console.log "#{path} - already exists, same rev, skipping..."
              cb()
        else
          save()
    else
      # TODO remove file/directory
      cb()

module.exports = DropboxPlugin
