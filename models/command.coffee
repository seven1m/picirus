mongoose = require('mongoose')

schema = mongoose.Schema
  user_id:
    type: Number
    #required: true
  session_id:
    type: Number
  input:
    type: String
    required: true
  output:
    type: String
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

schema.methods.append = (output) ->
  if @output
    @output += "\n" + output
  else
    @output = output

schema.statics.sync = (socket) ->
  socket.on 'sync.command.create', (data, cb) =>
    command = new this(data)
    command.save (err) ->
      if err then throw err # FIXME better error handling
      socket.get 'session', (err, session) ->
        session.process command, cb

module.exports = model = mongoose.model 'Command', schema
