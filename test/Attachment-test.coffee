assert = require 'should'
Attachment = require '../src/Attachment'

describe 'Attachment', ->
  attachment = undefined

  beforeEach ->
    attachment = new Attachment '/tmp/something/myFile.css', '/tmp/something', ''
    # Override the readFile method to mock reading…
    attachment._readFile = attachment.readFile
    attachment.readFile = ->
      attachment.data = 'data'
      
  describe 'constructor', ->
    it 'initializes with absolute path to get local path', ->
      attachment.path.should.equal 'myFile.css'

    it 'initializes with prefix which results in prefixed path', ->
      attachment = new Attachment '/tmp/something/myFile.css', '/tmp/something/', 'styles/'
      attachment.path.should.equal 'styles/myFile.css'

  describe 'methods', ->

    #it 'has mimetype for file', ->
    #  attachment.mime.should.equal 'text/css'

    it 'getMimetype() returns mimetype for file', ->
      attachment.getMimetype().should.equal 'text/css'

    it 'getMd5Hash() returns md5-hash for file', ->
      attachment.getMd5Hash().should.equal '8d777f385d3dfec8815d20f7496026dc'

    it 'getObject() returns object-representation of file', ->
      obj = attachment.getObject '33-93303093093'
      obj.content_type.should.equal (attachment.getMimetype())
      obj.digest.should.equal "md5-#{attachment.getMd5Hash()}"
      obj.revpos.should.equal 33
      obj.data.should.equal 'data' #as the file is empty

    it 'getName() returns absolute path', ->
      attachment.getName().should.equal '/tmp/something/myFile.css'
