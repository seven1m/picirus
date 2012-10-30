_ = require('underscore')
passport = require('passport')
DropboxStrategy = require('passport-dropbox').Strategy
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

module.exports = DropboxPlugin
