$ = require 'fire-keeper'

# return
module.exports = ->
  fn_ = $.require './source/module/lottery.coffee'
  await fn_()