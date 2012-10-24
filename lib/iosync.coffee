_ = require('underscore')
socketio = require('socket.io')
express = require('express')
models = require('../models')

module.exports = (server, app) ->
  io = socketio.listen(server)

  io.configure 'production', ->
    io.set 'log level', 1

  io.configure 'development', ->
    io.set 'log level', 2

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
    for name, model of models when model.sync
      model.sync(socket)
