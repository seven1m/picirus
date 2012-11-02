models = require('../models')
rotations = require('../lib/rotations')

class exports.BasePlugin

  redirect: (req, res) =>
    res.redirect '/accounts'


class exports.PluginBackup

  constructor: (@account) ->
    @path = CONFIG.path('account', @account)
    @rotation = new rotations.GFSRotation(@path)

  run: (cb) =>
    models.backup.start @account, (err, backup) =>
      @_backup = backup
      @rotation.snapshot (err, snapshot) =>
        if err then throw err
        @snapshot = snapshot
        @backup (err) =>
          if err then throw err
          @rotation.cleanup (err) =>
            if err then throw err
            backup.finish(cb)

  incCount: (which) =>
    @_backup["#{which}_count"]++
