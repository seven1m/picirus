#= require underscore
#= require backbone

class Console extends Backbone.View

  keys:
    return: 13
    up:     38
    down:   40

  history: []

  events:
    'keypress input': 'handleEvent'
    'click':          'focus'

  initialize: ->
    @on 'return', @execute
    @on 'up', @historyPrev
    @on 'down', @historyNext
    @input = @$el.find('input')
    @resetHistoryPointer()
    @sizeInput()
    $(window).on('resize', @sizeInput)

  historyPrev: =>
    @historyPointer++
    @checkHistoryPointer()
    @input.val @history[@historyPointer]

  historyNext: =>
    @historyPointer--
    @checkHistoryPointer()
    @input.val @history[@historyPointer]

  execute: =>
    if val = @input.val()
      if @history.length == 0 or @history[0] != val then @history.unshift(val)
      @addMessage(val)
      @input.val('')
      @resetHistoryPointer()
      @$el.scrollTop(100000000)

  addMessage: (text) =>
    message = $('<div>', class: 'message')
    message.append $('<span>', {class: 'nick', html: 'tim'})
    message.append $('<span>', {class: 'text', html: text})
    message.insertBefore @$el.find('.command')

  resetHistoryPointer: =>
    @historyPointer = -1

  checkHistoryPointer: =>
    if(@historyPointer < 0)
      @historyPointer = @history.length - 1
    else if(@historyPointer >= @history.length)
      @historyPointer = 0

  handleEvent: (e) =>
    if e.keyCode in _(@keys).values()
      e.preventDefault()
      @trigger _.invert(@keys)[e.keyCode], e

  sizeInput: =>
    width = @$el.width()
    promptWidth = @$el.find('.prompt').width()
    @input.width width - 20 - promptWidth - 8

  focus: =>
    @input[0].focus()

$ ->
  console = new Console el: $('.chat-container')
  console.focus()
