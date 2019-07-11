$ = require 'fire-keeper'

class M

  ###
  listIgnore

  check_(name)
  execute_()
  list_()
  ###

  listIgnore: [
    # 'dash'
    'iterm2'
    # 'onedrive'
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

    cmd = "brew cask reinstall #{listResult.join ' '}"
    await $.exec_ cmd

    @ # return

# return
module.exports = ->
  m = new M()
  await m.execute_()