fs = require('fs')

class Config

  constructor: (path) ->
    @config = JSON.parse(fs.readFileSync(path))
    for key, val of @config
      @[key] = val

  path: (name) =>
    p = @paths[name]
    if p.indexOf('/') == 0
      p
    else
      __dirname + '/../' + p

module.exports = Config
