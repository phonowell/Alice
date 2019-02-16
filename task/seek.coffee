$ = require 'fire-keeper'
{_} = $

# return
module.exports = ->
  fn_ = $.fn.require './source/module/seeker.coffee'
  await fn_()