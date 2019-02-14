$ = require 'fire-keeper'
{_} = $

path = require 'path'

# return
module.exports = ->

  await $.remove_ '~/.Trash/**/*'