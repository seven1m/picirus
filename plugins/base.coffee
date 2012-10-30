class BasePlugin

  constructor: (app) ->
    @setup(app)

  refreshScheduler: (req, res, next) =>
    scheduler.refresh()
    next()

  redirect: (req, res) =>
    res.redirect '/accounts'

module.exports = BasePlugin
