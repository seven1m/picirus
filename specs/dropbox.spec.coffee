fs = require('fs')
path = require('path')
mkdirp = require('mkdirp')
rimraf = require('rimraf')

require('./spec_helper')
File = require('../lib/file')
Account = require('../models/account')
DropboxBackup = require('../plugins/dropbox').DropboxBackup

describe 'DropboxBackup', ->

  root = __dirname + '/../test-data/dropbox-1234/2012-10-31/foo'
  backup = null
  account = Account.build
    provider: 'dropbox'
    uid: '1234'

  beforeEach ->
    rimraf.sync(root)
    mkdirp.sync(root)
    backup = new DropboxBackup(account)
    backup.snapshot = '2012-10-31'

  describe '#findFile', ->

    describe 'given no file is present', ->

      it 'calls the callback with an error', ->
        cb = jasmine.createSpy('cb')
        runs ->
          backup.findFile 'foo/baz', cb
        waitsFor (-> cb.callCount > 0), '_findFile', 1000
        runs ->
          expect(cb.mostRecentCall.args[0]).toEqual('not found')

    describe 'given "baz" file is present', ->

      beforeEach ->
        fs.writeFileSync(path.join(root, 'baz'), 'file contents')

      it 'calls the callback with the file', ->
        cb = jasmine.createSpy('cb')
        runs ->
          backup.findFile 'foo/baz', cb
        waitsFor (-> cb.callCount > 0), '_findFile', 1000
        runs ->
          expect(cb.mostRecentCall.args[0]).toBeNull()
          expect(cb.mostRecentCall.args[1] instanceof File).toBeTruthy('not instance of File')
          expect(cb.mostRecentCall.args[1].path).toEqual('baz')

    describe 'given "BAZ" file is present', ->

      beforeEach ->
        fs.writeFileSync(path.join(root, 'BAZ'), 'file contents')

      it 'calls the callback with the file', ->
        cb = jasmine.createSpy('cb')
        runs ->
          backup.findFile 'foo/baz', cb
        waitsFor (-> cb.callCount > 0), '_findFile', 1000
        runs ->
          expect(cb.mostRecentCall.args[0]).toBeNull()
          expect(cb.mostRecentCall.args[1] instanceof File).toBeTruthy()
          expect(cb.mostRecentCall.args[1].path).toEqual('BAZ')
