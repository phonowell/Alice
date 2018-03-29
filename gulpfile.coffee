$$ = require 'fire-keeper'
{$, _} = $$.library

fs = require 'fs'
path = require 'path'

# function

exclude = $$.fn.excludeInclude

$$.require = (name) ->
  require "./source/module/#{name}.coffee"

$.do = (fn) ->

  unless $.isAsyncFunction fn
    throw new Error 'xxx'

  fn.then (res) -> [null, res]
  .catch (err) -> [err]

$.isAsyncFunction = (fn) ->
  Object::toString.call(fn) == '[object AsyncFunction]'

# task

###

alice()
backup([target])
check(target)
convert()
daily()
josh()
jpeg([action])
lint()
list([target])
seek([target])
sfacg(url)
shell([cmd])
ssserver(host)
upgrade()
wnacg()

###

$$.task 'alice', ->

  m = $$.require 'alice'
  alice = m()

  await alice.start()

$$.task 'backup', ->

  m = $$.require 'onedrive'
  od = m()

  {target} = $$.argv
  if !target
    return $.info 'target', $$.fn.wrapList od.validTarget

  await od.execute target

$$.task 'check', ->

  {target} = $$.argv
  if !target
    throw new Error 'empty target'

  if target == 'all'
    listSource = await $$.source [
      '../*'
      '!../alice'
    ]
    for source in listSource
      target = path.basename source
      await $$.shell [
        "gulp check --target #{target}"
      ]
    await $$.say 'mission completed'
    return

  base = "../#{target}"
  unless await $$.isExisted base
    throw new Error "invalid target <#{target}>"
  if target == 'alice'
    throw new Error "invalid target <#{target}>"

  # function
  check = (listSource, callback) ->

    listSource = await $$.source listSource

    for source in listSource
      await $$.replace source, (cont) ->
        _.trim callback cont

  # execute

  # pug & stylus
  await check [
    "#{base}/source/**/*.pug"
    "#{base}/source/**/*.styl"
  ], (cont) -> cont.replace /\n{3,}/g, '\n\n'

  # coffee
  await check [
    "#{base}/gulpfile.coffee"
    "#{base}/source/**/*.coffee"
    "#{base}/task/**/*.coffee"
    "#{base}/test/**/*.coffee"
  ], (cont) ->
    cont
    .replace /yield/g, 'await'
    .replace /\sco\s->/g, ' ->'
    .replace /\sco\s=>/g, ' =>'
    .replace /\sco\s\(/g, ' ('
    .replace /,\sPromise}/g, '}'
    .replace /co\s=\sPromise\.coroutine/g, ''
    .replace /\n{3,}/g, '\n\n'

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

  lines = switch $$.os

    when 'macos'

      [
        'brew update -v'
        'brew upgrade -v'
        'gulp shell --cmd launchpad'
        'gulp jpeg'
        'gulp backup --target onedrive'
      ]

    when 'windows'

      [
        'gulp backup --target game'
        'gulp jpeg'
        'gulp backup --target onedrive'
      ]

    else throw new Error "invalid os <#{$$.os}>"

  await $$.shell lines

  await $$.say 'Mission Completed'

$$.task 'josh', ->

  m = $$.require 'josh'
  josh = m()

  await josh.download()

$$.task 'jpeg', ->

  m = $$.require 'jpeg'
  jpeg = m()

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
  list = m()

  {target} = $$.argv
  if !target
    return $.info 'target', $$.fn.wrapList list.validTarget

  list.list target

$$.task 'seek', ->

  m = $$.require 'seeker'
  seeker = m()

  {target} = $$.argv

  await seeker.seek target

$$.task 'sfacg', ->

  m = $$.require 'sfacg'
  sf = m()

  {url} = $$.argv
  if !url then throw new Error 'invalid url'

  await sf.get url

$$.task 'shell', ->

  m = $$.require 'shell'
  shell = m()

  {cmd} = $$.argv
  if !cmd
    return $.info 'cmd', $$.fn.wrapList shell.validCmd

  await shell.execute cmd

$$.task 'sssserver', ->

  m = $$.require 'ssserver'
  ss = m()

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
  wnacg = m()

  await wnacg.execute()

$$.task 'upgrade', ->

  await $$.shell [
    'git stash'
    'git stash clear'
    'git pull'
    'npm update'
    'gulp prune'
  ]

$$.task 'x', ->

  listSource = await $$.source './node_modules/*'
  listRemove = []

  for source in listSource

    try fs.statSync source
    catch err then listRemove.push source

  await $$.remove listRemove

# $$.task 'y', ->

# $$.task 'z', ->