mixins = require(__dirname + '/mixins')

mongoose = require('mongoose')
Schema = mongoose.Schema

schema = new Schema
  user_id:
    type: Schema.ObjectId
    required: true
  created:
    type: Date
  updated:
    type: Date

schema.plugin mixins.timestamps

module.exports = model = mongoose.model 'Session', schema
