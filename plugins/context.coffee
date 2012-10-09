# sample plugin
# echoes commands back as output

Plugin = require(__dirname + '/plugin')

class ContextPlugin extends Plugin

  name: 'context'
  context: '*'

  process: (command, next, halt) =>
    if m = command.body.match(/^cd (.*)/)
      context = m[1]
      @session.context = context # TODO check it is a valid context
      @session.socket.emit 'context', context
      halt()
    else
      next()

module.exports = ContextPlugin
