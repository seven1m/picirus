fs = require('fs')
pathLib = require('path')
async = require('async')
mime = require('mime')
syntax = require('node-syntaxhighlighter')
ExifImage = require('exif').ExifImage

class Browser

  constructor: (@account, @snapshot, @path='/') ->
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
        async.map list, @statChild, cb
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
    fs.readdir @rootPath(), cb

  latestSnapshot: (cb) =>
    @snapshots (err, snapshots) =>
      if snapshots.length > 0
        snapshots.sort()
        cb(null, snapshots[snapshots.length-1])
      else
        cb('no backups found')

  breadcrumbs: (cb) =>
    cum = @prettyPathRoot()
    parts = @path.split('/')
    parts.unshift('') unless parts[0] == ''
    for part, i in parts
      cum += '/' + part
      {
        name: part || @account.provider
        path: cum
        active: i == parts.length - 1
      }

  mime: =>
    mime.lookup(@name)

module.exports = Browser
