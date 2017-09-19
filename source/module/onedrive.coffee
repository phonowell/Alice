# require

$$ = require 'fire-keeper'
{$, _, Promise} = $$.library
co = Promise.coroutine

path = require 'path'

# class

class OneDrive

  constructor: ->

    @base = switch $$.os
      when 'macos' then '~/OneDrive'
      when 'windows' then 'E:/OneDrive'
      else throw new Error 'invalid os'

    @validTarget = [
      'one', 'onedrive'
      'game'
    ]

  ###

    backup()
    backupGameSave()
    execute(target)

  ###

  backup: co ->
    yield $$.zip "#{@base}/**/*.*", "#{@base}/..", 'OneDrive.zip'

  backupGameSave: co ->

    if $$.os != 'windows'
      throw new Error "invalid os <#{$$.os}>"

    listSave = [
      '~/AppData/Roaming/DarkSoulsIII'
      '~/Documents/AliceSoft'
      '~/Documents/My Games/NieR_Automata'
    ]

    for pathSave in listSave

      unless yield $$.isExisted pathSave
        continue

      source = "#{pathSave}/**/*.*"
      target = "#{@base}/存档"
      filename = "#{path.basename pathSave}.zip"

      yield $$.zip source, target, filename

  execute: co (target) ->

    switch target.toLowerCase()

      when 'one', 'onedrive'
        yield @backup()

      when 'game'
        yield @backupGameSave()

      else throw new Error "invalid target <#{target}>"

# return
module.exports = (arg...) -> new OneDrive arg...
