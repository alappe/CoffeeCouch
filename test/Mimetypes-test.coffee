assert = require 'should'
Mimetypes = require '../src/Mimetypes'

describe 'Mimetypes', ->

  it 'returns a mimetype for a given file-extension', ->
    (Mimetypes.lookup 'css').should.equal 'text/css'

  it 'returns octet-stream as default mimetype if nothing matches', ->
    (Mimetypes.lookup 'something').should.equal 'application/octet-stream'
