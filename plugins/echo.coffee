# sample plugin
# echoes commands back as output

class EchoPlugin

  constructor: (@session) ->
    @session.on '**', (command, cb) ->
      command.output = command.input # TODO append output?
      command.save cb

module.exports = EchoPlugin
