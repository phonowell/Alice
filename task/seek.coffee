$ = require 'fire-keeper'

# return
module.exports = ->
  fn_ = $.require './source/module/seeker'
  await fn_()