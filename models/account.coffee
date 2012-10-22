DropboxClient = require('dropbox-node').DropboxClient

mixins = require('./mixins')

mongoose = require('mongoose')

schema = mongoose.Schema
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

schema.methods.acctInfo = (cb) ->
  dropbox = new DropboxClient(KEYS.dropbox.key, KEYS.dropbox.secret,
                              @token.token, @token.secret)
  console.log dropbox
  dropbox.getAccountInfo cb

module.exports = mongoose.model 'Account', schema
