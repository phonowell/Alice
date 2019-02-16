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
    'trash'
  ]

  cleanDsStore_: ->

    unless $.os == 'macos'
      throw new Error "invalid os '#{$.os}'"

    await $.remove_ '~/Project/**/.DS_Store'

    @ # return

  cleanTrash_: ->
    
    unless $.os == 'macos'
      throw new Error "invalid os '#{$.os}'"

    await $.remove_ '~/.Trash/**/*'
    
    @ # return

  execute_: (target) ->

    {target} = $.argv

    target or= await $.prompt
      id: 'cleaner'
      type: 'select'
      message: 'select a target'
      list: @listTarget

    unless target in @listTarget
      throw new Error "invalid target '#{target}'"

    if target == '.ds_store'
      return await @cleanDsStore_()

    if target == 'trash'
      return await @cleanTrash_()

    @ # return

# return
module.exports = ->
  m = new M()
  await m.execute_()