# sample plugin
# echoes commands back as output

Plugin = require(__dirname + '/plugin')

class EchoPlugin extends Plugin

  name: 'echo'

  process: (command, next) =>
    @response command, command.body
    next() # don't wait until response is written to continue

module.exports = EchoPlugin
