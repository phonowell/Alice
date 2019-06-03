$ = require 'fire-keeper'

# return
module.exports = ->
  fn_ = $.fn.require './source/module/lottery.coffee'
  await fn_()
