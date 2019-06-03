$ = require 'fire-keeper'

# return
module.exports = ->
  fn_ = $.fn.require './source/module/seeker.coffee'
  await fn_()
