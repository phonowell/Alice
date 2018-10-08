$ = require 'fire-keeper'
{_} = $

# return
module.exports = ->
  
  await $.task('kokoro')()

  await $.lint_ './danmaku.md'

  await $.lint_ [
    './gulpfile.coffee'
    './source/**/*.coffee'
  ]