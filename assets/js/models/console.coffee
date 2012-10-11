class app.models.Console extends Backbone.Model

  namespace: 'console'
  idAttribute: '_id'

  initialize: ->
    @history = new app.collections.History
    @responses = new app.collections.Responses
    Backbone.socket.on 'context', _.bind(@set, @, 'context')
    Backbone.socket.on 'path', _.bind(@set, @, 'path')

  execute: (cmd) =>
    @history.create body: cmd
    @history.resetPointer()
    @set 'input', ''

  historyPrev: =>
    @set 'input', @history.prev()?.get('body')

  historyNext: =>
    @set 'input', @history.next()?.get('body')
