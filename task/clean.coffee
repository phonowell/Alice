$ = require 'fire-keeper'
{_} = $

# return
module.exports = ->
  fn_ = $.fn.require './source/module/cleaner.coffee'
  await fn_()