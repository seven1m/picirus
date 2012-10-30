_ = require('underscore')
CronJob = require('cron').CronJob

class Scheduler

  schedules:
    daily:    '0 0 0 * * *'
    hourly:   '0 0 * * * *'
    minutely: '0 * * * * *'

  constructor: (@model, @plugins) ->
    @crons = []
    @refresh()

  refresh: =>
    cron.stop() for cron in @crons
    @model.all().complete (err, accounts) =>
      if err then throw err
      @accounts = accounts
      for account in accounts
        @schedule account

  schedule: (account) =>
    sched = @schedules[account.schedule || 'daily'] || @schedules['daily']
    if (plugin = @plugins[account.provider]) and plugin.backup?
      @crons.push new CronJob sched, ->
        plugin.backup(account)
      plugin.backup(account) # testing
    else
      console.log "account #{account.id}: provider type '#{account.provider}' not supported for backup"

module.exports = Scheduler
