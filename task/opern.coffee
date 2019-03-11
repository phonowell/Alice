$ = require 'fire-keeper'

# return
module.exports = ->
  fn_ = $.fn.require './source/module/opern.coffee'
  await fn_()