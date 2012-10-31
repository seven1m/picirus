fs = require('fs')
express = require('express')
http = require('http')
path = require('path')
passport = require('passport')
jade_browser = require('jade-browser')
helpers = require('./lib/helpers')
Scheduler = require('./lib/scheduler')
Config = require('./lib/config')

GLOBAL.CONFIG = new Config(__dirname + '/config.json')

Sequelize = require('sequelize')
GLOBAL.sequelize = new Sequelize 'picirus', null, null
  dialect: 'sqlite'
  storage: CONFIG.path('database')

models = require('./models')
sequelize.sync()

plugins = require('./plugins') # must come after models

app = express()
server = http.createServer(app)

app.secret = "Never send a human to do a machine's job."

app.configure ->
  app.set 'port', process.env.PORT || 3000
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'jade'
  app.use express.logger('dev')
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use express.cookieParser(app.secret)
  app.use express.cookieSession()
  app.use passport.initialize()
  app.use passport.session()
  app.use require('connect-flash')()
  app.use helpers
  app.use app.router
  app.use express.static(path.join(__dirname, 'public'))

app.configure 'development', ->
  app.use express.errorHandler()

require('./routes')(app)

for name, plugin of plugins when plugin.routes
  plugin.routes(app)

new Scheduler(models.account)

server.listen app.get('port'), ->
  console.log("picirus listening on port " + app.get('port'))
