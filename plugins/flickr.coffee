_ = require('underscore')
passport = require('passport')
FlickrStrategy = require('passport-flickr').Strategy
BasePlugin = require('./base')
models = require('../models')

class FlickrPlugin extends BasePlugin

  routes: (app) ->
    app.get '/auth/flickr', @config, @auth
    app.get '/auth/flickr/callback', @auth, @redirect

  config: (req, res, next) =>
    config =
      consumerKey: CONFIG.keys.flickr.key
      consumerSecret: CONFIG.keys.flickr.secret
      callbackURL: "http://#{req.headers.host}/auth/flickr/callback"
    passport.use 'flickr-authz', new FlickrStrategy(config, @build)
    next()

  auth: passport.authorize('flickr-authz')

  build: (token, secret, profile, done) =>
    models.account.buildFromOAuth profile, token, secret, done

module.exports = FlickrPlugin
