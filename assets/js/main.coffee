#= require underscore
#= require backbone
#= require app
#= require lib/sync
#= require models/command
#= require models/response
#= require collections/history
#= require collections/responses
#= require views/console

$ ->
  Backbone.socket = io.connect()
  app.console = new app.views.Console(el: $('.console'), username: app.username).render()
  app.console.focus()
