$ = require 'fire-keeper'

# class

class M

  ###
  listTarget
  ###

  listTarget: [
    'trash'
  ]

  ###
  cleanTrash_()
  execute_(target)
  ###

  cleanTrash_: ->
    
    unless $.os == 'macos'
      throw new Error "invalid os '#{$.os}'"

    await $.remove_ '~/.Trash/**/*'
    
    @ # return

  execute_: (target) ->

    target or= await $.prompt
      type: 'select'
      message: 'select target'
      list: @listTarget

    unless target in @listTarget
      throw new Error "invalid target '#{target}'"

    if target == 'trash'
      await @cleanTrash_()

    @ # return

# return
module.exports = (arg...) -> new M arg...