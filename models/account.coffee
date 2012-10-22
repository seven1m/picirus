DropboxClient = require('dropbox-node').DropboxClient

Sequelize = require('sequelize')

schema =
  provider:
    type: Sequelize.STRING
    validate:
      notNull: true
      notEmpty: true
  uid:
    type: Sequelize.STRING
    validate:
      notNull: true
      notEmpty: true
  type:
    type: Sequelize.STRING
    validate:
      notNull: true
      notEmpty: true
  token:
    type: Sequelize.STRING
  secret:
    type: Sequelize.STRING
  refresh_token:
    type: Sequelize.STRING

Account = module.exports = sequelize.define 'account', schema,
  underscored: true

  classMethods:
    findOrInitialize: (attrs, cb) ->
      @find(where: attrs).complete (err, account) =>
        account ?= @build(attrs)
        cb(err, account)

    buildFromOAuth: (provider, uid, token, secret, cb) ->
      @findOrInitialize provider: provider, uid: uid, (err, account) ->
        account.type = 'oauth'
        account.token = token
        account.secret = secret
        account.save().complete(cb)

    buildFromOAuth2: (provider, uid, accessToken, refreshToken, cb) ->
      @findOrInitialize provider: provider, uid: uid, (err, account) ->
        account.type = 'oauth2'
        account.token = accessToken
        account.refresh_token = refreshToken
        account.save().complete(cb)

  instanceMethods:
    acctInfo: (cb) ->
      dropbox = new DropboxClient(KEYS.dropbox.key, KEYS.dropbox.secret,
                                  @token, @secret)
      console.log dropbox
      dropbox.getAccountInfo cb
