# sample plugin
# echoes commands back as output

BasePlugin = require('./base')

class EchoPlugin extends BasePlugin

  name: 'echo'

  process: (input, next) =>
    if input
      @output input, [
        label: input
      ]
    next()

module.exports = EchoPlugin
