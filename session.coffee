_ = require('underscore')
models = require(__dirname + '/models')
plugins = require(__dirname + '/plugins')

class Session

  constructor: (@socket) ->
    @stack = []
    for name, plugin of plugins
      @stack.push new plugin(@)

  load: (cb) =>
    # FIXME this breaks when not logged in
    user_id = @socket.handshake.session.passport.user
    models.session.findOne(user_id: user_id).sort('-updated').exec (err, sess) =>
      if err then throw err
      @sess = sess || new models.session(user_id: user_id)
      @sess.save (err) =>
        if err then throw err
        @socket.set 'session', this, =>
          @socket.emit 'sync.session.created', @sess.toJSON()
        cb()

  process: (command, cb) =>
    @processPlugin command, @stack, cb

  processPlugin: (command, stack, cb) =>
    return cb() unless stack.length > 0
    plugin = stack[0]
    if plugin.context == '*' or plugin.context == @context
      plugin.process command, _.bind(@next, this, command, stack, cb), cb
    else
      @next command, stack, cb

  next: (command, stack, cb) =>
    @processPlugin command, stack.slice(1), cb

  response: (response) =>
    @socket.emit 'sync.response.created', response

module.exports = Session
