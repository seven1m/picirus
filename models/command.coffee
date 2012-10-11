Response = require(__dirname + '/response')
mixins = require(__dirname + '/mixins')
Stack = new require(__dirname + '/../plugins').Stack

mongoose = require('mongoose')
Schema = mongoose.Schema

schema = new Schema
  user_id:
    type: Schema.ObjectId
    required: true
  session_id:
    type: Schema.ObjectId
    required: true
  console_id:
    type: Schema.ObjectId
    required: true
  body:
    type: String
    required: true
  created:
    type: Date
  updated:
    type: Date

schema.plugin mixins.timestamps

schema.plugin mixins.sync,
  keys: ['body']
  read: true
  create: true
  afterCreate: (model, _, socket) ->
    socket.get 'session', (err, session) ->
      session.process model

schema.methods.response = (body, meta, plugin, cb) ->
  meta ?= {}
  if cls = meta.class
    delete meta.class
  else
    cls = 'normal'
  response = new Response
    user_id: @user_id
    session_id: @session_id
    command_id: @_id
    body: body
    plugin: plugin
    class: cls
    meta: meta
  response.save cb

module.exports = model = mongoose.model 'Command', schema
