$ = require 'fire-keeper'

# return
module.exports = ->
  
  mapLines =

    macos: [
      'gulp brew'
      'gulp image'
      'gulp backup --target OneDrive'
      'gulp clean --target trash'
    ]

    windows: [
      'gulp backup --target Game_Save'
      'gulp image'
      'gulp backup --target OneDrive'
    ]

  lines = mapLines[$.os()]
  lines or throw new Error "invalid os '#{$.os()}'"

  await $.exec_ lines,
    ignoreError: true
  
  await $.say_ 'Mission Completed'