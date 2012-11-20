assert = require 'should'
path = require 'path'
List = require '../src/List'

describe 'List', ->

  describe 'constructor', ->

    it 'sets listPath', ->
      listRootPath = '/tmp/lists'
      name = 'my_list'
      list = new List listRootPath, name
      list.listPath.should.equal = path.join listRootPath, name

    it 'sets name', ->
      listRootPath = '/tmp/lists'
      name = 'my_list'
      list = new List listRootPath, name
      list.name.should.equal name

  describe 'code()', ->

    list = undefined

    beforeEach ->
      listRootPath = '/tmp/lists'
      name = 'my_list'
      list = new List listRootPath, name
      list.loadList = (listPath) ->
        'list content'

    it 'returns list content', ->
      list.code().should.equal 'list content'

  describe 'loadList()', ->

    it 'throws error on invalid CoffeeScript', ->
      list = new List '/tmp/lists', 'my_list'
      # Override loadFile method to mock in test
      list.loadFile = -> 'var invalidCoffeeScript = 23;'
      try
        list.loadList '/tmp/lists/my_list'
      catch error
        error.message.should.equal '/tmp/lists/my_list/list.coffee does not compile!'

    it 'returns undefined if file is not found', ->
      list = new List '/tmp/lists', 'my_list'
      # Override loadFile method to mock in test
      list.loadFile = -> throw new Error 'EOPEN cannot open file'
      value = list.loadList '/tmp/lists/my_list'
      'some'.should.equal 'some' unless value?

    it 'returns formatted CoffeeScript', ->
      list = new List '/tmp/lists', 'my_list'
      # Override loadFile method to mock in test
      list.loadFile = ->
        """
name1 = 'name1'
name2 = 'name2'
        """
      (list.loadList '/tmp/lists/my_list').should.equal = 'name1 = \'name1\nname2 = \'name2\''
