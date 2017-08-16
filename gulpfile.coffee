$$ = require 'fire-keeper'
{$, _, Promise} = $$.library
co = Promise.coroutine

fs = require 'fs'
path = require 'path'

# task

###

  backup
  josh
  launchpad
  lint
  open
  ping
  seek
  sfacg

###

$$.task 'backup', co ->

  m = require './source/module/oneDrive.coffee'
  od = new m 'E:/OneDrive'

  yield od.backupGameSave()
  yield od.backup()

$$.task 'josh', co ->

  m = require './source/module/josh.coffee'
  josh = new m()

  yield josh.download()

$$.task 'lint', co ->

  yield $$.task('kokoro')()

  yield $$.lint [
    './gulpfile.coffee'
    './source/**/*.coffee'
  ]

$$.task 'open', co ->

  {name} = $$.argv

  m = require './source/module/open.coffee'
  open = new m()

  yield open.open name

$$.task 'ping', co ->

  m = require './source/module/ping.coffee'
  ping = new m()

  yield ping.ping()

$$.task 'seek', co ->

  {target} = $$.argv

  m = require './source/module/seeker.coffee'
  seeker = new m()

  yield seeker.seek target

$$.task 'sfacg', co ->

  {url} = $$.argv
  if !url then throw new Error 'invalid url'

  m = require './source/module/sfacg.coffee'
  sf = new m()

  yield sf.get url

$$.task 'shell', co  ->

  {cmd} = $$.argv
  if !cmd then throw new Error 'invalid cmd'

  m = require './source/module/shell.coffee'
  shell = new m()

  yield shell.execute cmd