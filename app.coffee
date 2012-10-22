ACCOUNT_TYPES =
  dropbox: 'Dropbox'
  flickr: 'Flickr'
  google: 'Gmail'

express = require('express')
http = require('http')
path = require('path')
_ = require('underscore')
mongoose = require('mongoose')
passport = require('passport')
jade_browser = require('jade-browser')
helpers = require('./helpers')

Sequelize = require('sequelize')
GLOBAL.sequelize = new Sequelize 'minibot', null, null
  dialect: 'sqlite'
  storage: __dirname + '/data.sqlite3'

models = require('./models')
sequelize.sync()

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
  models.account.findAll().error(
    (e) -> res.render 'error', error: "could not load accounts: #{e}"
  ).success (accounts) ->
    res.render 'index', accounts: accounts, acct_types: ([p, l] for p, l of ACCOUNT_TYPES)

app.get '/accounts/:id', (req, res) ->
  models.account.find(req.params.id).error(
    (e) -> res.render 'error', error: e
  ).success (account) ->
    if ACCOUNT_TYPES[account.provider]
      account.acctInfo (err, info) ->
        res.render account.provider, account: account, info: info
    else
      res.render 'error', error: 'unsupported account type'

require('./auth')(app)

require('./sync')(server, app)

server.listen app.get('port'), ->
  console.log("minibot listening on port " + app.get('port'))
