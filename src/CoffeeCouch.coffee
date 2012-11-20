Logger = require './Logger'
Configuration = require './Configuration'
FilesystemUtilities = require './FilesystemUtilities'
View = require './View'
List = require './List'
Attachment = require './Attachment'
request = require 'request'

fs = require 'fs'
path = require 'path'

module.exports = class CoffeeCouch
  doc:
    _id: ''
    language: 'coffeescript'
    views: {}
    lists: {}
    rewrites: []
    _attachments: {}
    attachments_md5: {}

  # Initialize CoffeeCouch with the commandline options
  #
  # @param [Object] options
  constructor: (options) ->
    Logger.debug 'Intitializing CoffeeCouch'
    @configuration = new Configuration()
    @loadViews()
    @loadLists()
    @doc.rewrites = @loadRewrites()
    @addAttachments()
    @doc._id = @config 'id'
    @doc._rev = @config 'revision'

    # Option switching…
    switch options._[0]
      when 'push'
        throw Error unless options._[1]?
        @push options._[1]
      when 'sync'
        (throw new Error 'No remote given. Usage: coffeecouch sync <remote>') unless options._[1]?
        @sync options._[1]
      when 'remote'
        if options._[1]?
          switch options._[1]
            when 'show' then @showRemotes()
            when 'add'
              throw new Error 'You must provide a key and a host!' unless options._[2]? and options._[3]?
              @addRemote options._[2], options._[3]
            when 'rm', 'remote'
              throw new Error 'You must provide a key!' unless options._[2]?
              @removeRemote options._[2]
            else @showRemotes()
  
  # Show the saved remotes…
  showRemotes: ->
    console.log "Remotes:"
    for key,host of (@config 'remotes')
      console.log "#{key}:\t#{host}"

  # Add the given remote
  #
  # @param [String] key
  # @param [String] host
  addRemote: (key, host) ->
    Logger.debug "Add remote {#{key}:#{host}}"
    remotes = @config 'remotes'
    throw new Error "remote #{key} already set to #{remotes[key]}! Remove first…" if remotes[key]?
    remotes[key] = host
    @config 'remotes', remotes

  # Remove a given remote
  #
  # @param [String] key
  removeRemote: (key) ->
    console.log "Remove remote #{key}"
    Logger.debug "Remove remote #{key}"
    newRemotes = {}
    oldRemotes = @config 'remotes'
    for k,v of oldRemotes
      newRemotes[k] = v unless k is key
    @config 'remotes', newRemotes

  # Get or set the configuration for the given key
  #
  # @param [String] key
  # @param [String] value
  # @return [String] or undefined
  config: (key, value) ->
    if value?
      @configuration.values[key] = value
      @configuration.toFile @configuration.values
    else
      if @configuration.values[key]? then @configuration.values[key] else undefined

  # Load views
  loadViews: ->
    viewPath = @config 'views'
    views = fs.readdirSync viewPath
    views.forEach (directory) =>
      view = new View viewPath, directory
      viewName = directory.toLowerCase().replace /\W/g, '_'
      Logger.debug "Adding view #{viewName}"
      @doc.views[viewName] = view.code()

  # Load lists
  loadLists: ->
    listPath = @config 'lists'
    lists = fs.readdirSync listPath
    lists.forEach (directory) =>
      list = new List listPath, directory
      listName = directory.toLowerCase().replace /\W/, '_'
      Logger.debug "Add list #{listName}"
      @doc.lists[listName] = list.code()

  # Load rewrites
  #
  # Either return the rewrite list or null
  loadRewrites: ->
    result = []
    rewritePath = @config 'rewrites'
    rewrites = fs.readdirSync rewritePath
    rewrites.forEach (file) =>
      # do not read hidden files:
      unless (file.match /^\./)?
        obj = null
        filePath = path.join rewritePath, file
        try
          raw = fs.readFileSync filePath
        catch error
          throw new Error "Cannot read #{filePath}"
        try
          obj = JSON.parse raw.toString()
        catch error
          throw new Error "rewrites file »#{filePath}« is not valid JSON!"
        result = result.concat obj
    result

  # Synchronize the remote revision to the local configuration
  #
  # @param [String] remote (e.g. live, dev)
  sync: (remote) ->
    host = @getHost remote
    id = @config 'id'
    console.log "Synchronizing revision id on #{host}/#{id} to lokal"
    options =
      uri: "#{host}/#{id}"
      method: 'GET'
    request options, (error, response, body) =>
      throw error if error
      try
        doc = JSON.parse body
      if (@config 'revision') is doc._rev
        console.log "Revision already in sync: #{doc._rev}"
      else
        @config 'revision', doc._rev
        console.log "Revision updated to #{doc._rev}"

  # Push @doc to the remote indexed by key
  #
  # @param [String] remote
  push: (remote) ->
    host = @getHost remote
    console.log "Pushing #{@config 'revision'} to #{host}"
    #console.log @doc
    options =
      uri: host
      method: 'POST'
      json: @doc
    request options, (error, response, body) =>
      throw error if error
      throw new Error "Error pushing to #{remote}: #{body.error} – #{body.reason}" if (body.error? and body.reason?)
      @config 'revision', body.rev if body.ok and body.rev?

  # Return the host saved with the given remote key
  #
  # @param [String] key
  # @return [String]
  getHost: (key) ->
    remotes = @config 'remotes'
    throw new Error "no remote with key #{key} found!" unless remotes[key]?
    remotes[key]

  # Load attachments
  addAttachments: ->
    (@recursiveListing (@config 'attachments')).forEach (file) =>
      attachment = new Attachment file, (@config 'attachments'), ''
      @doc._attachments[attachment.getName()] = attachment.getObject (@config 'revision')

  # Add an attachment by reading the file in, calculating the md5 hash
  # and put both into @doc.
  #
  # @param [Attachment] attachment
  addAttachment: (attachment) -> @doc[attachment.path] = attachment.data

  # List all files in root recursively.
  #
  # @param [String] root
  # @return [Array]
  recursiveListing: (root) ->
    listing = []
    files = fs.readdirSync root
    for entry in files
      entryFullPath = path.join root, entry
      stat = fs.statSync entryFullPath
      if stat.isFile()
        # TODO Check what happens for dotFiles
        listing.push entryFullPath
      else if stat.isDirectory()
        listing = listing.concat @recursiveListing entryFullPath
    listing
