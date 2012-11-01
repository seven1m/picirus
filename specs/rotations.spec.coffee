_ = require('underscore')
moment = require('moment')

require('./spec_helper')
rotations = require('../lib/rotations')

describe 'rotations', ->

  describe 'GFS', ->

    rotation = null
    paths = [
      '2012-10-30',
      '2012-10-29',
      '2012-10-28',
      '2012-10-27',
      '2012-10-26',
      '2012-10-25',
      '2012-10-24',
      '2012-10-23',
      '2012-10-21',
      '2012-10-14',
      '2012-10-07',
      '2012-09-30',
      '2012-09-23',
      '2012-09-16',
      '2012-10-01',
      '2012-09-01',
      '2012-08-01',
      '2012-07-01',
      '2012-06-01',
      '2012-05-01',
      '2012-04-01',
      '2012-03-01',
      '2012-02-01',
      '2012-01-01',
      '2011-12-01',
      '2011-11-01',
      '2011-10-01'
    ]

    beforeEach ->
      rotation = new rotations.GFSRotation(root)
      rotation.today = moment('2012-10-31')
      spyOn(rotation, 'list').andCallFake (cb) =>
        setTimeout (-> cb(null, paths)), 1

    describe '#latest', ->

      it 'returns the most recent snapshot path', ->
        latest = null
        runs ->
          rotation.latest (err, l) -> latest = l
        waitsFor ->
          latest
        runs ->
          expect(latest).toEqual('2012-10-30')

    describe '#snapshot', ->

      describe 'given there is an existing path to copy', ->
        it 'cp -al the latest directory', ->
          spyOn(rotation, 'cp_al')
          cb = jasmine.createSpy('cb')
          runs ->
            rotation.snapshot(cb)
          waitsFor ->
            rotation.cp_al.callCount > 0
          runs ->
            args = rotation.cp_al.mostRecentCall.args
            expect(args[0]).toEqual('2012-10-30')
            expect(args[1]).toEqual('2012-10-31')

      describe 'given there is not an existing path to copy', ->
        beforeEach ->
          rotation = new rotations.GFSRotation(root)
          rotation.today = moment('2012-10-31')
          spyOn(rotation, 'list').andCallFake (cb) =>
            setTimeout (-> cb(null, [])), 1

        it 'does not call cp_al', ->
          spyOn(rotation, 'cp_al')
          spyOn(rotation, 'mkdir')
          cb = jasmine.createSpy('cb')
          runs ->
            rotation.snapshot(cb)
          waitsFor (-> rotation.mkdir.callCount > 0), 'mkdir', 1000
          runs ->
            expect(rotation.cp_al).not.toHaveBeenCalled()

        it 'calls mkdir', ->
          spyOn(rotation, 'mkdir')
          cb = jasmine.createSpy('cb')
          runs ->
            rotation.snapshot(cb)
          waitsFor (-> rotation.mkdir.callCount > 0), 'mkdir', 1000
          runs ->
            args = rotation.mkdir.mostRecentCall.args
            expect(args[0]).toEqual('2012-10-31')

    describe 'given that a new backup ran today', ->

      beforeEach ->
        paths.unshift('2012-10-31')

      describe '#pathsToKeep', ->

        saved = null

        beforeEach ->
          saved = rotation.pathsToKeep(paths)

        it 'returns the last 7 days, last 5 sundays, and last 12 1st-of-months', ->
          expect(saved).toEqual [
            '2012-10-31',
            '2012-10-30',
            '2012-10-29',
            '2012-10-28',
            '2012-10-27',
            '2012-10-26',
            '2012-10-25',
            #'2012-10-24', removed
            #'2012-10-23', removed
            '2012-10-21',
            '2012-10-14',
            '2012-10-07',
            '2012-09-30',
            '2012-09-23',
            #'2012-09-16', removed
            '2012-10-01',
            '2012-09-01',
            '2012-08-01',
            '2012-07-01',
            '2012-06-01',
            '2012-05-01',
            '2012-04-01',
            '2012-03-01',
            '2012-02-01',
            '2012-01-01',
            '2011-12-01',
            '2011-11-01'
            #'2011-10-01' removed
          ]

      describe '#cleanup', ->

        it 'removes paths that drop off the rotation', ->
          removed = []
          finished = false

          runs ->
            spyOn(rotation, 'remove').andCallFake (path, c) ->
              removed.push(path)
              c()
            cb = jasmine.createSpy('cb').andCallFake (err) ->
              finished = true
            rotation.cleanup cb
          waitsFor (-> finished), 'cleanup', 1000
          runs ->
            removed.sort()
            expect(removed).toEqual [
              '2011-10-01',
              '2012-09-16',
              '2012-10-23',
              '2012-10-24'
            ]
