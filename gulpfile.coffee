$ = require 'fire-keeper'
{_} = $

fs = require 'fs'
path = require 'path'

# function

###
exclude()

do_(name)
require(name)
###

exclude = $.fn.excludeInclude

$.do_ = (name) ->
  m = $.require name
  m = m()
  
  {target} = $.argv
  await m.execute_ target

$.require = (name) ->
  require "./source/module/#{name}.coffee"

# task

###
alice()
backup([target])
check(target)
daily()
image()
lint()
sankaku(target)
seek([target])
shell([cmd])
upgrade()
###

$.task 'alice', ->

  m = $.require 'alice'
  alice = m()

  await alice.start()

$.task 'backup', -> await $.do_ 'backup'

$.task 'check', ->

  {target} = $.argv
  if !target
    throw new Error 'empty target'

  if target == 'all'
    listSource = await $.source_ [
      '../*'
      '!../alice'
    ]
    for source in listSource
      target = path.basename source
      await $.shell_ [
        "gulp check --target #{target}"
      ]
    await $.say_ 'mission completed'
    return

  base = "../#{target}"
  unless await $.isExisted_ base
    throw new Error "invalid target <#{target}>"
  if target == 'alice'
    throw new Error "invalid target <#{target}>"

  # function
  check_ = (listSource, callback) ->

    listSource = await $.source_ listSource

    for source in listSource
      await $.replace_ source, (cont) ->
        _.trim callback cont

  # execute

  # pug & stylus
  await check_ [
    "#{base}/source/**/*.pug"
    "#{base}/source/**/*.styl"
  ], (cont) -> cont.replace /\n{3,}/g, '\n\n'

  # coffee
  await check_ [
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
      'gulp shell --target resetlaunchpad'
      'gulp image'
      'gulp backup --target onedrive'
    ]

    windows: [
      'gulp backup --target gamesave'
      'gulp image'
      'gulp backup --target onedrive'
    ]

  lines = mapLines[$.os] or throw new Error "invalid os '#{$.os}'"

  await $.shell_ lines
  await $.say_ 'Mission Completed'

$.task 'image', ->

  m = $.require 'image'
  image = m()

  await image.execute_()

$.task 'lint', ->

  await $.task('kokoro')()

  await $.lint_ './danmaku.md'

  await $.lint_ [
    './gulpfile.coffee'
    './source/**/*.coffee'
  ]

$.task 'sankaku', ->

  m = $.require 'sankaku'
  sankaku = m()

  {target} = $.argv
  if !target
    return await sankaku.executeList_()
  
  await sankaku.execute_ target

$.task 'seek', -> await $.do_ 'seeker'

$.task 'shell', -> await $.do_ 'shell'

$.task 'upgrade', ->

  await $.shell_ [
    'git stash'
    'git stash clear'
    'git pull'
    'npm update'
    'gulp prune'
  ]

$.task 'z', ->

  pathGulpfile = '../sakura/gulpfile.coffee'

  await $.replace_ pathGulpfile, /\$\.([^\s\(]+)/g, (s, string) ->
    
    listKey = [
      'backup'
      'compile'
      'copy'
      'delay'
      'download'
      'isExisted'
      'isSame'
      'link'
      'lint'
      'mkdir'
      'move'
      'read'
      'recover'
      'remove'
      'rename'
      'replace'
      'say'
      'shell'
      'source'
      'ssh.connect'
      'ssh.disconnect'
      'ssh.mkdir'
      'ssh.remove'
      'ssh.shell'
      'ssh.upload'
      'stat'
      'unzip'
      'update'
      'walk'
      'write'
      'zip'
    ]

    unless string in listKey
      return s

    "$.#{_.trim string, '_'}_"