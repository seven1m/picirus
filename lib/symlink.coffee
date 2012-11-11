# abstract file/directory
_ = require('underscore')
fs = require('fs')
pathLib = require('path')
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
    pathLib.join CONFIG.path('account', @account), @snapshot, @source_path

  fullPath: =>
    if @path.match(/\.\./)
      throw 'cannot be a relative path'
    pathLib.join CONFIG.path('account', @account), @snapshot, @path

  linkPath: =>
    source_path = @sourcePath().split '/'
    full_path = @fullPath().split '/'

    for path, i in full_path
      if path != source_path[i]
        upDir = ''
        for c in [0...full_path.length - i - 1]
          upDir += '../'
        linkPath = _.rest source_path, i      
        break

    if upDir
      upDir + linkPath.join('/')
    else
      source_path

  mkdir: (cb) =>
    name = pathLib.dirname(@fullPath())
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
      link = fs.symlink @linkPath(), @fullPath()
      cb()
    fs.stat @sourcePath(), (err, stat) =>
      if stat
        rimraf @fullPath(), (err) =>
          write()
      else
        write()

module.exports = Symlink
