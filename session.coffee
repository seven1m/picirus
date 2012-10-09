_ = require('underscore')
plugins = require(__dirname + '/plugins')

class Session

  constructor: (@socket) ->
    @context = 'wsh'
    @path = '~'
    @stack = []
    for name, plugin of plugins
      @stack.push new plugin(@)

  setContext: (context) =>
    @context = context
    @socket.emit 'context', context

  setPath: (path) =>
    @path = path
    @socket.emit 'path', path

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
