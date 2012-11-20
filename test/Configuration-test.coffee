assert = require 'should'
Configuration = require '../src/Configuration'

describe 'Configuration', ->
  describe 'fromFile', ->
    it 'throws error for invalid JSON', ->
      config = new Configuration()
      invalidJSON = '{ "something": "wrong }'
      try
        config.fromFile invalidJSON
      catch error
        error.message.should.equal 'Configuration file is no valid JSON!'

    it 'reads values from file', ->
      config = new Configuration()
      validJSON = '{ "port": 23456 }'
      config.fromFile validJSON
      config.values.port.should.equal 23456

  describe 'toFile()', ->
    written = undefined
    configuration = undefined

    beforeEach ->
      configuration = new Configuration()
      # Override the writeFile method to mock writing…
      configuration._writeFile = configuration.writeFile
      configuration.writeFile = (pathAndFile, content) ->
        written = content

    it 'saves configuration to file', ->
      configuration.toFile
        key1: 'value1'
        key2: 'value2'
      got = JSON.parse written
      got.key1.should.equal 'value1'
      got.key2.should.equal 'value2'
