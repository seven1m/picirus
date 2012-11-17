_ = require('underscore')
passport = require('passport')
GoogleStrategy = require('passport-google-oauth').OAuth2Strategy
base = require('./base')
BasePlugin = base.BasePlugin
models = require('../models')

class GooglePlugin extends BasePlugin

  routes: (app) ->
    config =
      clientID: CONFIG.keys.google.client_id
      clientSecret: CONFIG.keys.google.client_secret
      callbackURL: "urn:ietf:wg:oauth:2.0:oob"
    passport.use 'google-authz', new GoogleStrategy(config, @build)
    app.get '/auth/google', (req, res) ->
      res.render 'auth/google'
    app.get '/auth/google/go', @auth
    app.get '/auth/google/callback', @auth, @redirect

  auth: passport.authorize('google-authz',
    scope: ['https://www.googleapis.com/auth/userinfo.profile',
            'https://www.googleapis.com/auth/userinfo.email']
  )

  build: (accessToken, refreshToken, profile, done) =>
    models.account.buildFromOAuth2 profile, accessToken, refreshToken, done

module.exports = GooglePlugin

GooglePlugin.disabled = true
