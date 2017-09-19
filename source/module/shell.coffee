# require

$$ = require 'fire-keeper'
{$, _, Promise} = $$.library
co = Promise.coroutine

# class

class Shell

  constructor: ->

    @validCmd = [
      'flushdns', 'dns'
      'resetlaunchpad', 'lanunchpad'
    ]

  ###

    execute(cmd)

  ###

  execute: co (cmd) ->

    lines = switch cmd.toLowerCase()

      when 'flushdns', 'dns'
        macos: 'sudo killall mDNSResponder'
        windows: null

      when 'resetlaunchpad', 'launchpad'
        macos: 'defaults write com.apple.dock ResetLaunchPad -bool true && killall Dock'
        windows: null

      else throw new Error 'invalid cmd'

    unless lines = lines[$$.os]
      return $.info 'os', "invalid os <#{$$.os}>"

    yield $$.shell lines

# return
module.exports = (arg...) -> new Shell arg...
