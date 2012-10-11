class app.models.Session extends Backbone.Model

  namespace: 'session'
  idAttribute: '_id'

  initialize: ->
    @consoles = new app.collections.Consoles
    @consoles.fetch
      data: session_id: @get('_id')
      success: =>
        if @consoles.length == 0
          @newConsole()
    @consoles.on 'reset', =>
      @consoles.each (c) ->
        new app.views.Console(model: c).render()
    @consoles.on 'add', (c) =>
      new app.views.Console(model: c).render()

  showConsole: (cid) =>
    @consoles.each (c) ->
      c.save active: c.cid == cid

  newConsole: =>
    @consoles.each (c) -> c.save active: false
    console = @consoles.create
      context: 'wsh'
      path: '~'
      username: app.username
      active: true
