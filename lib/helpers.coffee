_ = require('underscore')

module.exports = (req, res, next) ->
  res.locals.flash = (key) ->
    if (vals = req.flash(key)).length > 0
      vals
  res.locals.params = req.params
  res.locals.session = req.session
  res.locals.path = req.path.split('/')[1]
  next()
