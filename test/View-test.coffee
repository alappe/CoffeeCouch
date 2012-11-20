assert = require 'should'
View = require '../src/View'

describe 'View', ->

  describe 'constructor', ->
    
    view = undefined

    beforeEach ->
      view = new View 'views/', 'myview'

    it 'sets name', ->
      view.name.should.equal 'myview'

    it 'sets viewPath to full path', ->
      view.viewPath.should.equal 'views/myview'

  describe 'code()', ->

    view = undefined
    beforeEach ->
      view = new View 'views/', 'myview'
      view.loadMap = ->
        'myMap'
      view.loadReduce = ->
        'myReduce'

    it 'returns object with map and reduce if both exists', ->
      obj = view.code()
      obj.map.should.equal 'myMap'
      obj.reduce.should.equal 'myReduce'

    it 'returns object with map if no reduce is found', ->
      view.loadReduce = -> undefined
      obj = view.code()
      obj.map.should.equal 'myMap'
      obj.should.not.have.property 'reduce'

  describe 'loadMap()', ->
    view = undefined
    beforeEach ->
      view = new View 'views/', 'myview'

    it 'should throw error if file is found', ->
      filePath = '/tmp/39838696893/myviews'
      try
        view.loadMap filePath
      catch error
        error.message.should.equal "Cannot read #{filePath}/map.coffee"

    it 'should throw error if map is invalid CoffeeScript', ->
      view.loadFile = -> 'var invalidCoffeeScript = 23;'
      filePath = '/tmp/39838696893/myviews'
      try
        view.loadMap filePath
      catch error
        error.message.should.equal "#{filePath}/map.coffee does not compile!"

    it 'should return formatted CoffeeScript', ->
      view.loadFile = ->
        """
name1 = 'name1'
name2 = "name2"
        """
      filePath = '/tmp/39838696893/myviews'
      (view.loadMap filePath).should.equal 'name1 = \'name1\'\nname2 = "name2"'

  describe 'loadReduce()', ->
    view = undefined
    beforeEach ->
      view = new View 'views', 'myview'

    it 'should not throw error if file is not found', ->
      try
        view.loadReduce '/tmp/03793983893/myviews'
      catch error
        should.fail 'no error expected!'

    it 'should throw error if reduce is invalid CoffeeScript', ->
      view.loadFile = -> 'var invalidCoffeeScript = 23;'
      filePath = '/tmp/03793983893/myviews'
      try
        view.loadReduce filePath
      catch error
        error.message.should.equal "#{filePath}/reduce.coffee does not compile!"

    it 'should return formatted CoffeeScript', ->
      view.loadFile = ->
        """
name1 = 'name1'
name2 = "name2"
        """
      filePath = '/tmp/39838696893/myviews'
      (view.loadReduce filePath).should.equal 'name1 = \'name1\'\nname2 = "name2"'
