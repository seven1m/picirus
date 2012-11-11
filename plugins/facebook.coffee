_ = require('underscore')
async = require('async')
passport = require('passport')
FacebookStrategy = require('passport-facebook').Strategy
graph = require('fbgraph')
https = require('https')

base = require('./base')
BasePlugin = base.BasePlugin
PluginBackup = base.PluginBackup
File = require('../lib/file')
models = require('../models')

class FacebookPlugin extends BasePlugin

  routes: (app) ->
    config =
      clientID: CONFIG.keys.facebook.client_id
      clientSecret: CONFIG.keys.facebook.client_secret
      callbackURL: "http://localhost:3000/auth/facebook/callback"
    passport.use 'facebook-authz', new FacebookStrategy(config, @build)
    app.get '/auth/facebook', @auth
    app.get '/auth/facebook/callback', @auth, @redirect

  auth: passport.authorize('facebook-authz',
    scope: ['offline_access', 'user_photos']
  )

  build: (accessToken, refreshToken, profile, done) =>
    models.account.buildFromOAuth2 profile, accessToken, refreshToken, done

  backup: (account, cb) =>
    new FacebookBackup(account).run(cb)


class FacebookBackup extends PluginBackup

  constructor: (@account) ->
    super(@account)
    @client = graph
    @client.setAccessToken(@account.token)
    @until = null

  backup: (cb) =>
    params = {}
    params.until = @until if @until
    @client.get 'me/feed', params, (err, res) =>
      async.forEachSeries res.data, @save, (err) =>
        if next = res.paging?.next
          for pair in next.split('&')
            parts = pair.split('=')
            if parts[0] == 'until'
              @until = parts[1]
          if @until
            process.nextTick => @backup(cb)

    #@client.delta @account.cursor, (err, data) =>
      #async.forEachSeries data.entries, @save, (err) =>
        #if err
          #cb(err)
        #else if data.has_more
          #@backup(cb)
        #else
          #@account.cursor = data.cursor
          #@account.save().complete(cb)

  save: (data, cb) =>
    if data.type == 'photo'
      @client.get data.object_id, (err, res) =>
        if err
          cb(err)
        else
          https.get res.source, (res) =>
            path = "photos/#{data.object_id}.jpg"
            file = new File @account, @snapshot, path, false, res, rev: data.updated_time
            file.save (err) =>
              if err
                console.log "#{path} - error - #{err}"
              else
                console.log "#{path} - saved"
                @incCount('added') if file.added
                @incCount('updated') if file.updated
              cb(err)
    else
      cb()

  #save: (path, cb) =>
    #meta = path[1]
    #path = path[0]
    #if meta
      #stream = !meta.is_dir && @client.getFile(path)
      #file = new File @account, @snapshot, meta.path, meta.is_dir, stream,
        #rev: meta.rev
      #file.save (err) =>
        #if err
          #console.log "#{path} - error - #{err}"
        #else
          #console.log "#{path} - saved"
          #@incCount('added') if file.added
          #@incCount('updated') if file.updated
        #cb(err)
    #else
      #@findFile path, (err, actual) =>
        #console.log "#{path} - removing"
        #if actual
          #file = new File @account, @snapshot, actual
          #@rotation.remove file.fullPath(), (err) =>
            #@incCount('deleted') unless err
            #cb(err)
        #else
          #@incCount('deleted')
          #cb()

module.exports = FacebookPlugin
FacebookPlugin.FacebookBackup = FacebookBackup
