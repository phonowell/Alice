# require

$ = require 'fire-keeper'
{_} = $
prompts = require 'prompts'

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
      choices: ({title: key, value: key} for key in _.keys @map)
      hint: '- Space to select. Return to submit.'
      message: 'select shell(s)'
      name: 'answer'
      type: 'multiselect'

    {answer} = await prompts option
    answer # return

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

      await $.shell_ lines

# return
module.exports = (arg...) -> new M arg...