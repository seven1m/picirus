# sample plugin
# echoes commands back as output

BasePlugin = require(__dirname + '/base')

class EchoPlugin extends BasePlugin

  name: 'echo'

  process: (input, next) =>
    @output input, [input]
    next()

module.exports = EchoPlugin
