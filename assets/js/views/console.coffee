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
    @username = @options.username if @options.username
    @on(key, @[fn]) for key, fn of @key_events
    @history = new app.collections.History
    @history.on 'change', (command) =>
      $('#' + command.cid).find('.text').html command.get('output')

  execute: =>
    if val = @input.val()
      command = @history.create input: val
      @addOutput command
      @input.val ''
      @updatePrompt()
      @history.resetPointer()
      @$el.scrollTop(100000000)

  historyPrev: =>
    @input.val @history.prev()?.get('input')

  historyNext: =>
    @input.val @history.next()?.get('input')

  addOutput: (command) =>
    $('<div>', id: command.cid)
      .append($('<span>', class: 'text', html: command.get('output')))
      .appendTo(@output)

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

  setUsername: (username) =>
    @username = username
    @updatePrompt()

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
    @output = @content.find('.output')
    @resize()
    $(window).on 'resize', _.debounce(@resize, 50)
    @
