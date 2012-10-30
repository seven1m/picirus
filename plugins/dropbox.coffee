_ = require('underscore')
passport = require('passport')
DropboxStrategy = require('passport-dropbox').Strategy
DropboxClient = require('dropbox-node').DropboxClient
BasePlugin = require('./base')
Account = require('../models/account')

class DropboxPlugin extends BasePlugin

  setup: (app) ->
    app.get '/auth/dropbox', @config, @auth
    app.get '/auth/dropbox/callback', @auth, @refreshScheduler, @redirect

  config: (req, res, next) =>
    config =
      consumerKey: CONFIG.keys.dropbox.key
      consumerSecret: CONFIG.keys.dropbox.secret
      callbackURL: "http://#{req.headers.host}/auth/dropbox/callback"
    passport.use 'dropbox-authz', new DropboxStrategy(config, @build)
    next()

  auth: passport.authorize('dropbox-authz')

  build: (token, secret, profile, done) =>
    Account.buildFromOAuth profile, token, secret, done

  client: (account) ->
    new DropboxClient(CONFIG.keys.dropbox.key, CONFIG.keys.dropbox.secret,
                      account.token, account.secret)

  backup: (account) ->
    console.log 'backing up dropbox', new Date()
    console.log 'finished backing up dropbox', new Date()

module.exports = DropboxPlugin
