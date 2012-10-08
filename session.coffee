plugins = require(__dirname + '/plugins')

class Session

  constructor: ->
    @stack = []
    for name, plugin of plugins
      @stack.push new plugin

  process: (command, cb) =>
    @processMiddleware command, @stack.slice(0), ->
      command.save cb

  processMiddleware: (command, stack, cb) =>
    return cb() unless stack.length > 0
    middleware = stack[0]
    middleware.process command, (update) =>
      # TODO handle other types of updated attributes
      command.append update.output
      @processMiddleware command, stack.slice(1), cb

module.exports = Session
