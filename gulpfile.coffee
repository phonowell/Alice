$ = require 'fire-keeper'
{_} = $.library

fs = require 'fs'
path = require 'path'

# function

exclude = $.fn.excludeInclude

$.require = (name) ->
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
daily()
image()
lint()
list([target])
seek([target])
shell([cmd])
ssserver(host)
upgrade()
wnacg()
###

$.task 'alice', ->

  m = $.require 'alice'
  alice = m()

  await alice.start()

$.task 'backup', ->

  m = $.require 'onedrive'
  od = m()

  {target} = $.argv
  if !target
    return $.info 'target', $.fn.wrapList od.validTarget

  await od.execute target

$.task 'check', ->

  {target} = $.argv
  if !target
    throw new Error 'empty target'

  if target == 'all'
    listSource = await $.source [
      '../*'
      '!../alice'
    ]
    for source in listSource
      target = path.basename source
      await $.shell [
        "gulp check --target #{target}"
      ]
    await $.say 'mission completed'
    return

  base = "../#{target}"
  unless await $.isExisted base
    throw new Error "invalid target <#{target}>"
  if target == 'alice'
    throw new Error "invalid target <#{target}>"

  # function
  check = (listSource, callback) ->

    listSource = await $.source listSource

    for source in listSource
      await $.replace source, (cont) ->
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

$.task 'daily', ->

  mapLines =

    macos: [
      'brew update -v'
      'brew upgrade -v'
      'gulp shell --cmd launchpad'
      'gulp image'
      'gulp backup --target onedrive'
    ]

    windows: [
      'gulp backup --target game'
      'gulp image'
      'gulp backup --target onedrive'
    ]

  lines = mapLines[$.os] or throw new Error "invalid os '#{$.os}'"

  await $.shell lines
  await $.say 'Mission Completed'

$.task 'image', ->

  m = $.require 'image'
  image = m()

  await image.execute_()

$.task 'lint', ->

  await $.task('kokoro')()

  await $.lint './danmaku.md'

  await $.lint [
    './gulpfile.coffee'
    './source/**/*.coffee'
  ]

$.task 'list', ->

  m = $.require 'list'
  list = m()

  {target} = $.argv
  if !target
    return $.info 'target', $.fn.wrapList list.validTarget

  list.list target

$.task 'seek', ->

  m = $.require 'seeker'
  seeker = m()

  {target} = $.argv
  await seeker.execute_ target

$.task 'shell', ->

  m = $.require 'shell'
  shell = m()

  {cmd} = $.argv
  if !cmd
    return $.info 'cmd', $.fn.wrapList shell.validCmd

  await shell.execute cmd

$.task 'sssserver', ->

  m = $.require 'ssserver'
  ss = m()

  {host} = $.argv
  if !host
    throw new Error 'empty host'

  await ss.execute host

$.task 'wnacg', ->

  m = $.require 'wnacg'
  wnacg = m()

  await wnacg.execute()

$.task 'upgrade', ->

  await $.shell [
    'git stash'
    'git stash clear'
    'git pull'
    'npm update'
    'gulp prune'
  ]

$.task 'x', ->

  listSource = await $.source '../*'
  listCmd = []

  for source in listSource

    pkg = "#{source}/package.json"
    pkg = await $.read pkg

    if !pkg then continue

    version = _.get pkg, 'dependencies.fire-keeper'
    version or= _.get pkg, 'devDependencies.fire-keeper'

    if !version then continue

    listCmd.push "cd #{source}"
    listCmd.push 'gulp update'

  # return $.i listCmd
  await $.shell listCmd
  await $.say 'mission completed'

$.task 'z', ->

  jimp = require 'jimp'

  await $.remove '~/Downloads/channel-new'

  listSource = await $.source '~/Downloads/channel/*.png'

  for source in listSource

    target = source.toLowerCase()
    # .replace /\s+/g, '-'
    .replace /downloads\/channel/, 'Downloads/channel-new'
    .replace /\.png/, '.jpg'

    img = await jimp.read source
    # img.scale 128 / 154
    img.rotate 90
    img.write target