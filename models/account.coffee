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
  email:
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
  schedule:
    type: Sequelize.STRING
    default: 'daily'
  cursor:
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
        account.updateFromProfile(profile)
        account.type = 'oauth'
        account.token = token
        account.secret = secret
        account.save().complete(cb)

    buildFromOAuth2: (profile, accessToken, refreshToken, cb) ->
      @findOrInitialize provider: profile.provider, uid: profile.id, (err, account) ->
        account.updateFromProfile(profile)
        account.type = 'oauth2'
        account.token = accessToken
        account.refresh_token = refreshToken
        account.save().complete(cb)

  instanceMethods:
    updateFromProfile: (profile) ->
      @display_name = profile.displayName
      if profile.emails and (emails = (e.value for e in profile.emails)).length > 0
        @email = emails[0]
      else if profile.email
        @email = email
