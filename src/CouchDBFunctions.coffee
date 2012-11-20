fs = require 'fs'
coffeeScript = require 'coffee-script'

# Class for view/list/show functions to inherit from
module.exports = class CouchDBFunctions

  # Compile the given file from CoffeeScript to JavaScript
  # to lint the file…
  #
  # @param [String] coffeeSource
  # @return [Boolean]
  lintCoffeeScript: (coffeeSource) ->
    valid = true
    try
      js = coffeeScript.compile coffeeSource
    catch error
      valid = false
    valid

  # @param [String] coffeeSource
  # @return [String] reduced to one line
  formatCoffeeScript: (coffeeSource) -> coffeeSource.replace /\n/g, '\n'

  # Load a give file
  #
  # @param [String] filePath
  # @return [String]
  loadFile: (filePath) ->
    try
      fileBuffer = fs.readFileSync filePath
      fileBuffer.toString()
    catch error
      error.message = "Cannot read #{filePath}"
      throw error
