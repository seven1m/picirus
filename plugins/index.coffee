fs = require 'fs'

module.exports = (app) ->
  plugins = []
  for file in fs.readdirSync(__dirname)
    if file.match(/\.coffee$/) && !file.match(/(base|index)\.coffee/)
      name = file.substr 0, file.indexOf('.')
      plugin = require('./' + name)
      plugins.push(new plugin(app))
  plugins
