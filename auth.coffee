HOST_NAME = 'localhost:3000'

GLOBAL.KEYS =
  dropbox:
    key: 'nhh9leo0oxyinb4'
    secret: 'a1tfo119j6kstkz'
  flickr:
    key: '54d93fd1c781a9a01a0c8fb6ec5bbf90'
    secret: 'e6939da141b95d41'
  google:
    client_id: '618644053859.apps.googleusercontent.com'
    client_secret: '23qIXSvZOGua_3tcQNijkEWm'

_ = require('underscore')
passport = require('passport')
BrowserIdStrategy = require('passport-browserid').Strategy
DropboxStrategy = require('passport-dropbox').Strategy
FlickrStrategy = require('passport-flickr').Strategy
GoogleStrategy = require('passport-google-oauth').OAuth2Strategy

Account = require('./models/account')

module.exports = (app) ->

  app.get '/login-failure', (req, res) ->
    res.render 'login-failure'

  app.get '/auth/dropbox',
    passport.authorize('dropbox-authz', failureRedirect: '/login-failure')

  app.get '/auth/dropbox/callback',
    passport.authorize('dropbox-authz', failureRedirect: '/login-failure'),
    (req, res) -> res.redirect '/'

  passport.use 'dropbox-authz', new DropboxStrategy
      consumerKey: KEYS.dropbox.key
      consumerSecret: KEYS.dropbox.secret
      callbackURL: "http://#{HOST_NAME}/auth/dropbox/callback"
    , (token, secret, profile, done) ->
      Account.findOrInitialize provider: profile.provider, uid: profile.id, (err, account) ->
        account.token =
          kind: 'oauth'
          token: token
          secret: secret
        account.save done

  app.get '/auth/flickr',
    passport.authorize('flickr-authz', failureRedirect: '/login-failure')

  app.get '/auth/flickr/callback',
    passport.authorize('flickr-authz', failureRedirect: '/login-failure'),
    (req, res) -> res.redirect '/'

  passport.use 'flickr-authz', new FlickrStrategy
      consumerKey: KEYS.flickr.key
      consumerSecret: KEYS.flickr.secret
      callbackURL: "http://#{HOST_NAME}/auth/flickr/callback"
    , (token, secret, profile, done) ->
      Account.findOrInitialize provider: profile.provider, uid: profile.id, (err, account) ->
        account.token =
          kind: 'oauth'
          token: token
          secret: secret
        account.save done

  app.get '/auth/google',
    passport.authorize 'google-authz',
      failureRedirect: '/login-failure'
      scope: ['https://www.googleapis.com/auth/userinfo.profile',
              'https://www.googleapis.com/auth/userinfo.email']

  app.get '/auth/google/callback',
    passport.authorize('google-authz', failureRedirect: '/login-failure'),
    (req, res) -> res.redirect '/'

  passport.use 'google-authz', new GoogleStrategy
      clientID: KEYS.google.client_id
      clientSecret: KEYS.google.client_secret
      callbackURL: "http://#{HOST_NAME}/auth/google/callback"
    , (accessToken, refreshToken, profile, done) ->
      Account.findOrInitialize provider: profile.provider, uid: profile.id, (err, account) ->
        account.token =
          kind: 'oauth2'
          access_token: accessToken
          refresh_token: refreshToken
        account.save done
