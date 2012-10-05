passport = require('passport')
LocalStrategy = require('passport-local').Strategy

passport.use new LocalStrategy (username, password, done) ->
  if username == 'tim'
    done null, id: 1, username: 'tim'
  else
    done null, false, message: 'Invalid user'
  # TODO
  #if err then return done(err)
  #if !user
    #return done(null, false, message: 'Unknown user')
  #if !user.validPassword(password)
    #return done(null, false, message: 'Invalid password')

passport.serializeUser (user, done) ->
  done null, user.id

passport.deserializeUser (id, done) ->
  done null, id: id, username: 'tim'
