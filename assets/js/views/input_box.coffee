class app.views.InputBox extends Backbone.View

  tagName: 'input'

  keys:
    return: 13
    up:     38
    down:   40

  events:
    'keypress': 'handleKeyEvent'
    'keyup':    'handleInput'

  key_events:
    return: 'execute'
    up:     'historyPrev'
    down:   'historyNext'

  initialize: ->
    @key_codes = _.invert(@keys)

  execute: =>
    @model.execute @$el.val()

  historyPrev: =>
    @model.historyPrev()

  historyNext: =>
    @model.historyNext()

  handleKeyEvent: (e) =>
    if event_name = @key_codes[e.keyCode]
      e.preventDefault()
      @trigger event_name, e

  handleInput: (e) =>
    app.list.render()
    if Backbone.socket
      Backbone.socket.emit 'input', @$el.val()

  updatePrompt: =>
    @prompt = "#{@model.get 'context'}:#{@model.get 'path'}&gt;"
    @$el.find('.prompt').html @prompt
    width = @content.width()
    promptWidth = @$el.find('.prompt').outerWidth(true)
    @$el.width width - promptWidth

  render: =>
    # noop
    @
