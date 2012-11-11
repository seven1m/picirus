require('../db')
Sequelize = require('sequelize')
Account = require('./account')

moment = require('moment')

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

    stats: (cb) ->
      days = 10
      start = moment().subtract('days', days)
      dates = for i in [0..days]
        start.clone().add('days', i).format('YYYY-MM-DD')
      sequelize.query(
        "select sum(added_count) as added,
                sum(updated_count) as updated,
                sum(deleted_count) as deleted,
                strftime('%Y-%m-%d', finished) as date
           from backups
       group by strftime('%Y-%m-%d', finished)
         having strftime('%Y-%m-%d', finished) >= '#{start.format('YYYY-MM-DD')}'
       order by strftime('%Y-%m-%d', finished) desc;", null, raw: true
      ).complete (err, stats) ->
        by_date = {}
        series = {}
        for stat in stats
          by_date[stat.date] = stat
          delete stat.date
          for key, val of stat
            series[key] =
              name: key
              data: []
              color: {added: 'green', updated: 'orange', deleted: 'red'}[key]
        for date in dates
          stat = by_date[date]
          for key of series
            series[key].data.push(stat && stat[key] || 0)
        cb err,
          categories: (d.split('-')[2] for d in dates)
          series: (v for k, v of series)


  instanceMethods:
    fail: (err, cb) ->
      date = new Date()
      console.log "error backing up #{@provider} #{@uid}", err, date
      Account.find(@account_id).complete (err, account) =>
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
