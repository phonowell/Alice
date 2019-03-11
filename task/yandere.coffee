$ = require 'fire-keeper'

# return
module.exports = ->
  fn_ = $.fn.require './source/module/yandere.coffee'
  await fn_()