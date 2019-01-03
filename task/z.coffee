$ = require 'fire-keeper'
{_} = $

path = require 'path'

# return
module.exports = ->

  a = await $.prompt
    type: 'text'
    timeout: 1e3