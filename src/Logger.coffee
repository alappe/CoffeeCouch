# Simple Logger class to have debug, info and error output
# depending on the configured level. If level is set to 'quiet'
# the Logger does not output a word…
module.exports = class Logger

  # The debug-level…
  @level: 'quiet'

  # Write an info message
  #
  # @param [String] message
  @info: (message) -> console.log message if Logger.level is 'info' or Logger.level is 'debug'

  # Write a debug message
  #
  # @param [String] message
  @debug: (message) -> console.log message if Logger.level is 'debug'

  # Write an error message and quit with error-code 1
  #
  # @param [String] message
  @error: (message) ->
    console.log message
    process.exit 1
