# abstract file/directory
fs = require('fs')
path = require('path')
xattr = require('xattr')
mkdirp = require('mkdirp')
util = require('util')
rimraf = require('rimraf')

File = require('./file')

class Symlink extends File

  constructor: (@account, @snapshot, @source_path, @path) ->

  sourcePath: =>
    if @source_path.match(/\.\./)
      throw 'cannot be a relative path'
    path.join CONFIG.path('account', @account), @snapshot, @source_path

  fullPath: =>
    if @path.match(/\.\./)
      throw 'cannot be a relative path'
    path.join CONFIG.path('account', @account), @snapshot, @path

  mkdir: (cb) =>
    name = path.dirname(@fullPath())
    fs.stat name, (err, stat) =>
      if stat and stat.isFile()
        rimraf name, (err) =>
          mkdirp name, cb
      else
        mkdirp name, cb

  save: (cb) =>
    @mkdir (err) =>
      if err then cb(err)
      @_writeFile(cb)

  _writeFile: (cb) =>
    write = =>
      link = fs.symlink @sourcePath(), @fullPath()
      cb()
    fs.stat @sourcePath(), (err, stat) =>
      if stat
        rimraf @fullPath(), (err) =>
          write()
      else
        write()

module.exports = Symlink
