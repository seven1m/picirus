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
    if p = @paths[name]
      p = p.replace /\$(\w+)/g, (m, name) =>
        @path(name)
      p = if p.indexOf('/') == 0
        p
      else
        @root() + p
      if obj
        p = p.replace /:(\w+)/g, (m, name) ->
          obj[name]
      p
    else
      throw "cannot find path #{name} in config."

  root: ->
    __dirname + '/../'


module.exports = Config
