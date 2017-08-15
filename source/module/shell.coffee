# require

$$ = require 'fire-keeper'
{$, _, Promise} = $$.library
co = Promise.coroutine

colors = require 'colors/safe'

# class

class Shell

  constructor: -> null

  ###

    execute(cmd)

  ###

  execute: co (cmd) ->

    if $$.os != 'macos'
      return $.info 'os', "invalid os <#{$$.os}>"

    yield $$.shell switch cmd.toLowerCase()

      when 'flushdns', 'dns'
        'sudo killall mDNSResponder'

      when 'resetlaunchpad', 'launchpad'
        'defaults write com.apple.dock ResetLaunchPad -bool true && killall Dock'

      else throw new Error 'invalid cmd'

# return
module.exports = (arg...) -> new Shell arg...