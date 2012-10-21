HOST_NAME = 'localhost:3000'
DROPBOX_APP_KEY = 'nhh9leo0oxyinb4'
DROPBOX_APP_SECRET = 'a1tfo119j6kstkz'

_ = require('underscore')
passport = require('passport')
BrowserIdStrategy = require('passport-browserid').Strategy
DropboxStrategy = require('passport-dropbox').Strategy

User = require('./models/user')
Account = require('./models/account')

module.exports = (app) ->

  app.get '/login-failure', (req, res) ->
    res.render 'login-failure'

  app.post '/auth/browserid',
    passport.authenticate('browserid', failureRedirect: '/login-failure'),
    (req, res) ->
      req.session.username = req.user.username
      res.json
        status: 'success'
        username: req.session.username

  passport.use new BrowserIdStrategy {audience: "http://127.0.0.1:3000"},
    (email, done) ->
      User.findOrCreate email: email, done

  app.get '/auth/dropbox',
    passport.authorize('dropbox-authz', failureRedirect: '/login-failure')

  app.get '/auth/dropbox/callback', 
    passport.authorize('dropbox-authz', failureRedirect: '/login-failure'),
    (req, res) ->
      req.account.user_id = req.user._id
      req.account.save (err) ->
        res.redirect '/'

  passport.use 'dropbox-authz', new DropboxStrategy
      consumerKey: DROPBOX_APP_KEY,
      consumerSecret: DROPBOX_APP_SECRET,
      callbackURL: "http://#{HOST_NAME}/auth/dropbox/callback"
    , (token, secret, profile, done) ->
      Account.findOrInitialize provider: profile.provider, uid: profile.id, (err, account) ->
        account.token =
          kind: 'oauth'
          token: token
          secret: secret
        done(null, account)

  passport.serializeUser (user, done) ->
    done null, user.id

  passport.deserializeUser (id, done) ->
    User.findOne _id: id, done
