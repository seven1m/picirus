_ = require('underscore')
async = require('async')
CronJob = require('cron').CronJob

class Scheduler

  sched: '0 0 0 * * *'

  constructor: (@model) ->
    @cron = new CronJob @sched, @run

  run: =>
    @model.all().complete (err, accounts) =>
      if err then throw err
      async.forEachSeries(accounts, @backup)

  backup: (account) =>
    account.backup()

module.exports = Scheduler
