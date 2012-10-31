ACCOUNT_TYPES =
  dropbox: 'Dropbox'
  flickr: 'Flickr'
  google: 'Gmail'
  imap: 'IMAP'
  pop3: 'POP3'
  ftp: 'FTP'
  scp: 'SCP'

models = require('./models')

module.exports = (app) ->

  find = (req, cb) ->
    models.account.find(where: {provider: req.params.provider, uid: req.params.uid}).complete cb

  app.get '/', (req, res) ->
    res.render 'dashboard'

  app.get '/accounts', (req, res) ->
    models.account.findAll().error(
      (e) -> res.render 'error', error: "could not load accounts: #{e}"
    ).success (accounts) ->
      res.render 'accounts', accounts: accounts, acct_types: ([p, l] for p, l of ACCOUNT_TYPES)

  app.get '/accounts/:provider/:uid', (req, res) ->
    find req, (err, account) ->
      if err or not account
        res.render 'error', error: err || 'account not found'
      else
        account.acctInfo (err, info) ->
          res.render account.provider, account: account, info: info, error: err

  app.post '/accounts/:provider/:uid/backup', (req, res) ->
    find req, (err, account) ->
      if err or not account
        res.render 'error', error: err || 'account not found'
      else
        status = account.backup()
        if status == true
          req.flash 'success', "backing up #{account.provider}..."
        else
          req.flash 'error', status
        res.redirect '/accounts'

  app.delete '/accounts/:provider/:uid', (req, res) ->
    find req, (err, account) ->
      if err or not account
        res.render 'error', error: err || 'account not found'
      else
        account.destroy().complete (err) ->
          if err
            res.render 'error', error: err
          else
            res.redirect '/accounts'

  app.get '/accounts/:provider/:uid/delete', (req, res) ->
    find req, (err, account) ->
      if err or not account
        res.render 'error', error: err || 'account not found'
      else
        res.render 'remove_account', account: account
