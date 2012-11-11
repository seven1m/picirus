fs = require('fs')
express = require('express')
partials = require('express-partials')
http = require('http')
path = require('path')
passport = require('passport')
helpers = require('./lib/helpers')
Scheduler = require('./lib/scheduler')
Config = require('./lib/config')

GLOBAL.CONFIG = new Config(__dirname + '/config.json')

models = require('./models')
plugins = require('./plugins')

sequelize.sync()
sequelize.query("update accounts set status='idle';")

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
  app.use (req, res, next) ->
    if req.url.match(/^\/(css|js|images|font)/)
      res.setHeader "Cache-Control", "public, max-age=345600"
    next()
  app.use express.static(path.join(__dirname, 'public'))

app.configure 'development', ->
  app.use express.errorHandler()

require('./routes')(app)

for name, plugin of plugins when plugin.routes
  plugin.routes(app)

new Scheduler(models.account)

server.listen app.get('port'), ->
  console.log("picirus listening on port " + app.get('port'))
