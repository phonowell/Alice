$$ = require 'fire-keeper'
{$, _, Promise} = $$.library
co = Promise.coroutine

fs = require 'fs'
path = require 'path'

# function

exclude = $$.fn.excludeInclude

$$.require = (name) ->
  require "./source/module/#{name}.coffee"

# task

###

  backup([target])
  daily()
  jpeg([action])
  josh()
  lint()
  list([target])
  reboot(host)
  seek([target])
  sfacg(url)
  shell([cmd])
  ssserver(host)

###

$$.task 'backup', co ->

  m = $$.require 'onedrive'
  od = new m()

  {target} = $$.argv
  if !target
    return $.info 'target', $$.fn.wrapList od.validTarget

  yield od.execute target

$$.task 'daily', co ->

  # listProject = [
  #   'alice'
  #   'bottle-fairies'
  #   'chika'
  #   'doremi'
  #   'fire-keeper'
  #   'gurumin'
  #   'kikyo'
  #   # 'kokoro' exclude this, do remember
  #   'potato'
  #   'sayori'
  #   # 'tamako' exclude this, do remember
  # ]

  # for item in listProject
  #   yield $$.shell [
  #     "cd ~/Project/#{item}"
  #     'gulp update'
  #   ]

  lines = [
    'brew update'
    'brew upgrade'
    'gulp shell --cmd launchpad'
    'gulp jpeg'
    'gulp backup --target onedrive'
  ]

  yield $$.shell lines

$$.task 'jpeg', co ->

  m = $$.require 'jpeg'
  jpeg = new m()

  {target} = $$.argv
  target or= 'auto'

  unless target in jpeg.validTarget
    $.info 'target', $$.fn.wrapList jpeg.validTarget
    throw new Error "invalid target <#{target}>"

  yield jpeg[target]()

$$.task 'josh', co ->

  m = $$.require 'josh'
  josh = new m()

  yield josh.download()

$$.task 'lint', co ->

  yield $$.task('kokoro')()

  yield $$.lint './danmaku.md'

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

$$.task 'reboot', co ->

  m = $$.require 'reboot'
  reboot = new m()

  {target} = $$.argv

  if !target
    $.info 'target', $$.fn.wrapList reboot.validTarget
    return

  unless target in reboot.validTarget
    $.info 'error', "invalid target <#{target}>"
    $.info 'target', $$.fn.wrapList reboot.validTarget
    return

  yield reboot.execute target

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

# $$.task 'z', co  ->