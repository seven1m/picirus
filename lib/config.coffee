fs = require('fs')

class Config

  constructor: (path) ->
    if 'string' == typeof path
      @config = JSON.parse(fs.readFileSync(path))
    else
      @config = path
    for key, val of @config
      @[key] = val

  path: (name, obj) =>
    p = @paths[name]
    p = if p.indexOf('/') == 0
      p
    else
      @root() + p
    if obj
      p = p.replace /:(\w+)/g, (m, name) ->
        obj[name]
    p

  root: ->
    __dirname + '/../'


module.exports = Config
