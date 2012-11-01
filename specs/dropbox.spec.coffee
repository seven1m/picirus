fs = require('fs')
path = require('path')
mkdirp = require('mkdirp')
rimraf = require('rimraf')

require('./spec_helper')
Account = require('../models/account')
DropboxPlugin = require('../plugins/dropbox')

describe DropboxPlugin, ->

  root = __dirname + '/../test-data/dropbox-1234/2012-10-31/foo'
  plugin = null
  account = Account.build
    provider: 'dropbox'
    uid: '1234'

  beforeEach ->
    rimraf.sync(root)
    mkdirp.sync(root)
    plugin = new DropboxPlugin

  describe '#_findFile', ->

    describe 'given no file is present', ->

      it 'calls the callback with an error', ->
        cb = jasmine.createSpy('cb')
        runs ->
          plugin._findFile account, '2012-10-31', 'foo/baz', cb
        waitsFor (-> cb.callCount > 0), '_findFile', 1000
        runs ->
          expect(cb.mostRecentCall.args[0]).toEqual('not found')

    describe 'given "baz" file is present', ->

      beforeEach ->
        fs.writeFileSync(path.join(root, 'baz'), 'file contents')

      it 'calls the callback with the filename', ->
        cb = jasmine.createSpy('cb')
        runs ->
          plugin._findFile account, '2012-10-31', 'foo/baz', cb
        waitsFor (-> cb.callCount > 0), '_findFile', 1000
        runs ->
          expect(cb.mostRecentCall.args[0]).toBeNull()
          expect(cb.mostRecentCall.args[1]).toEqual('baz')

    describe 'given "BAZ" file is present', ->

      beforeEach ->
        fs.writeFileSync(path.join(root, 'BAZ'), 'file contents')

      it 'calls the callback with the filename', ->
        cb = jasmine.createSpy('cb')
        runs ->
          plugin._findFile account, '2012-10-31', 'foo/baz', cb
        waitsFor (-> cb.callCount > 0), '_findFile', 1000
        runs ->
          expect(cb.mostRecentCall.args[0]).toBeNull()
          expect(cb.mostRecentCall.args[1]).toEqual('BAZ')
