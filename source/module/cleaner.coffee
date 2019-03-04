$ = require 'fire-keeper'

# class

class M

  ###
  listTarget

  cleanDsStore_()
  cleanTrash_()
  execute_(target)
  ###

  listTarget: [
    '.ds_store'
    'kindle'
    'trash'
  ]

  cleanDsStore_: ->

    unless $.os == 'macos'
      throw new Error "invalid os '#{$.os}'"

    await $.remove_ '~/Project/**/.DS_Store'

    @ # return

  cleanKindle_: ->

    unless $.os == 'macos'
      throw new Error "invalid os '#{$.os}'"

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

  cleanTrash_: ->
    
    unless $.os == 'macos'
      throw new Error "invalid os '#{$.os}'"

    await $.remove_ '~/.Trash/**/*'
    
    @ # return

  execute_: (target) ->

    {target} = $.argv

    target or= await $.prompt_
      id: 'cleaner'
      type: 'select'
      message: 'select a target'
      list: @listTarget

    unless target in @listTarget
      throw new Error "invalid target '#{target}'"

    switch target
      
      when '.ds_store'
        await @cleanDsStore_()
      
      when 'kindle'
        await @cleanKindle_()

      when 'trash'
        await @cleanTrash_()

      else throw new Error "invalid target '#{target}'"

    @ # return

# return
module.exports = ->
  m = new M()
  await m.execute_()