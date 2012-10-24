HOST_NAME = 'localhost:3000'

_ = require('underscore')
passport = require('passport')
BrowserIdStrategy = require('passport-browserid').Strategy
DropboxStrategy = require('passport-dropbox').Strategy
FlickrStrategy = require('passport-flickr').Strategy
GoogleStrategy = require('passport-google-oauth').OAuth2Strategy

Account = require('../models/account')

module.exports = (app) ->

  app.get '/login-failure', (req, res) ->
    res.render 'login-failure'

  app.get '/auth/dropbox',
    passport.authorize('dropbox-authz', failureRedirect: '/login-failure')

  app.get '/auth/dropbox/callback',
    passport.authorize('dropbox-authz', failureRedirect: '/login-failure'),
    (req, res) -> res.redirect '/'

  passport.use 'dropbox-authz', new DropboxStrategy
      consumerKey: CONFIG.keys.dropbox.key
      consumerSecret: CONFIG.keys.dropbox.secret
      callbackURL: "http://#{HOST_NAME}/auth/dropbox/callback"
    , (token, secret, profile, done) ->
      Account.buildFromOAuth profile, token, secret, done

  app.get '/auth/flickr',
    passport.authorize('flickr-authz', failureRedirect: '/login-failure')

  app.get '/auth/flickr/callback',
    passport.authorize('flickr-authz', failureRedirect: '/login-failure'),
    (req, res) -> res.redirect '/'

  passport.use 'flickr-authz', new FlickrStrategy
      consumerKey: CONFIG.keys.flickr.key
      consumerSecret: CONFIG.keys.flickr.secret
      callbackURL: "http://#{HOST_NAME}/auth/flickr/callback"
    , (token, secret, profile, done) ->
      Account.buildFromOAuth profile, token, secret, done

  app.get '/auth/google',
    passport.authorize 'google-authz',
      failureRedirect: '/login-failure'
      scope: ['https://www.googleapis.com/auth/userinfo.profile',
              'https://www.googleapis.com/auth/userinfo.email']

  app.get '/auth/google/callback',
    passport.authorize('google-authz', failureRedirect: '/login-failure'),
    (req, res) -> res.redirect '/'

  passport.use 'google-authz', new GoogleStrategy
      clientID: CONFIG.keys.google.client_id
      clientSecret: CONFIG.keys.google.client_secret
      callbackURL: "http://#{HOST_NAME}/auth/google/callback"
    , (accessToken, refreshToken, profile, done) ->
      Account.buildFromOAuth2 profile, accessToken, refreshToken, done
