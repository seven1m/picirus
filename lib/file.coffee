# abstract file/directory

_ = require('underscore')
Stream = require('stream').Stream
fs = require('fs')
path = require('path')
mkdirp = require('mkdirp')
rimraf = require('rimraf')
moment = require('moment')

class File

  constructor: (@account, @snapshot, @path, @isDir, @data, @meta) ->

  fullPath: =>
    if @path.match(/\.\./)
      throw 'cannot be a relative path'
    path.join CONFIG.path('account', @account), @snapshot, @path

  metaPath: =>
    @fullPath() + '.meta.json'

  mkdir: (cb) =>
    name = if @isDir then @fullPath() else path.dirname(@fullPath())
    fs.stat name, (err, stat) =>
      if stat and stat.isFile()
        rimraf name, (err) =>
          @added = true if @isDir
          mkdirp name, cb
      else
        @added = true if @isDir
        mkdirp name, cb

  save: (cb) =>
    cb ?= _.identity
    @data.pause() if @data instanceof Stream
    @mkdir (err) =>
      if err then cb(err)
      if @isDir
        @saveMeta(cb)
      else
        @getMeta (err, meta) =>
          if @meta?.rev? && meta?.rev? && @meta.rev == meta.rev
            # same file rev
            cb(null)
          else
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
      if stat
        @updated = true
        rimraf @fullPath(), (err) =>
          write()
      else
        @added = true
        write()


  saveMeta: (cb) =>
    cb ?= _.identity
    fs.writeFile @metaPath(), JSON.stringify(@meta), (err) =>
      if err
        cb(err)
      else
        if @meta?.updated
          fs.utimes @fullPath(), new Date(), moment(@meta.updated).toDate(), =>
            cb(null)
        else
          cb(null)

  getMeta: (cb) =>
    fs.stat @metaPath(), (err, stat) =>
      if stat
        fs.readFile @metaPath(), (err, data) =>
          if not err and data
            cb null, JSON.parse(data.toString())
          else
            cb null
      else
        cb null

  delete: (cb) =>
    rimraf @fullPath(), cb

  exists: (cb) =>
    fs.exists @fullPath(), cb

module.exports = File
