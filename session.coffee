plugins = require(__dirname + '/plugins')

class Session

  constructor: ->
    @stack = []
    for name, plugin of plugins
      @stack.push new plugin

  process: (command, cb) =>
    @processPlugin command, @stack.slice(0), ->
      command.save cb

  processPlugin: (command, stack, cb) =>
    return cb() unless stack.length > 0
    plugin = stack[0]
    plugin.process command, (update) =>
      # TODO handle other types of updated attributes
      command.append update.output
      @processPlugin command, stack.slice(1), cb

module.exports = Session
