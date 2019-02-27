$ = require 'fire-keeper'

# return
module.exports = ->
  
  mapLines =

    macos: [
      'brew update -v'
      'brew upgrade -v'
      'gulp image'
      'gulp backup --target OneDrive'
      'gulp clean --target trash'
    ]

    windows: [
      'gulp backup --target Game_Save'
      'gulp image'
      'gulp backup --target OneDrive'
    ]

  lines = mapLines[$.os] or throw new Error "invalid os '#{$.os}'"

  await $.exec_ lines
  await $.say_ 'Mission Completed'