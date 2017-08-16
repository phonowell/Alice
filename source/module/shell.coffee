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

    lines = switch cmd.toLowerCase()

      when 'flushdns', 'dns'
        macos: 'sudo killall mDNSResponder'
        windows: null

      when 'resetlaunchpad', 'launchpad'
        macos: 'defaults write com.apple.dock ResetLaunchPad -bool true && killall Dock'
        windows: null

      when 'wechat'
        macos: 'open https://wx2.qq.com'
        windows: 'start https://wx2.qq.com'

      else throw new Error 'invalid cmd'

    unless lines = lines[$$.os]
      return $.info 'os', "invalid os <#{$$.os}>"

    yield $$.shell lines

# return
module.exports = (arg...) -> new Shell arg...