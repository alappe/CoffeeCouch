path = require 'path'
CouchDBFunctions = require './CouchDBFunctions'

module.exports = class View extends CouchDBFunctions

  # Find map and reduce files, load them, parse for validity
  #
  # @param [String] viewPath
  # @param [String] viewName
  constructor: (viewRootPath, @name) ->
    @viewPath = path.join viewRootPath, name
    #@map = @loadMap viewPath
    #@reduce = @loadReduce viewPath
  
  # Load a map.coffee if it exists – otherwise throw an error
  #
  # @param [String] viewPath
  # @return [String]
  loadMap: (viewPath) ->
    mapPath = path.join viewPath, 'map.coffee'
    coffeeMap = @loadFile mapPath
    unless @lintCoffeeScript coffeeMap
      throw new Error "#{mapPath} does not compile!"
    @formatCoffeeScript coffeeMap

  # Load a reduce.coffee if it exists – otherwise do nothing
  #
  # @param [String] viewPath
  # @return [Mixed] String or undefined
  loadReduce: (viewPath) ->
    reducePath = path.join viewPath, 'reduce.coffee'
    coffeeReduce = undefined
    try
      coffeeReduce = @loadFile reducePath
      unless @lintCoffeeScript @coffeeReduce
        throw new Error "#{path} does not compile!"
      coffeeReduce = @formatCoffeeScript coffeeReduce
    catch error
      # No problem, reduce is optional…
    coffeeReduce

  # Get view code
  #
  # @return [Object]
  code: ->
    map =  @loadMap @viewPath
    reduce = @loadReduce @viewPath
    code = map: map
    code.reduce = reduce if reduce?
    code
