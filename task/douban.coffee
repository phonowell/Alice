$ = require 'fire-keeper'

# return
module.exports = ->
  fn_ = $.require './source/module/douban.coffee'
  await fn_()