#!/usr/bin/env coffee

watch = require 'watch'
path = require 'path'
fs = require 'fs'

CoffeeCouch = require './CoffeeCouch'
#couchapp = require './main.coffee'

FilesystemUtilities = require './FilesystemUtilities'
Logger = require './Logger'
optimist = (require 'optimist')

options = [
    short: 'd'
    long: 'debug'
    demand: false
    describe: 'Enable debug mode'
    boolean: true
  ,
    short: 'h'
    long: 'help'
    demand: false
    describe: 'Show this help'
    boolean: true
  ,
    short: 'v'
    long: 'version'
    demand: false
    describe: 'Display version number'
    boolean: true
  ]

for option in options
  optimist = optimist.alias option.short, option.long
  optimist = optimist.demand option.short if option.demand
  optimist = optimist.boolean option.short if option.boolean
  optimist = optimist.describe option.short, option.describe
optimist.usage """
Usage:

  $0 [Options] <Command> <Parameters>

Command:

  push    Push the application to the given URL

  sync    Synchronize the remote revision id to the local one

  clone   TODO Clone an online application locally

  remote  Manage your remotes
"""

argv = optimist.argv

if argv.help
  console.log optimist.help()
  process.exit 1
if argv.debug
  Logger.level = 'debug'
  Logger.debug 'debug mode enabled…'
if argv.version
  console.log "insert code to show version here"

cc = new CoffeeCouch argv

#View = require './View.coffee'
#v = new View '/tmp/views/', 'test'
#doc =
#  views: {}
#doc.views[v.name] = v.code()
#console.log doc
# FIXME

# Create a boilerplace structure
#
# @param [String] app
#boiler = (app) ->
#  console.log "boiler with #{app}"
#  app = app || '.'
#  copytree (path.join __dirname, 'boiler'), (FilesystemUtilities.abspath app)

#if process.mainModule and process.mainModule.filename is __filename
#  node = process.argv.shift()
#  bin = process.argv.shift()
#  command = process.argv.shift()
#  app = process.argv.shift()
#  couch = process.argv.shift()
#
#  if command is 'help' or command is undefined
#    message = """
#      couchapp -- utility for creating couchapps
#
#      Usage:
#        couchapp <command> app.js http://localhost:5984/dbname
#
#      Commands:
#        push   : Push app once to server.
#        sync   : Push app then watch local files for changes.
#        boiler : Create a boiler project.
#    """
#    console.log message
#    process.exit()
#
#  if command is 'boiler'
#    boiler app
#  else
#    couchapp.createApp (require (FilesystemUtilities.abspath app)), couch, (app) ->
#      if command is 'push'
#        app.push()
#      else if command is 'sync'
#        #app.sync()
#        console.log "No sync yet…!"

  #exports.boilerDirectory = path.join __dirname, 'boiler'
