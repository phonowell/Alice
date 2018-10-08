$ = require 'fire-keeper'
{_} = $

# return
module.exports = ->
  
  mapLines =

    macos: [
      'brew update -v'
      'brew upgrade -v'
      'gulp shell --target resetlaunchpad'
      'gulp image'
      'gulp backup --target onedrive'
    ]

    windows: [
      'gulp backup --target gamesave'
      'gulp image'
      'gulp backup --target onedrive'
    ]

  lines = mapLines[$.os] or throw new Error "invalid os '#{$.os}'"

  await $.shell_ lines
  await $.say_ 'Mission Completed'