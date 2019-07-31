$ = require 'fire-keeper'

# return
module.exports = ->
  
  m = $.require './source/module/image.coffee'
  m = m()

  {target} = $.argv()
  await m.execute_ target