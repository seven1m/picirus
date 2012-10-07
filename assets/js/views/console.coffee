class app.views.Console extends Backbone.View

  username: 'guest'
  context:  'websh'
  path:     '~'

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
    @on(key, @[fn]) for key, fn of @key_events
    @history = new app.models.History

  execute: =>
    if val = @input.val()
      @history.add val
      @addMessage val
      @input.val ''
      @history.reset()
      @$el.scrollTop(100000000)

  historyPrev: =>
    @history.prev()
    @input.val @history.current()

  historyNext: =>
    @history.next()
    @input.val @history.current()

  addMessage: (text) =>
    message = $('<div>', class: 'message')
    message.append $('<span>', {class: 'nick', html: 'tim'})
    message.append $('<span>', {class: 'text', html: text})
    message.insertBefore @$el.find('.command')

  handleEvent: (e) =>
    if e.keyCode in _(@keys).values()
      e.preventDefault()
      @trigger _.invert(@keys)[e.keyCode], e

  resize: =>
    if @$el.is '.full'
      bodyHeight = $('body').height()
      headerHeight = $('header').outerHeight(true)
      @$el.height bodyHeight - headerHeight

  updatePrompt: =>
    @prompt = "#{@username}@#{@context}:#{@path}&gt;"
    @$el.find('.prompt').html @prompt
    width = @content.width()
    promptWidth = @$el.find('.prompt').outerWidth(true)
    @input.width width - promptWidth

  focus: =>
    @input[0].focus()

  render: =>
    @$el.html jade.render('console', prompt: 'guest')
    @input = @$el.find('input')
    @content = @$el.find('.content')
    @updatePrompt()
    @resize()
    $(window).on 'resize', _.debounce(@resize, 50)
    @
