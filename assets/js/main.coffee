#= require lib/underscore
#= require lib/backbone
#= require app
#= require lib/sync
#= require lib/browserid
#= require views/nav
#= require views/input_box
#= require views/list

$ ->
  Backbone.socket = io.connect()
  app.input = new app.views.InputBox().render()
  app.input.$el.appendTo('#main .input')[0].focus()
  app.list = new app.views.List().render()
  app.list.$el.appendTo('#main .list')
