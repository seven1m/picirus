#= require lib/underscore
#= require lib/backbone
#= require app
#= require lib/sync
#= require lib/browserid
#= require models/console
#= require models/command
#= require models/response
#= require models/session
#= require collections/consoles
#= require collections/history
#= require collections/responses
#= require views/console
#= require views/nav

$ ->
  Backbone.socket = io.connect()
  Backbone.socket.on 'sync.session.created', (data) ->
    app.session = new app.models.Session(data)

    app.nav = new app.views.Nav(model: app.session)
      .render()
      .$el.prependTo('header')
