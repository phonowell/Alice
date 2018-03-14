# require

$$ = require 'fire-keeper'
{$, _} = $$.library

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

  backup: ->
    await $$.zip "#{@base}/**/*.*"
    , "#{@base}/.."
    , 'OneDrive.zip'

  backupGameSave: ->

    if $$.os != 'windows'
      throw new Error "invalid os <#{$$.os}>"

    listSave = [
      '~/AppData/Roaming/DarkSoulsIII'
      '~/Documents/AliceSoft'
      '~/Documents/My Games/NieR_Automata'
    ]

    for pathSave in listSave

      unless await $$.isExisted pathSave
        continue

      source = "#{pathSave}/**/*.*"
      target = "#{@base}/存档"
      filename = "#{path.basename pathSave}.zip"

      await $$.zip source, target, filename

  execute: (target) ->

    switch target.toLowerCase()

      when 'one', 'onedrive'
        await @backup()

      when 'game'
        await @backupGameSave()

      else throw new Error "invalid target <#{target}>"

# return
module.exports = (arg...) -> new OneDrive arg...