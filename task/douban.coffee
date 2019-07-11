$ = require 'fire-keeper'

# return
module.exports = ->
  fn_ = $.require './source/module/douban'
  await fn_()