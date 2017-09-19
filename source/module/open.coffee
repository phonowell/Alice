# require

$$ = require 'fire-keeper'
{$, _, Promise} = $$.library
co = Promise.coroutine

# class

class Open

  constructor: ->

    @validTarget = [
      'github'
      'npm'
      'onedrive'
      'wechat'
    ]

  ###

    open(name)

  ###

  open: co (name) ->

    if !name
      throw new Error 'empty name'

    url = switch name.toLowerCase()

      when 'github' then 'https://github.com/phonowell/'
      when 'npm' then 'https://www.npmjs.com/~phonowell'
      when 'onedrive' then 'https://onedrive.live.com/'
      when 'wechat' then 'https://wx2.qq.com/'

      else throw new Error "invalid name <#{name}>"

    method = switch $$.os
      when 'macos' then 'open'
      when 'windows' then 'start'
      else throw new Error "invalid os <#{$$.os}>"

    yield $$.shell "#{method} #{url}"

# return
module.exports = (arg...) -> new Open arg...
