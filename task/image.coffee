$ = require 'fire-keeper'
{_} = $

# return
module.exports = ->
  
  m = $.fn.require './source/module/image.coffee'
  m = m()

  {target} = $.argv
  await m.execute_ target