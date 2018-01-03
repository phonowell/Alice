# require

$$ = require 'fire-keeper'
{$, _} = $$.library

# class

class Shell

  constructor: ->

    @validCmd = [
      'flushdns', 'dns'
      'resetlaunchpad', 'lanunchpad'
      'ssh-add'
    ]

  ###

    execute(cmd)

  ###

  execute: (cmd) ->

    lines = switch cmd.toLowerCase()

      when 'flushdns', 'dns'
        macos: 'sudo killall mDNSResponder'

      when 'resetlaunchpad', 'launchpad'
        macos: [
          'defaults write com.apple.dock ResetLaunchPad -bool true'
          'killall Dock'
        ]

      when 'ssh-add'
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

      else throw new Error 'invalid cmd'

    unless lines = lines[$$.os]
      return $.info 'os', "invalid os <#{$$.os}>"

    await $$.shell lines

# return
module.exports = (arg...) -> new Shell arg...