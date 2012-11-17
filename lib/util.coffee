child_process = require('child_process')

exports.storageStats = (cb) ->
  child_process.exec "du -d 1 -b #{CONFIG.path('backup_root')}", (err, du) ->
    child_process.exec "df #{CONFIG.path('backup_root')} | tail -1 | awk '{ print $4 }'", (err, df) ->
      accounts = {}
      lines = du.trim().split(/\r?\n/)
      for line, i in lines when i < lines.length-1
        parts = line.split(/\t/)
        path = parts[1].split('/')
        accounts[path[path.length-1]] = parseInt(parts[0])
      accounts['free'] = parseInt(df)
      cb(err, [k.split('-')[0], v] for k, v of accounts)
