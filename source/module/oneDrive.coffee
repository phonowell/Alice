# require

$$ = require 'fire-keeper'
{$, _, Promise} = $$.library
co = Promise.coroutine

fs = require 'fs'
path = require 'path'

# function

absPath = (source) -> source.replace /\.\//, "#{process.cwd()}/"

# class

class OneDrive

  constructor: (@base) ->

    if !@base then throw new Error 'invalid base'

  ###

    backup()
    backupGameSave()

  ###

  backup: co ->
    yield $$.remove "#{@base}/../OneDrive.zip"
    yield $$.zip "#{@base}/**/*.*", "#{@base}/../OneDrive.zip"

  backupGameSave: co ->

    yield $$.compile './data/oneDrive/save.yaml'
    sourceList = require absPath './data/oneDrive/save.json'

    for source in sourceList

      if !fs.existsSync source then continue

      src = "#{source}/**/*.*"
      tar = "#{@base}/存档/#{path.basename source}.zip"

      yield $$.remove tar
      yield $$.zip src, tar

# return
module.exports = (arg...) -> new OneDrive arg...
