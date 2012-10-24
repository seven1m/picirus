_ = require('underscore')

module.exports = (req, res, next) ->
  res.locals.flash = _.bind(req.flash, req)
  res.locals.params = req.params
  res.locals.session = req.session
  next()
