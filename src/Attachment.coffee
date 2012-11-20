crypto = require 'crypto'
Mimetypes = require './Mimetypes'
path = require 'path'
fs = require 'fs'

###
# Attachment
###
module.exports = class Attachment

  data: undefined
  dataBase64: undefined
  md5: undefined
  mime: undefined

  # @param [String] @absolutePath
  # @param [String] @root
  # @param [String] prefix
  constructor: (@absolutePath, @root, prefix) ->
    @prefix = prefix || ''
    @path = (@absolutePath.replace @root, @prefix).replace /\\/g, '/'
    @path = @path.slice 1 if @path[0] is '/'

  # Read in the file
  #
  # @return [Buffer]
  readFile: ->
    try
      @data = fs.readFileSync @absolutePath
    catch error
      #throw error
      console.log "Can't read file #{@absolutePath}"

  # Return @data as base64
  #
  # @return [String]
  getDataBase64: ->
    @readFile() unless @data?
    @data.toString 'base64'

  # Return the mimetype of the file
  #
  # @return [String]
  getMimetype: ->
    @readFile() unless @data?
    unless @mime?
      @mime = Mimetypes.lookup (path.extname @absolutePath).slice 1
    @mime

  # Get the md5-hash
  # 
  # @return [String]
  getMd5Hash: ->
    @readFile() unless @data?
    unless @md5?
      md5 = crypto.createHash 'md5'
      md5.update @getDataBase64()
      @md5 = md5.digest 'hex'
    @md5

  # Get the path and name of this attachment
  #
  # @return [String]
  getName: -> @absolutePath

  # Return the attachment-object that should be pushed
  # to the database
  #
  # FIXME TODO Rename…
  #
  # @param [String] revision
  # @return [Object]
  getObject: (revision) ->
    @readFile() unless @data?
    revpos = parseInt (revision.replace /^(\d+)-.*$/, '$1'), 10
    obj =
      content_type: @getMimetype()
      digest: "md5-#{@getMd5Hash()}"
      revpos: revpos
      data: @getDataBase64()
