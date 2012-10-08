socketio = require('socket.io')
models = require(__dirname + '/models')
Session = require(__dirname + '/session')

module.exports = (server) ->
  io = socketio.listen(server)
  io.sockets.on 'connection', (socket) ->
    # TODO load existing session, multiple sessions, etc.
    socket.set 'session', new Session
    for name, model of models when model.sync
      model.sync(socket)
