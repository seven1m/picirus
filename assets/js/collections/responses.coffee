class app.collections.Responses extends Backbone.Collection

  model: app.models.Response
  namespace: 'response'

  initialize: ->
    Backbone.socket.on 'sync.response.created', _.bind(@add, this)
