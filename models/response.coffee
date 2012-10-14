mixins = require(__dirname + '/mixins')

mongoose = require('mongoose')
Schema = mongoose.Schema

schema = new Schema
  user_id:
    type: Schema.ObjectId
    required: true
  session_id:
    type: Schema.ObjectId
    required: true
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

schema.plugin mixins.timestamps

schema.plugin mixins.sync,
  read: true

module.exports = model = mongoose.model 'Response', schema
