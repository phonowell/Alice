$ = require 'fire-keeper'

# return
module.exports = ->
  fn_ = $.require './source/module/lottery'
  await fn_()