fs = require 'fs'
path = require 'path'
Logger = require './Logger'

# Read in the configuration or provide sane default
# values if no configuration-file is found.
module.exports = class Configuration

  # Default values
  values:
    views: 'views'
    remotes: {}
    id: '_design/MyApp'
    lists: 'lists'
    revision: ''
    attachments: 'assets'

  configurationPath: undefined

  # Read the file if it exits
  constructor: ->
    @configurationPath = path.resolve '.coffeecouch'

    Logger.debug "Executing in #{@configurationPath}"
    try
      configFile = fs.readFileSync @configurationPath
      @fromFile configFile
    catch error
      if error.message.match /no valid/
        throw error
      else
        Logger.debug "No configuration file found in  #{@configurationPath}; using defaults…"

  # Set variables from configuration file…
  #
  # @param [String] fileContent
  fromFile: (fileContent) ->
    try
      configuration = JSON.parse fileContent
      for k, v of configuration
        Logger.debug "Configuration: Setting »#{k}« to »#{v}«"
        @values[k] = v
    catch error
      throw new Error 'Configuration file is no valid JSON!'

  # Stringify JSON configuration and write to file
  #
  # @param [Object] content
  toFile: (content) ->
    encodedContent = JSON.stringify content, null, '  '
    @writeFile @configurationPath, encodedContent
    Logger.debug "Written configuration to #{@configurationPath}"

  # Write file
  #
  # @param [String] pathAndFile
  # @param [String] content
  writeFile: (pathAndFile, content) ->
    try
      fs.writeFileSync pathAndFile, content
    catch error
      timestamp = +(new Date())
      filename = path.join '/tmp', "coffeecouch-#{timestamp}"
      @writeFile filename, content
      Logger.error "Configuration couldn't be saved to #{pathAndFile}. I tried to save a copy to #{filename}"
