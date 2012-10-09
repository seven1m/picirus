mongoose = require('mongoose')

Schema = mongoose.Schema

schema = new Schema
  user_id:
    type: Schema.ObjectId
    #required: true
  session_id:
    type: Schema.ObjectId
    #required: true
  command_id:
    type: Schema.ObjectId
  body:
    type: String
  plugin:
    type: String
  class:
    type: String
    default: 'normal'
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

module.exports = model = mongoose.model 'Response', schema
