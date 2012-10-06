passport = require('passport')
LocalStrategy = require('passport-local').Strategy
BrowserIdStrategy = require('passport-browserid').Strategy

User = require(__dirname + '/models/user')

passport.use new LocalStrategy (username, password, done) ->
  User.findOne username: username, (err, user) ->
    if err or not (user and User.authenticate(user, password))
      done null, false, message: 'User not found or password incorrect.'
    else
      done null, user

passport.use new BrowserIdStrategy {audience: 'http://localhost:3000'},
  (email, done) ->
    User.findOne email: email, (err, user) ->
      if err
        done err
      else
        user ?= new User(email: email)
        user.last_login = new Date()
        user.save (err) ->
          if err and err.code == 11000 # ugly hack
            user.username = user.alternate_username
            user.save (err) ->
              done err, user
          else
            done err, user

passport.serializeUser (user, done) ->
  done null, user.id

passport.deserializeUser (id, done) ->
  User.findOne _id: id, done
