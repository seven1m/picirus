_ = require('underscore')
models = require(__dirname + '/models')
plugins = require(__dirname + '/plugins')

class Session

  constructor: (@socket) ->
    @user_id = @socket.handshake.session.passport.user
    @stack = []
    for name, plugin of plugins
      @stack.push new plugin(@)
    @socket.on 'input', @process

  process: (command, cb) =>
    @processPlugin command, @stack, cb || _.identity

  processPlugin: (command, stack, cb) =>
    return cb() unless stack.length > 0
    stack[0].process command, =>
      @processPlugin command, stack.slice(1), cb

  output: (input, outputs) =>
    @socket.emit 'list', input, outputs

module.exports = Session
