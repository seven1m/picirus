# irc plugin
# connect to irc server, join room, talk

irc = require('irc')
BasePlugin = require(__dirname + '/base')

class IrcPlugin extends BasePlugin

  name: 'irc'
  context: 'irc'

  error_missing_command: 'command not recognized; use "say" to speak here'
  error_invalid_room: 'room must start with # or ##'
  info_connected_to: 'connected to %s'
  info_joined: 'joined %s'

  commands: ['connect', 'join', 'say']

  process: (command, next) =>
    @session.irc ?= {}
    if m = command.body.match(/^(\w+)\s?(.*)/)
      if m[1] in @commands
        @[m[1]] m[2].trim(), command
      else
        @error command, @error_missing_command
    next()

  connect: (server, command) =>
    @session.irc.server = server
    @session.irc.room = null
    @setPath()
    @info command, @message('info_connected_to', server)

  join: (room, command) =>
    if room.match(/^#/)
      @session.irc.room = room
      @setPath()
      @info command, @message('info_joined', room)
    else
      @error command, @error_invalid_room

  say: (message, command) =>
    @response command, message

  setPath: =>
    path = @session.irc.server
    if r = @session.irc.room
      path += r
    @session.setPath path

module.exports = IrcPlugin
