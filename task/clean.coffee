$ = require 'fire-keeper'

class M

  ###
  map
  ---
  ask_()
  cleanDsStore_()
  cleanKindle_()
  cleanTrash_()
  execute_(target)
  ###

  map:
    '.ds_store': 'cleanDsStore_'
    'kindle': 'cleanKindle_'
    'trash': 'cleanTrash_'

  ask_: ->

    {target} = $.argv()
    listTarget = (key for key, value of @map)

    target or= await $.prompt_
      id: 'clean'
      type: 'autocomplete'
      message: 'input'
      list: listTarget

    unless target in listTarget
      throw new Error "invalid target '#{target}'"

    unless method = @map[target]
      throw new Error "invalid target '#{target}'"

    method # return

  cleanDsStore_: ->

    unless $.os 'macos'
      throw new Error "invalid os '#{$.os()}'"

    await $.remove_ [
      '~/OneDrive/**/.DS_Store'
      '~/Project/**/.DS_Store'
    ]

    @ # return

  cleanKindle_: ->

    unless $.os 'macos'
      throw new Error "invalid os '#{$.os()}'"

    pathKindle = '/Volumes/Kindle/documents'
    unless await $.isExisted_ pathKindle
      throw new Error "invalid path '#{pathKindle}'"

    listExtname = [
      '.azw'
      '.azw3'
      '.kfx'
      '.mobi'
    ]

    listBook = []
    for extname in listExtname
      listTemp = await $.source_ "#{pathKindle}/*#{extname}"
      for book in listTemp
        listBook.push $.getBasename book

    listSdr = await $.source_ "#{pathKindle}/*.sdr"
    for sdr in listSdr
      basename = $.getBasename sdr
      if basename in listBook
        continue
      await $.remove_ sdr

    @ # return

  cleanTrash_: ->
    
    unless $.os 'macos'
      throw new Error "invalid os '#{$.os()}'"

    await $.remove_ '~/.Trash/**/*'
    
    @ # return

  execute_: ->

    method = await @ask_()
    await @[method]()

    @ # return

# return
module.exports = ->
  m = new M()
  await m.execute_()