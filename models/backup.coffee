require('../db')
Sequelize = require('sequelize')

schema =
  account_id:
    type: Sequelize.INTEGER
    validate:
      notNull: true
      notEmpty: true
  started:
    type: Sequelize.DATE
  finished:
    type: Sequelize.DATE
  added_count:
    type: Sequelize.INTEGER
  updated_count:
    type: Sequelize.INTEGER
  deleted_count:
    type: Sequelize.INTEGER


Backup = module.exports = sequelize.define 'backup', schema,
  underscored: true

  classMethods:
    start: (account, cb) ->
      date = new Date()
      console.log "backing up #{account.provider} #{account.uid}", date
      backup = @build
        account_id: account.id
        started: new Date()
      cb(null, backup)

  instanceMethods:
    finish: (cb) ->
      date = new Date()
      console.log "finished backing up #{@provider} #{@uid}", date
      @finished = date
      res = @save()
      res.complete(cb) if cb
