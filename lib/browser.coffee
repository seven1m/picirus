fs = require('fs')
pathLib = require('path')
async = require('async')
mime = require('mime')
syntax = require('node-syntaxhighlighter')

File = require('./file')

cmpFilesName = (a, b) =>
  na = a.name.toLowerCase()
  nb = b.name.toLowerCase()
  da = a.isDirectory()
  db = b.isDirectory()
  if da and not db then -1     # directories on top
  else if db and not da then 1
  else if na < nb then -1      # lowercase alphabetically
  else if na > nb then 1
  else 0

cmpFilesModified = (a, b) =>
  ma = a.mtime
  mb = b.mtime
  da = a.isDirectory()
  db = b.isDirectory()
  if da and not db then -1     # directories on top
  else if db and not da then 1
  else if ma < mb then -1      # modified time
  else if ma > mb then 1
  else 0

cmpFilesSize = (a, b) =>
  sa = a.size
  sb = b.size
  da = a.isDirectory()
  db = b.isDirectory()
  if da and not db then -1     # directories on top
  else if db and not da then 1
  else if sa < sb then -1      # file size
  else if sa > sb then 1
  else 0

META_PATTERN = /\.meta\.json$/
EXTENDED_VIEWS =
  facebook: ['plugins/facebook/comments']

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

  list: (sort, cb) =>
    if @snapshot
      fs.readdir @fullPath(), (err, list) =>
        if err then return cb(err)
        list = (i for i in list when not i.match(META_PATTERN))
        async.map list, @statChild, (err, list) =>
          if list
            if sort == 'name'
              list.sort cmpFilesName
            else if sort == 'modified'
              list.sort cmpFilesModified
            else if sort == 'size'
              list.sort cmpFilesSize
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

  meta: (cb) =>
    file = new File(@account, @snapshot, @path, false)
    file.getMeta(cb)

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

  extendedViews: =>
    EXTENDED_VIEWS[@account.provider]

module.exports = Browser
