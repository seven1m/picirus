ACCOUNT_TYPES =
  dropbox: 'Dropbox'
  flickr: 'Flickr'
  google: 'Gmail'
  facebook: 'Facebook'
  imap: 'IMAP'
  pop3: 'POP3'
  ftp: 'FTP'
  scp: 'SCP'

fs = require('fs')
syntax = require('node-syntaxhighlighter')
Paginator = require('paginator')

File = require('./lib/file')
Browser = require('./lib/browser')
models = require('./models')
util = require('./lib/util')
plugins = require('./plugins')

module.exports = (app) ->

  find = (req, cb) ->
    if req.params.length
      req.params.provider = req.params[0]
      req.params.uid = req.params[1]
    models.account.find(where: {provider: req.params.provider, uid: req.params.uid}).complete cb

  app.get '/', (req, res) ->
    models.backup.count().complete (err, count) ->
      paginator = new Paginator perPage: 10, page: req.query.page, count: count
      models.backup.all(order: 'started desc', offset: paginator.skip, limit: paginator.limit).complete (err, backups) ->
        res.render 'dashboard', backups: backups, paginator: paginator

  app.get '/stats/backups', (req, res) ->
    models.backup.stats (err, stats) ->
      res.json stats

  app.get '/stats/storage', (req, res) ->
    util.storageStats (err, stats) ->
      res.json stats

  app.get '/accounts', (req, res) ->
    models.account.all().complete (err, accounts) ->
      if err
        res.render 'error', error: "could not load accounts: #{e}"
      else
        res.render 'accounts', accounts: accounts, acct_types: ([p, l] for p, l of ACCOUNT_TYPES)

  app.get '/settings', (req, res) ->
    res.render 'settings_page'
  
  app.post '/accounts/:provider/:uid/backup', (req, res) ->
    find req, (err, account) ->
      if err or not account
        res.render 'error', error: err || 'account not found'
      else
        plugin = plugins[account.provider]
        if plugin.backup?
          plugin.backup account, (err) ->
          req.flash 'success', "backing up #{account.provider}..."
        else
          req.flash 'error', "backing up #{account.provider} not supported yet"
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
            browser.meta (err, meta) =>
              if err
                res.render 'error', error: err
              else
                if stat.isDirectory()
                  browser.snapshots (err, snapshots) =>
                    sort = req.query.sort || 'name'
                    browser.list sort, (err, files) =>
                      if err
                        res.render 'error', error: err
                      else
                        res.render 'folder', account: account, browser: browser, files: files, snapshots: snapshots, sort: sort
                else
                  if req.query.raw
                    res.sendfile stat.fs_path
                  else
                    if stat.lang
                      fs.readFile stat.fs_path, (err, body) =>
                        code = syntax.highlight(body.toString(), stat.lang)
                        res.render 'file', account: account, browser: browser, file: stat, code: code, meta: meta
                    else
                      res.render 'file', account: account, browser: browser, file: stat, code: null, meta: meta
        else
          browser.latestSnapshot (err, snapshot) =>
            if err
              if err.code == 'ENOENT'
                err = "This account hasn't yet been backed up, so there aren't any files to see yet."
              res.render 'error', error: err
            else
              res.redirect "/accounts/#{req.params[0]}/#{req.params[1]}/#{snapshot}"
