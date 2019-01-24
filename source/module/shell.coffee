$ = require 'fire-keeper'
{_} = $

# class

class M

  ###
  map
  ###

  map:

    flushdns:
      macos: 'sudo killall mDNSResponder'

    resetlaunchpad:
      macos: [
        'defaults write com.apple.dock ResetLaunchPad -bool true'
        'killall Dock'
      ]

    'ssh-add':
      macos: [
        'ssh-add -D'
        'cd ~/OneDrive/密钥/Anitama'
        'ssh-add anitama'
        'ssh-add anitama_cn'
        'ssh-add anitama_l'
        'ssh-add cspg'
        'ssh-add deploy'
        'ssh-add -l'
      ]

  ###
  ask_()
  execute_(cmd)
  ###

  ask_: ->

    option =
      type: 'select'
      message: 'select cmd'
      hint: '- Space to select. Return to submit.'
      choices: (key for key in _.keys @map)

    await $.prompt option

  execute_: (cmd) ->

    listCmd = cmd or await @ask_()

    if $.type(listCmd) != 'array'
      listCmd = [listCmd]

    for cmd in listCmd
      cmd = cmd.toLowerCase()

      item = @map[cmd]
      if !item then throw new Error "invalid command '#{cmd}'"
      
      lines = item[$.os]
      if !lines then throw new Error "invalid os '#{$.os}'"

      await $.exec_ lines

# return
module.exports = (arg...) -> new M arg...