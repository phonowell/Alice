$ = require 'fire-keeper'
{_} = $

# return
module.exports = ->

  m = $.fn.require './source/module/sankaku.coffee'
  m = m()

  {target} = $.argv
  unless target
    return await m.executeList_()
  
  await m.execute_ target