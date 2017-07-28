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
  sfacg
  sfacg-all

###

$$.task 'backup', co ->

  m = require './source/module/oneDrive.coffee'
  od = new m 'E:/OneDrive'

  yield od.backupGameSave()
  yield od.backup()

$$.task 'josh', co ->

  m = require './source/module/josh.coffee'
  josh = new m()

  resourceList = yield josh.getResourceList()
  yield josh.download resourceList, 'E:/midi'

$$.task 'lint', co ->

  yield $$.task('kokoro')()

  yield $$.lint './gulpfile.coffee'

$$.task 'sfacg', co ->

  {url} = $$.argv
  if !url then throw new Error 'invalid url'

  m = require './source/module/sfacg.coffee'
  sf = new m()

  yield sf.get url

$$.task 'sfacg-all', co ->

  m = require './source/module/sfacg.coffee'
  sf = new m()

  for i in [1e3...1e6]

    yield sf.get "http://book.sfacg.com/Novel/#{i}/MainIndex"