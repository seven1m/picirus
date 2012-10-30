_ = require('underscore')
passport = require('passport')
DropboxStrategy = require('passport-dropbox').Strategy
BasePlugin = require('./base')
Account = require('../models/account')

class DropboxPlugin extends BasePlugin

  setup: (app) ->
    config =
      consumerKey: CONFIG.keys.dropbox.key
      consumerSecret: CONFIG.keys.dropbox.secret
      callbackURL: "/auth/dropbox/callback"
    passport.use 'dropbox-authz', new DropboxStrategy(config, @build)
    app.get '/auth/dropbox', @auth
    app.get '/auth/dropbox/callback', @auth, @redirect

  auth: passport.authorize('dropbox-authz')

  build: (token, secret, profile, done) =>
    Account.buildFromOAuth profile, token, secret, done

module.exports = DropboxPlugin
