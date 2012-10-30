Config = require('../lib/config')

describe Config, ->
  config = null

  beforeEach ->
    config = new Config
      foo: 'bar'
      paths:
        database: 'data.sqlite3'

  it 'acts like a regular object', ->
    expect(config.foo).toEqual('bar')

  describe '#root', ->
    it 'returns the root path of the project', ->
      expect(config.root()).toMatch(/\/lib\/\.\.\//)

  describe '#path', ->

    describe 'given a relative path', ->
      beforeEach ->
        config.paths.database = 'data.sqlite3'

      it 'returns the path prepended with the app root', ->
        expect(config.path('database')).toEqual(config.root() + 'data.sqlite3')

    describe 'given an absolute path', ->
      beforeEach ->
        config.paths.database = '/data.sqlite3'

      it 'returns the absolute path', ->
        expect(config.path('database')).toEqual('/data.sqlite3')

    describe 'given a path with variables and a reference object', ->
      beforeEach ->
        config.paths.account = '/data/:provider-:uid/'

      it 'returns the path with variables interpolated', ->
        obj =
          provider: 'dropbox'
          uid: '1234'
        expect(config.path('account', obj)).toEqual('/data/dropbox-1234/')
