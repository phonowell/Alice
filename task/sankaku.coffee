$ = require 'fire-keeper'
{_} = $

# return
module.exports = ->

  source = $.fn.normalizePath './source/module/sankaku.coffee'
  m = require source
  m = m()

  {target} = $.argv
  if !target
    return await m.executeList_()
  
  await m.execute_ target