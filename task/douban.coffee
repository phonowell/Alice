$ = require 'fire-keeper'

# return
module.exports = ->
  fn_ = $.fn.require './source/module/douban.coffee'
  await fn_()
