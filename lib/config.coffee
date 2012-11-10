fs = require('fs')

class Config

  constructor: (path) ->
    if 'string' == typeof path
      @config = JSON.parse(fs.readFileSync(path))
    else
      @config = path
    for key, val of @config
      @[key] = val

  option: (provider, name, obj) =>
    if @options[provider] && p = @options[provider][name]
      if obj
        p = p.replace /\{:(\w+)\}/g, (m, name) =>          
          obj[name]
      else
        @options[provider][name]
      p
    else
      throw "cannot find option for #{provider} #{name} in config."

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
