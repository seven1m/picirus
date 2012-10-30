class BasePlugin

  constructor: (app) ->
    @setup(app)

  redirect: (req, res) =>
    res.redirect '/accounts'

module.exports = BasePlugin
