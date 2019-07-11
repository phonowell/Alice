$ = require 'fire-keeper'

# return
module.exports = ->
  
  m = $.require './source/module/image'
  m = m()

  {target} = $.argv()
  await m.execute_ target