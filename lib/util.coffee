child_process = require('child_process')

exports.storageStats = (cb) ->
  child_process.exec "du -d 1 -b #{CONFIG.path('backup_root')}", (err, output) ->
    accounts = {}
    lines = output.trim().split(/\r?\n/)
    console.log lines
    for line, i in lines when i < lines.length-1
      parts = line.split(/\t/)
      path = parts[1].split('/')
      accounts[path[path.length-1]] = parseInt(parts[0])
    cb(err, [k.split('-')[0], v] for k, v of accounts)
