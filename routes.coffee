ACCOUNT_TYPES =
  dropbox: 'Dropbox'
  flickr: 'Flickr'
  google: 'Gmail'
  imap: 'IMAP'
  pop3: 'POP3'
  ftp: 'FTP'
  scp: 'SCP'

fs = require('fs')
syntax = require('node-syntaxhighlighter')

Browser = require('./lib/browser')
models = require('./models')

module.exports = (app) ->

  find = (req, cb) ->
    if req.params.length
      req.params.provider = req.params[0]
      req.params.uid = req.params[1]
    models.account.find(where: {provider: req.params.provider, uid: req.params.uid}).complete cb

  app.get '/', (req, res) ->
    models.backup.findAll(order: 'started desc', limit: 25).complete (err, backups) ->
      res.render 'dashboard', backups: backups

  app.get '/accounts', (req, res) ->
    models.account.findAll().complete (err, accounts) ->
      if err
        res.render 'error', error: "could not load accounts: #{e}"
      else
        res.render 'accounts', accounts: accounts, acct_types: ([p, l] for p, l of ACCOUNT_TYPES)

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

  app.get /\/accounts\/(\w+)\/([^\/]+)\/?(.*)?/, (req, res) ->
    find req, (err, account) ->
      if err or not account
        res.render 'error', error: err || 'account not found'
      else
        browser = new Browser(account, req.params[2])
        if browser.snapshot
          browser.stat (err, stat) =>
            if err
              res.render 'error', error: err
            else
              if stat.isDirectory()
                browser.snapshots (err, snapshots) =>
                  browser.list (err, files) =>
                    if err
                      res.render 'error', error: err
                    else
                      res.render 'folder', account: account, browser: browser, files: files, snapshots: snapshots
              else
                if req.query.raw
                  res.sendfile stat.fs_path
                else
                  if stat.lang
                    fs.readFile stat.fs_path, (err, body) =>
                      code = syntax.highlight(body.toString(), stat.lang)
                      res.render 'file', account: account, browser: browser, file: stat, code: code
                  else
                    res.render 'file', account: account, browser: browser, file: stat, code: null
        else
          browser.latestSnapshot (err, snapshot) =>
            if err
              if err.code == 'ENOENT'
                err = "This account hasn't yet been backed up, so there aren't any files to see yet."
              res.render 'error', error: err
            else
              res.redirect "/accounts/#{req.params[0]}/#{req.params[1]}/#{snapshot}"
