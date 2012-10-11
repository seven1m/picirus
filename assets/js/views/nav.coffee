class app.views.Nav extends Backbone.View

  tagName: 'nav'
  className: 'tabs'

  events:
    'click .tab':     'switchTab'
    'click .new-tab': 'newTab'

  initialize: ->
    # @model = Session
    for ev in ['add', 'change', 'remove', 'reset']
      @model.consoles.on ev, @render

  switchTab: (e) =>
    e.preventDefault()
    cid = $(e.target).parent('li').attr('id')
    @model.showConsole cid

  newTab: (e) =>
    e.preventDefault()
    @model.newConsole()

  render: =>
    @$el.html jade.render 'nav',
      tabs: @model.consoles.models
    $('nav.tabs').html @$el.html()
    @
