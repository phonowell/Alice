# require

$ = require 'fire-keeper'
{_} = $

path = require 'path'

inquirer = require 'inquirer'

# class

class M

  ###
  storage
  ###

  storage: do ->

    mapPath =
      macos: '~/OneDrive'
      windows: 'E:/OneDrive'

    mapPath[$.os] or throw new Error "invalid os '#{$.os}'"

  ###
  ask_()
  backupGameSave_()
  backupOneDrive_()
  execute_(target)
  ###

  ask_: ->

    listOption = [
      'Game Save'
      'OneDrive'
    ]

    {answer} = await inquirer.prompt
      type: 'list'
      name: 'answer'
      choices: listOption

    answer # return

  backupGameSave_: ->

    if $.os != 'windows'
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
      target = "#{@storage}/存档"
      filename = "#{path.basename pathSave}.zip"

      await $.zip_ source, target, filename

  backupOneDrive_: ->
    await $.zip_ "#{@storage}/**/*.*"
    , "#{@storage}/.."
    , 'OneDrive.zip'

  execute_: (target) ->

    listTask = target or await @ask_()

    if $.type(listTask) != 'array'
      listTask = [listTask]

    for task in listTask
      task = task.toLowerCase()
      .replace /\s/g, ''

      mapMethod =
        onedrive: 'backupOneDrive_'
        gamesave: 'backupGameSave_'

      method = mapMethod[task] or throw new Error "invalid task '#{task}'"
      await @[method]()

# return
module.exports = (arg...) -> new M arg...