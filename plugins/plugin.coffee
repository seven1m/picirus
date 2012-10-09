# abstract plugin class
# all plugins should extend this class

class Plugin

  constructor: (@session) ->

  response: (command, body, cb) =>
    command.response body, @name, (err, response) =>
      if err then throw err
      @session.response response
      cb()

module.exports = Plugin
