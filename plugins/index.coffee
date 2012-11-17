fs = require 'fs'

for file in fs.readdirSync(__dirname)
  if file.match(/\.coffee$/) && !file.match(/(base|index)\.coffee/)
    name = file.substr 0, file.indexOf('.')
    plugin = require('./' + name)
    exports[name] = new plugin() unless plugin.disabled
