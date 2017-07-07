$$ = require 'fire-keeper'
{$, _, Promise, gulp} = $$.library
co = Promise.coroutine

fs = require 'fs'
path = require 'path'

# task

###

  backup
  lint

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

$$.task 'lint', co ->

  yield $$.task('kokoro')()

  yield $$.lint './gulpfile.coffee'