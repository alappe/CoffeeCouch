path = require 'path'
fs = require 'fs'

# Some Filesystem related methods should be grouped
# here in the future.
module.exports = class FilesystemUtilities
  # Convert given path to absolute path
  #
  # @param [String] pathname
  # @return [String]
  @abspath: (pathname) ->
    unless pathname[0] is '/'
      pathname = path.join process.cwd(), (path.normalize pathname)
    pathname
