class app.models.History extends Backbone.Model

  commands: []
  pointer: -1

  initialize: ->
    @reset()

  prev: =>
    @pointer++
    @checkBounds()

  next: =>
    @pointer--
    @checkBounds()

  current: =>
    @commands[@pointer]

  add: (command) =>
    if @commands.length == 0 or @commands[0] != command
      @commands.unshift command

  reset: =>
    @pointer = -1

  checkBounds: =>
    if @pointer < 0
      @pointer = @commands.length - 1
    else if(@pointer >= @commands.length)
      @pointer = 0

