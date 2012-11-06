require('../db')
Sequelize = require('sequelize')
Account = require('./account')

schema =
  account_id:
    type: Sequelize.INTEGER
    validate:
      notNull: true
      notEmpty: true
  provider:
    type: Sequelize.STRING
    validate:
      notNull: true
      notEmpty: true
  uid:
    type: Sequelize.STRING
    validate:
      notNull: true
      notEmpty: true
  started:
    type: Sequelize.DATE
  finished:
    type: Sequelize.DATE
  status:
    type: Sequelize.STRING
  error:
    type: Sequelize.STRING
  added_count:
    type: Sequelize.INTEGER
    defaultValue: 0
  updated_count:
    type: Sequelize.INTEGER
    defaultValue: 0
  deleted_count:
    type: Sequelize.INTEGER
    defaultValue: 0


Backup = module.exports = sequelize.define 'backup', schema,
  underscored: true

  classMethods:
    start: (account, cb) ->
      date = new Date()
      console.log "backing up #{account.provider} #{account.uid}", date
      backup = @build
        account_id: account.id
        provider: account.provider
        uid: account.uid
        started: date
        status: 'busy'
      account.status = 'busy'
      account.error = ''
      account.save().complete (err) =>
        cb(null, backup)

  instanceMethods:
    fail: (err, cb) ->
      Account.find(@account_id).complete (err, account) =>
        date = new Date()
        console.log "error backing up #{@provider} #{@uid} - #{err}", date
        account.status = 'idle'
        account.error = err
        account.save()
        @finished = date
        @status = 'error'
        @error = err
        res = @save()
        if cb
          res.complete =>
            cb(err)

    finish: (cb) ->
      Account.find(@account_id).complete (err, account) =>
        date = new Date()
        console.log "finished backing up #{@provider} #{@uid}", date
        account.status = 'idle'
        account.error = ''
        account.last_backup = date
        account.save()
        @finished = date
        @status = 'success'
        res = @save()
        res.complete(cb) if cb
