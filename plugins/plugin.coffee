# abstract plugin class
# all plugins should extend this class

class Plugin

  constructor: (@session) ->

  response: (command, body, meta, cb) =>
    command.response body, meta, @name, (err, response) =>
      if err then throw err
      @session.response response
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

module.exports = Plugin
