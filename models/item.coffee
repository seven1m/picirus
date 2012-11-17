require('../db')
pathLib = require('path')
mime = require('mime')
Sequelize = require('sequelize')

schema =
  account_id:
    type: Sequelize.INTEGER
    validate:
      notNull: true
  backup_id:
    type: Sequelize.INTEGER
    validate:
      notNull: true
  provider:
    type: Sequelize.STRING
    validate:
      notNull: true
      notEmpty: true
  uid:
    type: Sequelize.STRING
    validate:
      notNull: true
      notEmpty: true
  snapshot:
    type: Sequelize.STRING
    validate:
      notNull: true
      notEmpty: true
  path:
    type: Sequelize.STRING
    validate:
      notNull: true
      notEmpty: true
  deleted:
    type: Sequelize.BOOLEAN
    default: false

Item = module.exports = sequelize.define 'item', schema,
  underscored: true

  classMethods:
    findOrInitialize: (attrs, cb) ->
      @find(where: attrs).complete (err, item) =>
        item ?= @build(attrs)
        cb(err, item)

  instanceMethods:
    mime: ->
      mime.lookup(@path)

    image: ->
      @mime().match(/^image/)

    url: (raw) ->
      '/' + pathLib.join('accounts', @provider, @uid, @snapshot, @path) + (raw && '?raw=true' || '')

