_ = require('underscore')
models = require('../models')
rotations = require('../lib/rotations')
File = require('../lib/file')

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
        if err
          backup.fail(err, cb)
        else
          @snapshot = snapshot
          @backup (err) =>
            if err
              backup.fail(err, cb)
            else
              @rotation.cleanup (err) =>
                if err
                  backup.fail(err, cb)
                else
                  backup.finish(cb)

  newFile: (options) =>
    new File _.defaults options,
      account: @account
      backup: @_backup
      snapshot: @snapshot
