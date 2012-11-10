_ = require('underscore')
fs = require('fs')
pathLib = require('path')
async = require('async')
passport = require('passport')

OAuth2Strategy = require('passport-oauth').OAuth2Strategy
base = require('./base')
BasePlugin = base.BasePlugin
PluginBackup = base.PluginBackup
File = require('../lib/file')
models = require('../models')

class AuthProxyPlugin extends BasePlugin

  routes: (app) ->
    app.get '/auth/proxy', @config, @auth
    app.get '/auth/proxy/callback', @auth, @redirect

  config: (req, res, next) =>
    config =
      authorizationURL: 'http://localhost:3000/o/oauth2/auth'
      tokenURL: 'http://localhost:3000/o/oauth2/token';
      clientID: CONFIG.keys['auth-proxy'].client_id
      clientSecret: CONFIG.keys['auth-proxy'].client_secret
      callbackURL: "http://#{req.headers.host}/auth/auth-proxy/callback"
    passport.use 'auth-proxy-authz', new OAuth2Strategy(config, @build)
    next()

  auth: passport.authorize('auth-proxy-authz')

  build: (accessToken, refreshToken, profile, done) =>
    models.account.buildFromOAuth2 profile, accessToken, refreshToken, done

module.exports = AuthProxyPlugin
