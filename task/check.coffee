$ = require 'fire-keeper'
{_} = $

path = require 'path'

# return
module.exports = ->
  
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