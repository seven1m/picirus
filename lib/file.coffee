# abstract file/directory

_ = require('underscore')
fs = require('fs')
path = require('path')
mkdirp = require('mkdirp')
rimraf = require('rimraf')
moment = require('moment')

Stream = require('stream').Stream
Item = require('../models/item')

class File

  constructor: (options) ->
    for key, val of options
      @[key] = val

  fullPath: =>
    if @path.match(/\.\./)
      throw 'cannot be a relative path'
    path.join CONFIG.path('account', @account), @snapshot, @path

  metaPath: =>
    @fullPath() + '.meta.json'

  mkdir: (cb) =>
    name = if @is_dir then @fullPath() else path.dirname(@fullPath())
    fs.stat name, (err, stat) =>
      if stat and stat.isFile()
        rimraf name, (err) =>
          @added = true if @is_dir
          mkdirp name, cb
      else
        @added = true if @is_dir
        mkdirp name, cb

  save: (cb) =>
    cb ?= _.identity
    @data.pause() if @data instanceof Stream
    @mkdir (err) =>
      if err then cb(err)
      if @is_dir
        @saveMeta(cb)
      else
        @getMeta (err, meta) =>
          if @meta?.rev? && meta?.rev? && @meta.rev == meta.rev
            # same file rev
            cb(null)
          else
            @findItem (err, item) =>
              item.snapshot = @snapshot
              item.backup_id = @backup.id if @backup
              item.deleted = false
              item.save()
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
        console.log "#{@path} - updated"
        if @backup
          @backup.updated_count++
        rimraf @fullPath(), (err) =>
          write()
      else
        console.log "#{@path} - created"
        if @backup
          @backup.added_count++
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
    console.log "#{@path} - removing"
    if @backup
      @backup.deleted_count++
    @findItem 'existing', (err, item) =>
      if item
        item.snapshot = @snapshot
        item.backup_id = @backup.id if @backup
        item.deleted = true
        item.save()
    rimraf @fullPath(), cb

  exists: (cb) =>
    fs.exists @fullPath(), cb

  findItem: (onlyIfExisting, cb) =>
    unless cb
      cb = onlyIfExisting
      onlyIfExisting = null
    attrs =
      account_id: @account.id
      provider: @account.provider
      uid: @account.uid
      path: @path
    if onlyIfExisting
      Item.find(where: attrs).complete(cb)
    else
      Item.findOrInitialize attrs, cb

module.exports = File
