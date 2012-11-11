_ = require('underscore')
async = require('async')
passport = require('passport')
FacebookStrategy = require('passport-facebook').Strategy
graph = require('fbgraph')
https = require('https')
url = require('url')

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
    models.account.buildFromOAuth2 profile, accessToken, refreshToken, (err, account) =>
      if err
        done(err)
      else
        @backup(account)
        done(null, account)

  backup: (account, cb) =>
    new FacebookBackup(account).run(cb)


class FacebookBackup extends PluginBackup

  constructor: (@account) ->
    super(@account)
    @client = graph
    @client.setAccessToken(@account.token)
    @until = null
    @since = null

  backup: (cb) =>
    params = {}
    if @until
      params.until = @until
    else if @account.cursor # FIXME does FB return the first batch 'since', or the last batch 'since'?
      params.since = @account.cursor
    @client.get 'me/feed', params, (err, res) =>
      if err
        cb(err)
      else
        # FIXME I think some pages will have zero data length, but we should still query for the next page
        if res.data and res.data.length > 0
          async.forEachSeries res.data, @save, (err) =>
            if err
              cb(err)
            else
              if not @since
                @since = @_findParam(res.paging?.previous, 'since')
              if @until = @_findParam(res.paging?.next, 'until')
                process.nextTick => @backup(cb)
              else
                @finish(cb)
        else
          @finish(cb)

  save: (data, cb) =>
    if data.type == 'photo'
      @client.get data.object_id, (err, res) =>
        if err
          if err.code == 100 # just a bad image, skip it
            cb()
          else
            cb(err)
        else
          console.log "retrieving #{data.object_id}..."
          path = "photos/#{data.object_id}.jpg"
          uri = url.parse(res.source)
          req = https.request host: uri.host, port: uri.port, path: uri.path, (res) =>
            file = new File @account, @snapshot, path, false, res, rev: data.updated_time, updated: data.updated_time
            file.save (err) =>
              if err
                console.log "#{path} - error - #{err}"
              else
                console.log "#{path} - saved"
                @incCount('added') if file.added
                @incCount('updated') if file.updated
              req.destroy() # FIXME this doesn't seem right, but the timeout fires if we don't destroy the req
              cb(err)
          req.setTimeout 10000, =>
            data.fail_count ?= 0
            console.log "timeout trying to retrieve Facebook photo (#{data.fail_count} failures): #{path}"
            req.destroy()
            if data.fail_count < 5
              data.fail_count++
              @save(data, cb)
            else
              cb("timeout trying to retreive photo #{path}")
          req.end()
    else
      cb()

  finish: (cb) =>
    @account.cursor = @since
    @account.save().complete(cb)

  _findParam: (url, name) =>
    if url
      for pair in url.split('&')
        parts = pair.split('=')
        if parts[0] == name
          return parts[1]


module.exports = FacebookPlugin
FacebookPlugin.FacebookBackup = FacebookBackup
