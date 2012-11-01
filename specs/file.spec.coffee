fs = require('fs')
path = require('path')
rimraf = require('rimraf')
xattr = require('xattr')
mkdirp = require('mkdirp')
Stream = require('stream').Stream

require('./spec_helper')
File = require('../lib/file')

describe File, ->
  account = null
  file = null

  beforeEach ->
    rimraf.sync(__dirname + '/../test-data')

    account =
      provider: 'dropbox'
      uid: '1234'

    file = new File(account, '2012-10-31', 'foo/bar')

  describe '#fullPath', ->
    it 'returns the full path on the filesystem', ->
      expect(file.fullPath()).toEqual(path.join path.dirname(__dirname), 'test-data/dropbox-1234/2012-10-31/foo/bar')

  describe '#mkdir', ->
    describe 'given a regular file', ->
      beforeEach ->
        file = new File(account, '2012-10-31', 'foo/bar')

      it 'creates the parent directory for the file', ->
        done = false
        runs ->
          file.mkdir -> done = true
        waitsFor (-> done), 'done', 1000
        runs ->
          dir = __dirname + '/../test-data/dropbox-1234/2012-10-31/foo'
          expect(fs.existsSync(dir)).toBeTruthy()
          expect(fs.existsSync(dir + '/bar')).toBeFalsy()

    describe 'given a directory', ->
      beforeEach ->
        file = new File(account, '2012-10-31', 'foo/baz', true)

      it 'creates the directory', ->
        done = false
        runs ->
          file.mkdir -> done = true
        waitsFor (-> done), 'done', 1000
        runs ->
          dir = __dirname + '/../test-data/dropbox-1234/2012-10-31/foo/baz'
          expect(fs.existsSync(dir)).toBeTruthy()
          expect(fs.statSync(dir).isDirectory()).toBeTruthy()

  describe '#save', ->
    filename = __dirname + '/../test-data/dropbox-1234/2012-10-31/foo/bar'

    describe 'given @isDir', ->
      beforeEach ->
        file = new File(account, '2012-10-31', 'foo/bar', true)

      describe 'given an existing file of the same name', ->
        beforeEach ->
          mkdirp.sync(path.dirname(filename))
          fs.writeFileSync filename, 'file contents'

        it 'deletes the existing file and creates the directory', ->
          cb = jasmine.createSpy('cb')
          runs -> file.save cb
          waitsFor (-> cb.callCount > 0), 'save', 1000
          runs ->
            expect(cb.mostRecentCall.args[0]).toBeNull()
            expect(fs.statSync(filename).isDirectory()).toBeTruthy()

    describe 'given string data', ->
      beforeEach ->
        file = new File(account, '2012-10-31', 'foo/bar', false, 'file contents')

      it 'writes the file', ->
        args = null
        runs ->
          file.save -> args = arguments
        waitsFor (-> args), 'args', 1000
        runs ->
          expect(args[0]).toBeNull()
          expect(fs.readFileSync(filename).toString()).toEqual('file contents')

    describe 'given a readable stream', ->
      stream = null

      beforeEach ->
        stream = new Stream()
        stream.pause = ->
        stream.resume = -> this.emit 'resume'
        file = new File(account, '2012-10-31', 'foo/bar', false, stream)

      it 'writes the file', ->
        args = null
        runs ->
          file.mkdir ->
            file.save -> args = arguments
            stream.on 'resume', ->
              stream.emit('data', 'stream contents')
              stream.emit('end')
        waitsFor (-> args), 'args', 1000
        runs ->
          expect(args[0]).toBeNull()
          expect(fs.readFileSync(filename).toString()).toEqual('stream contents')

    describe 'given the same rev', ->
      beforeEach ->
        mkdirp.sync(path.dirname(filename))
        fs.writeFileSync(filename, 'old contents')
        xattr.set filename, 'user.rev', '12345'
        file = new File account, '2012-10-31', 'foo/bar', false, 'file contents',
          rev: '12345'

      it 'does not overwrite the file', ->
        cb = jasmine.createSpy('cb')
        runs -> file.save cb
        waitsFor (-> cb.callCount > 0), 'save', 1000
        runs ->
          expect(cb.mostRecentCall.args[0]).toBeNull()
          expect(fs.readFileSync(filename).toString()).toEqual('old contents')

    describe 'given an existing directory of the same name', ->
      beforeEach ->
        mkdirp.sync(filename)
        file = new File account, '2012-10-31', 'foo/bar', false, 'file contents'

      it 'deletes the existing directory and writes the file', ->
        cb = jasmine.createSpy('cb')
        runs -> file.save cb
        waitsFor (-> cb.callCount > 0), 'save', 1000
        runs ->
          expect(cb.mostRecentCall.args[0]).toBeNull()
          expect(fs.statSync(filename).isDirectory()).toBeFalsy()

  describe '#saveMeta', ->
    filename = __dirname + '/../test-data/dropbox-1234/2012-10-31/foo/bar'

    beforeEach ->
      mkdirp.sync(path.dirname(filename))
      fs.writeFileSync(filename, 'foo')
      file = new File account, '2012-10-31', 'foo/bar', false, 'file contents',
        url: 'http://example.com/foo/bar'
        rev: '1234'

    it 'writes xattrs', ->
      list = null
      runs ->
        file.saveMeta ->
          list = xattr.list(filename)
      waitsFor (-> list), 'list', 1000
      runs ->
        expect(list).toEqual
          'user.url': 'http://example.com/foo/bar'
          'user.rev': '1234'

  describe '#exists', ->
    filename = __dirname + '/../test-data/dropbox-1234/2012-10-31/foo/bar'

    beforeEach ->
      file = new File account, '2012-10-31', 'foo/bar', false, 'file contents'

    describe 'given the file does not exist on the filesystem', ->

      it 'returns false', ->
        exists = null
        runs ->
          file.exists (bool) ->
            exists = bool
        waitsFor (-> exists?), 'exists', 1000
        runs ->
          expect(exists).toEqual(false)

    describe 'given the file exists on the filesystem', ->

      beforeEach ->
        mkdirp.sync(path.dirname(filename))
        fs.writeFileSync(filename, 'file contents')

      it 'returns true', ->
        exists = null
        runs ->
          file.exists (bool) ->
            exists = bool
        waitsFor (-> exists?), 'exists', 1000
        runs ->
          expect(exists).toEqual(true)

  describe '#getMeta', ->
    filename = __dirname + '/../test-data/dropbox-1234/2012-10-31/foo/bar'

    beforeEach ->
      file = new File account, '2012-10-31', 'foo/bar', false, 'file contents',
        url: 'http://example.com/foo/bar'
        rev: '1234'
      done = false
      runs ->
        file.save -> done = true
      waitsFor (-> done), 'save', 1000

    it 'returns an object containing all meta attributes', ->
      attrs = null
      runs ->
        file.getMeta (err, meta) ->
          attrs = meta
      waitsFor (-> attrs), 'getMeta', 1000
      runs ->
        expect(attrs).toEqual
          url: 'http://example.com/foo/bar'
          rev: '1234'
