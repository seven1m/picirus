mixins = require('./mixins')

mongoose = require('mongoose')

schema = mongoose.Schema
  user_id:
    type: mongoose.Schema.ObjectId
  provider:
    type: String
    required: true
  uid:
    type: String
    required: true
  token:
    type: Object
  created:
    type: Date
  updated:
    type: Date

schema.plugin mixins.timestamps

schema.statics.findOrInitialize = (attrs, cb) ->
  @findOne attrs, (err, account) =>
    if err
      cb err
    else
      account ?= new this(attrs)
      account.save cb

module.exports = mongoose.model 'Account', schema
