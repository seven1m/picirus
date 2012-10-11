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
  position:
    type: Number
  name:
    type: String
  context:
    type: String
    default: 'wsh'
  path:
    type: String
    default: '~'
  active:
    type: Boolean
    default: false
  created:
    type: Date
  updated:
    type: Date

schema.plugin mixins.timestamps

schema.plugin mixins.sync,
  keys: ['position', 'name', 'context', 'path', 'active']
  read: true
  create: true
  update: true
  delete: true

module.exports = model = mongoose.model 'Console', schema
