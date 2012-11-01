rimraf = require('rimraf')
rotations = require('../lib/rotations')

class BasePlugin

  redirect: (req, res) =>
    res.redirect '/accounts'

  remove: (path, cb) =>
    @rotation(account).remove path, cb

  snapshot: (account, cb) =>
    @rotation(account).snapshot cb

  cleanup: (account, cb) =>
    @rotation(account).cleanup cb

  rotation: (account) =>
    path = CONFIG.path('account', account)
    new rotations.GFSRotation(path)

module.exports = BasePlugin
