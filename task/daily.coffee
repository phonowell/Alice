$ = require 'fire-keeper'

# return
module.exports = ->
  
  mapLines =

    macos: [
      'brew update'
      'brew upgrade'
      # 'brew cask upgrade'
      'gulp image'
      'gulp backup --target OneDrive'
      'gulp clean --target trash'
    ]

    windows: [
      'gulp backup --target Game_Save'
      'gulp image'
      'gulp backup --target OneDrive'
    ]

  lines = mapLines[$.os]
  lines or throw new Error "invalid os '#{$.os}'"

  await $.chain $
  .exec_ lines,
    ignoreError: true
  .say_ 'Mission Completed'