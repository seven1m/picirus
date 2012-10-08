class app.collections.History extends Backbone.Collection

  model: app.models.Command
  namespace: 'command'

  pointer: -1

  prev: =>
    @pointer--
    @checkBounds()
    @current()

  next: =>
    @pointer++
    @checkBounds()
    @current()

  current: =>
    @at(@pointer)

  resetPointer: =>
    @pointer = -1

  checkBounds: =>
    len = @length
    if @pointer < 0
      @pointer = len - 1
    else if @pointer >= len
      @pointer = 0
