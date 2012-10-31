_ = require('underscore')

alertIconClass = (cls) ->
  switch cls
    when 'info'
      'icon-info-sign'
    when 'success'
      'icon-ok'
    when 'error'
      'icon-exclamation-sign'

module.exports = (req, res, next) ->
  res.locals.flash = (key) ->
    if (vals = req.flash(key)).length > 0
      vals
  res.locals.params = req.params
  res.locals.session = req.session
  res.locals.path = req.path.split('/')[1]
  res.locals.alertIconClass = alertIconClass
  next()
