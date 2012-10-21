mixins = require('./mixins')

mongoose = require('mongoose')

usernameRegexp = /^[a-z0-9_\-\.]{3,15}$/i
emailRegexp = /^[a-z0-9_\-\.%]+@[a-z0-9\-\.]+$/i

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
  created:
    type: Date
  updated:
    type: Date
  last_login:
    type: Date

schema.plugin mixins.timestamps

schema.pre 'save', (next) ->
  unless @username
    short = @email && @email.split('@')[0]
    short = 'user' if not (short and short.match(usernameRegexp))
    @username = short
    @alternate_username = short + Math.floor(Math.random() * 10000)
  next()

schema.statics.findOrCreate = (attrs, cb) ->
  @findOne attrs, (err, user) =>
    if err
      cb err
    else
      user ?= new this(attrs)
      user.last_login = new Date()
      user.save (err) =>
        # FIXME ugly hack
        if err and err.code == 11000 and user.alternate_username
          user.username = user.alternate_username
          user.save cb
        else
          cb err, user

module.exports = mongoose.model 'User', schema
