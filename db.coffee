Sequelize = require('sequelize')

GLOBAL.sequelize ?= new Sequelize 'picirus', null, null
  dialect: 'sqlite'
  storage: CONFIG.path('database')
