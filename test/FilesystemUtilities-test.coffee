assert = require 'should'
FilesystemUtilities = require '../src/FilesystemUtilities.coffee'

describe 'FilesystemUtilities', ->

  describe 'abspath', ->

    it 'returns the absolute path for a relative path', ->
      absolutePath = FilesystemUtilities.abspath './boiler/attachments'
      (absolutePath.replace (__dirname.replace /test$/, ''), '').should.equal 'boiler/attachments'

    it 'returns the absolute path for an absolute path', ->
      (FilesystemUtilities.abspath '/tmp').should.equal '/tmp'
