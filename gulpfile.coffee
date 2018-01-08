$$ = require 'fire-keeper'
{$, _} = $$.library

fs = require 'fs'
path = require 'path'

# function

exclude = $$.fn.excludeInclude

$$.require = (name) ->
  require "./source/module/#{name}.coffee"

# task

###

alice()
backup([target])
convert()
daily()
josh()
jpeg([action])
lint()
list([target])
reboot(host)
seek([target])
sfacg(url)
shell([cmd])
ssserver(host)
upgrade()
upgrade()
wnacg()

###

$$.task 'alice', ->

  m = $$.require 'alice'
  alice = new m()

  await alice.start()

$$.task 'backup', ->

  m = $$.require 'onedrive'
  od = new m()

  {target} = $$.argv
  if !target
    return $.info 'target', $$.fn.wrapList od.validTarget

  await od.execute target

$$.task 'convert', ->

  iconv = require 'iconv-lite'

  listSource = await $$.source '~/Download/*.txt'

  for source in listSource

    text = await $$.read source
    if ~text.search /[的一是了我不人在他有这个上们来到时，。]/
      continue

    buffer = fs.readFileSync source
    text = iconv.decode buffer, 'gbk'

    await $$.write source, text

$$.task 'daily', ->

  lines = [
    'brew update -v'
    'brew upgrade -v'
    'gulp shell --cmd launchpad'
    'gulp jpeg'
    'gulp backup --target onedrive'
  ]

  await $$.shell lines

  await $$.say 'Mission Completed'

$$.task 'josh', ->

  m = $$.require 'josh'
  josh = new m()

  await josh.download()

$$.task 'jpeg', ->

  m = $$.require 'jpeg'
  jpeg = new m()

  {target} = $$.argv
  target or= 'auto'

  unless target in jpeg.validTarget
    $.info 'target', $$.fn.wrapList jpeg.validTarget
    throw new Error "invalid target <#{target}>"

  await jpeg[target]()

$$.task 'lint', ->

  await $$.task('kokoro')()

  await $$.lint './danmaku.md'

  await $$.lint [
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

$$.task 'reboot', ->

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

  await reboot.execute target

$$.task 'seek', ->

  m = $$.require 'seeker'
  seeker = new m()

  {target} = $$.argv

  await seeker.seek target

$$.task 'sfacg', ->

  m = $$.require 'sfacg'
  sf = new m()

  {url} = $$.argv
  if !url then throw new Error 'invalid url'

  await sf.get url

$$.task 'shell', ->

  m = $$.require 'shell'
  shell = new m()

  {cmd} = $$.argv
  if !cmd
    return $.info 'cmd', $$.fn.wrapList shell.validCmd

  await shell.execute cmd

$$.task 'sssserver', ->

  m = $$.require 'ssserver'
  ss = new m()

  {host} = $$.argv
  if !host
    throw new Error 'empty host'

  await ss.execute host

$$.task 'upgrade', ->

  await $$.shell [
    'git fetch'
    'gulp update'
  ]

$$.task 'wnacg', ->

  m = $$.require 'wnacg'
  wnacg = new m()

  await wnacg.execute()

$$.task 'upgrade', ->

  await $$.shell [
    'git stash'
    'git stash clear'
    'git pull'
    'npm update'
    'gulp prune'
  ]

$$.task 'z', ->

  base = '../tamako'

  listSource = await $$.source [
    "#{base}/gulpfile.coffee"
    "#{base}/source/**/*.coffee"
    "#{base}/test/**/*.coffee"
  ]

  for source in listSource

    cont = $.parseString await $$.read source

    res = cont
    .replace /await/g, 'await'
    .replace /\sco\s->/g, ' ->'
    .replace /\sco\s=>/g, ' =>'
    .replace /\sco\s\(/g, ' ('
    .replace /,\sPromise}/g, '}'
    .replace /co\s=\sPromise\.coroutine/g, ''
    .replace /\n{3,}/g, '\n\n'

    if res == cont
      continue

    await $$.write source, res