$ = require 'fire-keeper'

# return
module.exports = ->
  
  # await $.task('kokoro')()

  await $.lint_ [
    './danmaku.md'
    './gulpfile.coffee'
    './source/**/*.coffee'
    './task/**/*.coffee'
    './test/**/*.coffee'
  ]