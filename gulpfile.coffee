$$ = require 'fire-keeper'
{$, _, Promise} = $$.library
co = Promise.coroutine

fs = require 'fs'
path = require 'path'

# task

###

  backup
  josh
  lint
  prepare

###

$$.task 'backup', co ->

  # load
  yield $$.compile './data/data.yml'
  LIST = require './data/data.json'
  TARGET = 'E:/OneDrive/存档'

  # zip files
  for source in LIST

    if !fs.existsSync source then continue

    src = "#{source}/**/*.*"
    tar = "#{TARGET}/#{path.basename source}.zip"

    yield $$.remove tar
    yield $$.zip src, tar

  # backup OneDrive
  yield $$.remove 'E:/OneDrive.zip'
  yield $$.zip 'E:/OneDrive/**/*.*', 'E:/OneDrive.zip'

$$.task 'josh', co ->

  josh = require './source/module/josh.coffee'

  resourceList = yield josh.getResourceList()

    # download
#    return
#
#    for a in res
#
#      filename = path.basename a.src
#      if fs.existsSync "E:/OneDrive/midi/josh/#{a.title}/#{filename}" then continue
#
#      $.i a.src
#
#      continue
#
#      yield $$.download a.src
#      , "E:/OneDrive/midi/josh/#{a.title}"
#
#      #yield $$.delay 5e3

$$.task 'lint', co ->

  yield $$.task('kokoro')()

  yield $$.lint './gulpfile.coffee'