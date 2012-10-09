# sample plugin
# echoes commands back as output

Plugin = require(__dirname + '/plugin')

class ContextPlugin extends Plugin

  name: 'context'
  context: '*'

  process: (command, next, halt) =>
    if m = command.body.match(/^(context|cx) (.*)/)
      @session.setContext m[2] # TODO check it is a valid context
      halt()
    else
      next()

module.exports = ContextPlugin
