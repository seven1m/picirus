class app.views.Console extends Backbone.View

  className: 'console full'

  keys:
    return: 13
    up:     38
    down:   40

  events:
    'keypress input': 'handleEvent'
    'click':          'focus'

  key_events:
    return: 'execute'
    up:     'historyPrev'
    down:   'historyNext'

  initialize: ->
    @active = @options.active
    @on(key, @[fn]) for key, fn of @key_events
    @model.on 'change', @updatePrompt
    @model.on 'change:input', (_, input) =>
      @input.val input
    @model.on 'change:active', (_, active) =>
      if active then @$el.show()
      else @$el.hide()
    @model.responses.on 'add', @addResponse

  execute: =>
    @model.execute @input.val()

  historyPrev: =>
    @model.historyPrev()

  historyNext: =>
    @model.historyNext()

  addResponse: (response) =>
    r = $('<div>', id: response.id)
    if cls = response.get('class')
      r.addClass(cls)
    # TODO append other metadata, e.g. 'nick' for irc
    r.append($('<span>', class: 'text', html: response.get('body')))
    r.appendTo(@output)

  handleEvent: (e) =>
    if e.keyCode in _(@keys).values()
      e.preventDefault()
      @trigger _.invert(@keys)[e.keyCode], e

  resize: =>
    if @$el.is '.full'
      bodyHeight = $('body').height()
      headerHeight = $('header').outerHeight(true)
      @$el.height bodyHeight - headerHeight
    @updatePrompt()

  updatePrompt: =>
    @prompt = "#{@model.get 'context'}:#{@model.get 'path'}&gt;"
    @$el.find('.prompt').html @prompt
    width = @content.width()
    promptWidth = @$el.find('.prompt').outerWidth(true)
    @input.width width - promptWidth

  focus: =>
    @input[0].focus()

  # only should be called once
  render: =>
    @$el.appendTo('#main')
    @$el.html jade.render('console')
    @input = @$el.find('input')
    @content = @$el.find('.content')
    @output = @content.find('.output')
    @resize()
    $(window).on 'resize', _.debounce(@resize, 50)
    @
