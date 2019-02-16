$ = require 'fire-keeper'
{_} = $

# return
module.exports = ->
  fn_ = $.fn.require './source/module/backup.coffee'
  await fn_()