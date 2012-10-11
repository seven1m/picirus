# sample plugin
# echoes commands back as output

BasePlugin = require(__dirname + '/base')

class EchoPlugin extends BasePlugin

  name: 'echo'
  context: 'echo'

  process: (command, next) =>
    @response command, command.body
    next()

module.exports = EchoPlugin
