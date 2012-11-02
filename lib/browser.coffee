fs = require('fs')
pathLib = require('path')
async = require('async')
mime = require('mime')
syntax = require('node-syntaxhighlighter')

cmpFiles = (a, b) =>
  na = a.name.toLowerCase()
  nb = b.name.toLowerCase()
  da = a.isDirectory()
  db = b.isDirectory()
  if da and not db then -1     # directories on top
  else if db and not da then 1
  else if na < nb then -1      # lowercase alphabetically
  else if na > nb then 1
  else 0

class Browser

  constructor: (@account, @snapshot, @path='') ->
    if @snapshot
      if m = @snapshot.match(/^([^\/]+)\/(.*)$/)
        @snapshot = m[1]
        @path = m[2]
    @name = pathLib.basename(@path)

  fullPath: =>
    if @path.match(/\.\./) or @snapshot.match(/\.\./)
      throw 'cannot be a relative path'
    pathLib.join @rootPath(), @snapshot, @path

  prettyPath: =>
    pathLib.join @prettyPathRoot(), @path

  prettyPathRoot: =>
    '/accounts/' + pathLib.join(@account.provider, @account.uid, @snapshot)

  rootPath: =>
    CONFIG.path('account', @account)

  list: (cb) =>
    if @snapshot
      fs.readdir @fullPath(), (err, list) =>
        if err then return cb(err)
        async.map list, @statChild, (err, list) =>
          if list then list.sort cmpFiles
          cb(err, list)
    else
      @latestSnapshot (err, snapshot) =>
        @snapshot = snapshot
        @list cb

  stat: (callback) =>
    p = @fullPath()
    fs.stat p, (err, stat) =>
      if err then return callback(err)
      stat.url = @prettyPath()
      stat.raw_url = stat.url + '?raw=true'
      stat.fs_path = p
      stat.path = @path
      stat.mime = @mime()
      stat.lang = syntax.getLanguage(pathLib.extname(@name))
      stat.name = @name
      callback null, stat

  statChild: (name, callback) =>
    p = pathLib.join(@fullPath(), name)
    fs.stat p, (err, stat) =>
      if err then return callback(err)
      stat.url = pathLib.join(@prettyPath(), name)
      stat.raw_url = stat.url + '?raw=true'
      stat.fs_path = p
      stat.path = @path
      stat.mime = mime.lookup(name)
      stat.lang = syntax.getLanguage(pathLib.extname(name))
      stat.name = name
      callback null, stat

  snapshots: (cb) =>
    fs.readdir @rootPath(), (err, list) =>
      list.sort() if list
      cb(err, list)

  latestSnapshot: (cb) =>
    @snapshots (err, snapshots) =>
      if err then return cb(err)
      if snapshots.length > 0
        snapshots.sort()
        cb(null, snapshots[snapshots.length-1])
      else
        cb('no backups found')

  breadcrumbs: (cb) =>
    path = @prettyPathRoot()
    parts = @path.split('/')
    parts.unshift('') unless parts[0] == ''
    for part, i in parts
      path = pathLib.join(path, part)
      {
        name: part || @account.provider
        path: path
        active: i == parts.length - 1
      }

  mime: =>
    mime.lookup(@name)

module.exports = Browser
