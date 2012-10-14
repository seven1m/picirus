# base plugin class
# all plugins should extend this class

class BasePlugin

  constructor: (@session) ->

  output: (input, outputs) =>
    @session.output input, outputs

module.exports = BasePlugin
