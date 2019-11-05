$ = require 'fire-keeper'

class M

  ###
  map
  pathStorage
  ---
  ask_()
  backupGameSave_()
  backupOneDrive_()
  execute_()
  ###

  map:
    'Game Save': 'backupGameSave_'
    'OneDrive': 'backupOneDrive_'

  pathStorage: do ->

    map =
      macos: '~/OneDrive'
      windows: 'E:/OneDrive'
    os = $.os()

    map[os] or throw new Error "invalid os '#{os}'"

  ask_: ->

    {target} = $.argv()
    listTarget = (key for key, value of @map)

    target or= await $.prompt_
      type: 'autocomplete'
      message: 'input'
      list: listTarget

    target = target
    .replace /_/g, ' '

    unless target in listTarget
      throw new Error "invalid target '#{target}'"

    unless method = @map[target]
      throw new Error "invalid target '#{target}'"

    method # return

  backupGameSave_: ->

    unless $.os 'windows'
      $.info 'warning', "invalid os '#{$.os()}'"
      return @

    listSave = [
      '~/AppData/Roaming/DarkSoulsIII'
      '~/Documents/AliceSoft'
      '~/Documents/My Games/NieR_Automata'
    ]

    for pathSave in listSave

      unless await $.isExisted_ pathSave
        continue

      source = "#{pathSave}/**/*.*"
      target = "#{@pathStorage}/存档"
      filename = "#{$.getBasename pathSave}.zip"

      await $.zip_ source, target, filename

    @ # return

  backupOneDrive_: ->
    
    await $.zip_ "#{@pathStorage}/**/*.*"
    , "#{@pathStorage}/.."
    , 'OneDrive.zip'

    @ # return

  execute_: ->

    method = await @ask_()
    await @[method]()

    @ # return

# return
module.exports = ->
  m = new M()
  await m.execute_()