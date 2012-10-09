Response = require(__dirname + '/response')

mongoose = require('mongoose')

Schema = mongoose.Schema

schema = new Schema
  user_id:
    type: Schema.ObjectId
    #required: true
  session_id:
    type: Schema.ObjectId
    #required: true
  body:
    type: String
    required: true
  created:
    type: Date
  updated:
    type: Date

schema.pre 'save', (next) ->
  if !@created
    @created = @updated = new Date()
  else
    @updated = new Date()
  next()

schema.methods.response = (body, plugin, cb) ->
  response = new Response
    user_id: @user_id
    session_id: @session_id
    command_id: @_id
    body: body
    plugin: plugin
  response.save cb

schema.statics.sync = (socket) ->
  socket.on 'sync.command.create', (data, cb) =>
    command = new this(data)
    command.save (err) ->
      if err then throw err # FIXME better error handling
      socket.get 'session', (err, session) ->
        session.process command, ->
          cb null, command

module.exports = model = mongoose.model 'Command', schema
