_ = require('underscore')
fs = require('fs')
path = require('path')
child_process = require('child_process')
async = require('async')
rimraf = require('rimraf')
mkdirp = require('mkdirp')
moment = require('moment')

class Rotation

  format: 'YYYY-MM-DD'

  constructor: (@path) ->
    @today = moment()

  dest: =>
    @today.format(@format)

  # override this in the rotation class
  pathsToKeep: (paths) =>
    paths # noop

  # call BEFORE running a backup
  snapshot: (cb) =>
    mkdirp @path, (err) =>
      if err then return cb(err)
      @latest (err, latest) =>
        if err then return cb(err)
        if latest == @dest()
          #cb('backup already exists for this date')
          cb err, @dest()
        else if latest
          @cp_al latest, @dest(), (err) =>
            cb err, @dest()
        else
          @mkdir @dest(), (err) =>
            cb err, @dest()

  # call AFTER running a backup
  cleanup: (cb) =>
    @list (err, dirs) =>
      keep = @pathsToKeep(dirs)
      remove = _.difference(dirs, keep)
      async.forEach remove, @remove, cb

  latest: (cb) =>
    @list (err, files) =>
      if err
        cb(err)
      else if files
        files.sort()
        cb null, files[files.length-1]
      else
        cb()

  list: (cb) =>
    fs.readdir @path, cb

  cp_al: (source, dest, cb) =>
    source = path.join(@path, source)
    dest = path.join(@path, dest)
    stderr = ''
    copy = child_process.spawn('cp', ['-al', source, dest])
    copy.stderr.on 'data', (data) =>
      stderr += data.toString()
    copy.on 'exit', (code) =>
      if code == 0
        cb(null)
      else
        cb(stderr)

  mkdir: (dest, cb) =>
    fs.mkdir path.join(@path, dest), cb

  remove: (path, cb) =>
    fs.exists path, (exists) =>
      if exists
        rimraf(path, cb)
      else
        cb(null)


class GFSRotation extends Rotation

  pathsToKeep: (paths) =>
    days = for i in _.range(7)
      @today.clone().subtract('days', i).format('YYYY-MM-DD')

    weekStart = @today.clone().day(-7)
    weeks = for i in _.range(5)
      weekStart.clone().subtract('weeks', i).format('YYYY-MM-DD')

    monthStart = @today.clone().date(1)
    months = for i in _.range(12)
      monthStart.clone().subtract('months', i).format('YYYY-MM-DD')

    days.concat(weeks).concat(months)


exports.Rotation = Rotation
exports.GFSRotation = GFSRotation
