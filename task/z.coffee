$ = require 'fire-keeper'

# return
module.exports = ->
  
  for source in await $.source_ './../*'

    await $.exec_ [
      "cd #{source}"
      'gulp kokoro'
    ]
