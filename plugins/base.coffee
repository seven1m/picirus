# base plugin class
# all plugins should extend this class

class BasePlugin

  constructor: (@stack) ->

  response: (command, body, meta, cb) =>
    command.response body, meta, @name, (err, response) =>
      if err then throw err
      @stack.response response
      cb() if cb

  error: (command, body, cb) =>
    @response command, body, {class: 'error'}, cb

  info: (command, body, cb) =>
    @response command, body, {class: 'info'}, cb

  message: (name) =>
    args = Array.prototype.slice.call(arguments, 1)
    msg = @[name]
    for arg in args
      msg = msg.replace('%s', arg)
    msg

module.exports = BasePlugin
