_ = require('underscore')
moment = require('moment')

alertIconClass = (cls) ->
  switch cls
    when 'info'
      'icon-info-sign'
    when 'success'
      'icon-ok'
    when 'error'
      'icon-exclamation-sign'

fileClass = (file) ->
  if file.isDirectory()
    'icon-folder-close'
  else if file.mime and file.mime.match(/^image\//)
    'icon-picture'
  else
    'icon-file'

timestamp = (time) ->
  if time and time.getFullYear() > 1969
    moment(time).format('YYYY-MM-DD hh:mm:ss a')

prettySize = (bytes) ->
  kbytes = bytes / 1024
  mbytes = kbytes / 1024
  gbytes = mbytes / 1024
  if gbytes >= 1.0
    "#{Math.round(gbytes * 10) / 10} GiB"
  else if mbytes > 1.0
    "#{Math.round(mbytes * 10) / 10} MiB"
  else if kbytes > 1.0
    "#{Math.round(kbytes * 10) / 10} KiB"
  else
    "#{bytes} B"

module.exports = (req, res, next) ->
  res.locals.flash = (key) ->
    if (vals = req.flash(key)).length > 0
      vals
  res.locals.params = req.params
  res.locals.session = req.session
  res.locals.path = req.path.split('/')[1]
  res.locals.alertIconClass = alertIconClass
  res.locals.fileClass = fileClass
  res.locals.timestamp = timestamp
  res.locals.prettySize = prettySize
  next()
