# sample plugin
# echoes commands back as output

class EchoPlugin

  name: 'echo'

  process: (command, next) =>
    next output: command.input

module.exports = EchoPlugin
