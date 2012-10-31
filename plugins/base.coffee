class BasePlugin

  redirect: (req, res) =>
    res.redirect '/accounts'

module.exports = BasePlugin
