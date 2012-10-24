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
  display_name:
    type: Sequelize.STRING
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

    buildFromOAuth: (profile, token, secret, cb) ->
      @findOrInitialize provider: profile.provider, uid: profile.id, (err, account) ->
        account.display_name = profile.displayName
        account.type = 'oauth'
        account.token = token
        account.secret = secret
        account.save().complete(cb)

    buildFromOAuth2: (profile, accessToken, refreshToken, cb) ->
      @findOrInitialize provider: profile.provider, uid: profile.id, (err, account) ->
        account.display_name = profile.displayName
        account.type = 'oauth2'
        account.token = accessToken
        account.refresh_token = refreshToken
        account.save().complete(cb)

  instanceMethods:
    acctInfo: (cb) ->
      dropbox = new DropboxClient(KEYS.dropbox.key, KEYS.dropbox.secret,
                                  @token, @secret)
      dropbox.getAccountInfo cb
