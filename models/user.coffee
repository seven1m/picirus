mongoose = require('mongoose')
bcrypt = require('bcrypt')

usernameRegexp = /^[a-z0-9_\-\.]{3,15}$/i
emailRegexp = /^[a-z0-9\-\_\.%]+@[a-z0-9\-\.]+$/i

schema = mongoose.Schema
  username:
    type: String
    index: true
    match: usernameRegexp
    index: unique: true
  nickname:
    type: String
  email:
    type: String
    index: true
    required: true
    match: emailRegexp
    index: unique: true
  hashed_password:
    type: String
  created:
    type: Date
  updated:
    type: Date
  last_login:
    type: Date

schema.pre 'save', (next) ->
  if !@created
    @created = @updated = new Date()
  else
    @updated = new Date()
  next()

schema.pre 'save', (next) ->
  unless @username
    short = @email && @email.split('@')[0]
    short = 'user' if not (short and short.match(usernameRegexp))
    @username = short
    @alternate_username = short + Math.floor(Math.random() * 10000)
  next()

schema.post 'save', ->
  console.log arguments

schema.methods.comparePassword = (password, cb) ->
  bcrypt.compare password, @hashed_password, cb

schema.methods.setPassword = (password, cb) ->
  bcrypt.hash password, 8, (err, hash) =>
    @hashed_password = hash
    cb(err, hash)

module.exports = mongoose.model 'User', schema
