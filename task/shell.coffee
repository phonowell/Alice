$ = require 'fire-keeper'
{_} = $

# return
module.exports = ->
  fn_ = $.fn.require './source/module/shell.coffee'
  await fn_()