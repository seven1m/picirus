express = require('express')
http = require('http')
path = require('path')
mongoose = require('mongoose')
passport = require('passport')
jade_browser = require('jade-browser')
auth = require(__dirname + '/auth')
models = require(__dirname + '/models')
helpers = require(__dirname + '/helpers')

mongoose.connect 'localhost', 'wsh'

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
  app.use require('connect-assets')()
  app.use jade_browser('/js/templates.js', '**/*.jade', root: __dirname + '/assets/js/templates')

app.configure 'development', ->
  app.use express.errorHandler()

app.get '/', (req, res) ->
  res.render 'index'

app.get '/login-failure', (req, res) ->
  res.render 'login-failure'

app.post '/auth/browserid',
  passport.authenticate('browserid', failureRedirect: '/login-failure'),
  (req, res) ->
    req.session.username = req.user.username
    res.json
      status: 'success'
      username: req.session.username

require(__dirname + '/sync')(server, app)

server.listen app.get('port'), ->
  console.log("Express server listening on port " + app.get('port'))
