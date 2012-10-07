#= require underscore
#= require backbone
#= require app
#= require models/history
#= require views/console

$ ->
  app.console = new app.views.Console(el: $('.console')).render()
  app.console.focus()
