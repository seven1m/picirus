# abstract file/directory

Stream = require('stream').Stream
fs = require('fs')
path = require('path')
xattr = require('xattr')
mkdirp = require('mkdirp')
rimraf = require('rimraf')

class File

  constructor: (@account, @snapshot, @path, @isDir, @data, @meta) ->

  fullPath: =>
    if @path.match(/\.\./)
      throw 'cannot be a relative path'
    path.join CONFIG.path('account', @account), @snapshot, @path

  mkdir: (cb) =>
    name = if @isDir then @fullPath() else path.dirname(@fullPath())
    fs.stat name, (err, stat) =>
      if stat and stat.isFile()
        rimraf name, (err) =>
          @added = true
          mkdirp name, cb
      else
        mkdirp name, cb

  save: (cb) =>
    @data.pause() if @data instanceof Stream
    @mkdir (err) =>
      if err then cb(err)
      if @isDir
        @saveMeta(cb)
      else
        @getMeta (err, meta) =>
          if @meta && meta && @meta.rev == meta.rev
            # same file rev
            cb(null)
          else
            if meta
              @updated = true
            else
              @added = true
            @_writeFile(cb)

  _writeFile: (cb) =>
    write = =>
      file = fs.createWriteStream @fullPath()
      if @data instanceof Stream
        @data.pipe(file)
        @data.resume()
      else
        file.end(@data)
      file.on 'close', =>
        @saveMeta(cb)
    fs.stat @fullPath(), (err, stat) =>
      if stat and stat.isDirectory()
        rimraf @fullPath(), (err) =>
          write()
      else
        write()


  saveMeta: (cb) =>
    for key, val of @meta
      xattr.set @fullPath(), "user.#{key}", val
    cb(null)

  getMeta: (cb) =>
    meta = {}
    for key, val of xattr.list(@fullPath())
      meta[key.replace(/^user\./, '')] = val
    cb null, meta

  delete: (cb) =>
    rimraf @fullPath(), cb

  exists: (cb) =>
    fs.exists @fullPath(), cb

module.exports = File
