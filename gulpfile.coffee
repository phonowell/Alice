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

  m = require './source/module/oneDrive.coffee'
  od = m 'E:/OneDrive'

  yield od.backupGameSave()
  yield od.backup()

$$.task 'josh', co ->

  m = require './source/module/josh.coffee'
  josh = new m()

  resourceList = yield josh.getResourceList()
  #yield josh.download resourceList, 'E:/midi'

$$.task 'lint', co ->

  yield $$.task('kokoro')()

  yield $$.lint './gulpfile.coffee'