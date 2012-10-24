DropboxClient = require('dropbox-node').DropboxClient

GB = 1024 * 1024 * 1024

class Dropbox

  constructor: (@account, cb) ->
    dropbox = new DropboxClient(CONFIG.keys.dropbox.key, CONFIG.keys.dropbox.secret,
                                @account.token, @account.secret)
    dropbox.getAccountInfo (err, info) =>
      if err
        cb(err)
      else
        @info = info
        cb(null, @)

  used: ->
    (@info.quota_info.normal + @info.quota_info.shared) / GB

  quota: ->
    @info.quota_info.quota / GB

  free: ->
    @quota() - @used()


module.exports = Dropbox
