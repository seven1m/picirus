class app.collections.Consoles extends Backbone.Collection

  model: app.models.Console
  namespace: 'console'

  initialize: ->
    Backbone.socket.on 'sync.console.created', _.bind(@add, this)
