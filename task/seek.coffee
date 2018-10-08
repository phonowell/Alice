$ = require 'fire-keeper'
{_} = $

# return
module.exports = ->

  source = $.fn.normalizePath './source/module/seeker.coffee'
  m = require source
  m = m()

  {target} = $.argv
  await m.execute_ target