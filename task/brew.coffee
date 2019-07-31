$ = require 'fire-keeper'

class M

  ###
  listIgnore

  check_(name)
  execute_()
  list_()
  ###

  listIgnore: [
    'iterm2'
  ]

  check_: (name) ->

    result = await $.exec_ "brew cask info #{name}"

    lines = result[1].split '\n'

    version = (lines[0].split ' ')[1].trim()

    unless ~lines[2].search version
      return true # outdated

    false # up-to-date

  list_: ->

    result = await $.exec_ 'brew cask list'

    lines = result[1].split '\n'

    lines # return

  execute_: ->

    list = await @list_()

    listResult = []
    for name in list

      if name in @listIgnore
        continue

      if await @check_ name
        listResult.push name

    unless listResult.length
      return @

    cmd = "brew cask reinstall #{listResult.join ' '}"
    await $.exec_ cmd

    @ # return

module.exports = ->

  unless $.os 'macos'
    throw new Error "invalid os '#{$.os()}'"

  await $.exec_ [
    'brew update'
    'brew upgrade'
    'brew cask upgrade'
  ]

  m = new M()
  await m.execute_()