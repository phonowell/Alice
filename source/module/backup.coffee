$ = require 'fire-keeper'

# class

class M

  ###
  listTarget
  mapMethod
  pathStorage
  ###

  listTarget: [
    'Game Save'
    'OneDrive'
  ]

  mapMethod:
    'Game Save': 'backupGameSave_'
    'OneDrive': 'backupOneDrive_'

  pathStorage: do ->

    mapPath =
      macos: '~/OneDrive'
      windows: 'E:/OneDrive'

    mapPath[$.os] or throw new Error "invalid os '#{$.os}'"

  ###
  backupGameSave_()
  backupOneDrive_()
  execute_(target)
  ###

  backupGameSave_: ->

    unless $.os == 'windows'
      throw new Error "invalid os '#{$.os}'"

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
      filename = "#{path.basename pathSave}.zip"

      await $.zip_ source, target, filename

    @ # return

  backupOneDrive_: ->
    
    await $.zip_ "#{@pathStorage}/**/*.*"
    , "#{@pathStorage}/.."
    , 'OneDrive.zip'

    @ # return

  execute_: (target) ->

    target or= await $.prompt
      type: 'select'
      message: 'select target'
      list: @listTarget

    unless target in @listTarget
      throw new Error "invalid target '#{target}'"

    method = @mapMethod[target]
    unless method
      throw new Error "invalid target '#{target}'"

    await @[method]()

    @ # return

# return
module.exports = (arg...) -> new M arg...