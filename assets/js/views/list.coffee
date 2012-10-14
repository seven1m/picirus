class app.views.List extends Backbone.View

  tagName: 'ul'

  initialize: ->
    Backbone.socket.on 'list', @render

  render: (input, items) =>
    if items
      for item in items
        @$el.append jade.render('list_item', item: item)
    else
      @$el.html('')
    @
