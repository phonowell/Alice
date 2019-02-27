$ = require 'fire-keeper'

# return
module.exports = ->
  fn_ = $.fn.require './source/module/50on.coffee'
  await fn_()