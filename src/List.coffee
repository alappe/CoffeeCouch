path = require 'path'
CouchDBFunctions = require './CouchDBFunctions'

module.exports = class List extends CouchDBFunctions

  list: undefined

  # Find list file, load it. parse for validity
  #
  # @param [String] listPath
  # @param [String] listName
  constructor: (listRootPath, @name) ->
    @listPath = path.join listRootPath, name

  # Load a list.coffee if it exits – otherwise do nothing
  #
  # @param [String] listPath
  # @return [Mixed] String or undefined
  loadList: (listPath) ->
    listPath = path.join listPath, 'list.coffee'
    coffeeList = undefined
    try
      coffeeList = @loadFile listPath
      unless @lintCoffeeScript coffeeList
        throw new Error "#{listPath} does not compile!"
      coffeeList = @formatCoffeeScript coffeeList
    catch error
      throw error if (error.message.match /compile/)?
      # No problem, list is optional…
    coffeeList

  # Get list code
  #
  # @return [Object]
  code: ->
    @list = @loadList @listPath unless @list?
    @list
