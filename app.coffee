express = require('express')
http = require('http')
path = require('path')
mongoose = require('mongoose')
passport = require('passport')
auth = require(__dirname + '/auth')
models = require(__dirname + '/models')
helpers = require(__dirname + '/helpers')

mongoose.connect 'localhost', 'websh'

app = express()

app.configure ->
  app.set 'port', process.env.PORT || 3000
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'jade'
  app.use express.logger('dev')
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use express.cookieParser("Never send a human to do a machine's job.")
  app.use express.session(cookie: maxAge: 60000)
  app.use passport.initialize()
  app.use passport.session()
  app.use require('connect-flash')()
  app.use helpers
  app.use app.router
  app.use express.static(path.join(__dirname, 'public'))
  app.use require('connect-assets')()

app.configure 'development', ->
  app.use express.errorHandler()

app.get '/', (req, res) ->
  res.render 'index', user: req.user

app.get '/signup', (req, res) ->
  res.render 'signup'

app.post '/signup', (req, res) ->
  # TODO

app.get '/login', (req, res) ->
  res.render 'login'

app.post '/auth',
  passport.authenticate 'local',
    successRedirect: '/'
    failureRedirect: '/login'
    failureFlash: true
    badRequestMessage: 'Please enter a username and password.'

app.post '/auth/browserid',
  passport.authenticate('browserid', failureRedirect: '/login'),
  (req, res) ->
    res.redirect('/')

http.createServer(app).listen app.get('port'), ->
  console.log("Express server listening on port " + app.get('port'))
