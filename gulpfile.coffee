$$ = require 'fire-keeper'
{$, _, Promise} = $$.library
co = Promise.coroutine

fs = require 'fs'
path = require 'path'

# function

$$.require = (name) ->
  require "./source/module/#{name}.coffee"

# task

###

  backup([target])
  josh()
  lint()
  list([target])
  open([target])
  seek([target])
  sfacg(url)
  shell([cmd])
  upgrade()

###

$$.task 'backup', co ->

  m = $$.require 'onedrive'
  od = new m()

  {target} = $$.argv
  if !target
    return $.info 'target', $$.fn.wrapList od.validTarget

  yield od.execute target

$$.task 'josh', co ->

  m = $$.require 'josh'
  josh = new m()

  yield josh.download()

$$.task 'lint', co ->

  yield $$.task('kokoro')()

  yield $$.lint [
    './gulpfile.coffee'
    './source/**/*.coffee'
  ]

$$.task 'list', ->

  m = $$.require 'list'
  list = new m()

  {target} = $$.argv
  if !target
    return $.info 'target', $$.fn.wrapList list.validTarget

  list.list target

$$.task 'open', co ->

  m = $$.require 'open'
  open = new m()

  {target} = $$.argv
  if !target
    return $.info 'target', $$.fn.wrapList open.validTarget

  yield open.open target

$$.task 'seek', co ->

  m = $$.require 'seeker'
  seeker = new m()

  {target} = $$.argv

  yield seeker.seek target

$$.task 'sfacg', co ->

  m = $$.require 'sfacg'
  sf = new m()

  {url} = $$.argv
  if !url then throw new Error 'invalid url'

  yield sf.get url

$$.task 'shell', co  ->

  m = $$.require 'shell'
  shell = new m()

  {cmd} = $$.argv
  if !cmd
    return $.info 'cmd', $$.fn.wrapList shell.validCmd

  yield shell.execute cmd

$$.task 'upgrade', co ->

  yield $$.shell [
    'git fetch'
    'git pull'
  ]

#$$.task 'z', co ->
