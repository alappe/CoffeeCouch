assert = require 'should'
CouchDBFunctions = require '../src/CouchDBFunctions'

describe 'CouchDBFunctions', ->
  couchDBFunctions = undefined

  beforeEach ->
    couchDBFunctions = new CouchDBFunctions()

  describe 'lintCoffeeScript()', ->
    it 'returns true for valid CoffeeScript', ->
      src = """
a = 20
      """
      (couchDBFunctions.lintCoffeeScript src).should.equal true

    it 'returns false for invalid CoffeeScript', ->
      src = """
var a = b;
      """
      (couchDBFunctions.lintCoffeeScript src).should.equal false

  describe 'formatCoffeeScript()', ->
    it 'returns one-line with escaped doublequotes', ->
      src = """
nameA = "Peter"
nameB = "John"
      """
      expected = 'nameA = \"Peter\"\nnameB = \"John\"'
      (couchDBFunctions.formatCoffeeScript src).should.equal expected
