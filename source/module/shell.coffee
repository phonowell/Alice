$ = require 'fire-keeper'

class M

  ###
  map

  execute_()
  ###

  map:

    flushdns:
      macos: 'sudo killall mDNSResponder'

    resetlaunchpad:
      macos: [
        'defaults write com.apple.dock ResetLaunchPad -bool true'
        'killall Dock'
      ]

    'ssh-add':
      macos: [
        'ssh-add -D'
        'cd ~/OneDrive/密钥/Anitama'
        'ssh-add anitama'
        'ssh-add anitama_cn'
        'ssh-add anitama_l'
        'ssh-add cspg'
        'ssh-add deploy'
        'ssh-add -l'
      ]

  execute_: ->

    {target} = $.argv

    listKey = (key for key in $._.keys @map)
    target or= await $.prompt
      id: 'shell'
      type: 'select'
      message: 'select a target'
      list: listKey

    unless target in listKey
      throw new Error "invalid target '#{target}'"

    item = @map[target]
    unless item
      throw new Error "invalid target '#{target}'"
    
    lines = item[$.os]
    unless lines
      throw new Error "invalid os '#{$.os}'"

    await $.exec_ lines

    @ # return

# return
module.exports = ->
  m = new M()
  await m.execute_()