plugins = require(__dirname + '/plugins')

class Session

  constructor: (@socket) ->
    @stack = []
    for name, plugin of plugins
      @stack.push new plugin(@)

  process: (command, cb) =>
    @processPlugin command, @stack, cb

  processPlugin: (command, stack, cb) =>
    return cb() unless stack.length > 0
    plugin = stack[0]
    plugin.process command, (update) =>
      @processPlugin command, stack.slice(1), cb

  response: (response) =>
    @socket.emit 'sync.response.created', response

module.exports = Session
