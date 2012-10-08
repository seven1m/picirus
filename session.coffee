EventEmitter2 = require('eventemitter2').EventEmitter2
plugins = require(__dirname + '/plugins')

class Session extends EventEmitter2

  constructor: ->
    super
      wildcard: true
      delimiter: '.'
      maxListeners: 20
    for name, plugin of plugins
      new plugin(this)

module.exports = Session
