_ = require('underscore')
passport = require('passport')
GoogleStrategy = require('passport-google-oauth').OAuth2Strategy
BasePlugin = require('./base')
Account = require('../models/account')

class GooglePlugin extends BasePlugin

  setup: (app) ->
    config =
      clientID: CONFIG.keys.google.client_id
      clientSecret: CONFIG.keys.google.client_secret
      callbackURL: "urn:ietf:wg:oauth:2.0:oob"
    passport.use 'google-authz', new GoogleStrategy(config, @build)
    app.get '/auth/google', (req, res) ->
      res.render 'auth/google'
    app.get '/auth/google/go', @auth
    app.get '/auth/google/callback', @auth, @refreshScheduler, @redirect

  auth: passport.authorize('google-authz',
    scope: ['https://www.googleapis.com/auth/userinfo.profile',
            'https://www.googleapis.com/auth/userinfo.email']
  )

  build: (accessToken, refreshToken, profile, done) =>
    Account.buildFromOAuth2 profile, accessToken, refreshToken, done

module.exports = GooglePlugin
