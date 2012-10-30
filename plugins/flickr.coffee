_ = require('underscore')
passport = require('passport')
FlickrStrategy = require('passport-flickr').Strategy
BasePlugin = require('./base')
Account = require('../models/account')

class FlickrPlugin extends BasePlugin

  setup: (app) ->
    config =
      consumerKey: CONFIG.keys.flickr.key
      consumerSecret: CONFIG.keys.flickr.secret
      callbackURL: "/auth/flickr/callback"
    passport.use 'flickr-authz', new FlickrStrategy(config, @build)
    app.get '/auth/flickr', @auth
    app.get '/auth/flickr/callback', @auth, @redirect

  auth: passport.authorize('flickr-authz')

  build: (token, secret, profile, done) =>
    Account.buildFromOAuth profile, token, secret, done

module.exports = FlickrPlugin
