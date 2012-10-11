_ = require('underscore')
socketio = require('socket.io')
express = require('express')
models = require(__dirname + '/models')
Session = require(__dirname + '/session')

module.exports = (server, app) ->
  io = socketio.listen(server)

  # parse session cookie and save on the socket
  if app and app.secret
    cookieParser = express.cookieParser(app.secret)
    io.set 'authorization', (data, accept) ->
      if c = data.headers.cookie
        # fake a request to get the signed cookie
        req = headers: cookie: c
        cookieParser req, null, ->
          data.session = req.signedCookies['connect.sess']
          accept null, true
      else
        accept null, true

  io.sockets.on 'connection', (socket) ->
    session = new Session(socket)
    session.load ->
      for name, model of models when model.sync
        model.sync(socket)
