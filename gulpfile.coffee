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
  jpeg([action])
  josh()
  lint()
  list([target])
  seek([target])
  sfacg(url)
  shell([cmd])
  ssserver(host)
  upgrade()

###

$$.task 'backup', co ->

  m = $$.require 'onedrive'
  od = new m()

  {target} = $$.argv
  if !target
    return $.info 'target', $$.fn.wrapList od.validTarget

  yield od.execute target

$$.task 'jpeg', co ->

  m = $$.require 'jpeg'
  jpeg = new m()

  {action} = $$.argv
  action or= 'auto'

  unless action in jpeg.validAction
    $.info 'action', $$.fn.wrapList jpeg.validAction
    throw new Error "invalid action <#{action}>"

  yield jpeg[action]()

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

$$.task 'shell', co ->

  m = $$.require 'shell'
  shell = new m()

  {cmd} = $$.argv
  if !cmd
    return $.info 'cmd', $$.fn.wrapList shell.validCmd

  yield shell.execute cmd

$$.task 'sssserver', co ->

  m = $$.require 'ssserver'
  ss = new m()

  {host} = $$.argv
  if !host
    throw new Error 'empty host'

  yield ss.execute host

$$.task 'upgrade', co ->

  yield $$.shell [
    'git fetch'
    'git pull'
    'npm update'
  ]

#$$.task 'y', ->

#$$.task 'z', co ->
