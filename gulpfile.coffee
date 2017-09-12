$$ = require 'fire-keeper'
{$, _, Promise} = $$.library
co = Promise.coroutine

fs = require 'fs'
path = require 'path'

# task

###

  backup([target])
  josh()
  lint()
  open(name)
  seek([target])
  sfacg(url)
  shell(cmd)
  upgrade()

###

$$.task 'backup', co ->

  {target} = $$.argv
  target or= 'OneDrive'

  m = require './source/module/onedrive.coffee'
  od = new m()

  switch target.toLowerCase()

    when 'one', 'onedrive'
      od.backup()

    when 'game'
      od.backupGameSave()

    else throw new Error "invalid target '#{target}'"

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

$$.task 'upgrade', co ->

  yield $$.shell [
    'git fetch'
    'git pull'
  ]

#$$.task 'z', co ->
