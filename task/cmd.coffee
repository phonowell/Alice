_ = require 'lodash'
$ = require 'fire-keeper'

class M

  ###
  ask_(map)
  execute_()
  load_()
  ###

  ask_: (map) ->

    {target} = $.argv()
    listKey = _.keys map

    target or= await $.prompt_
      id: 'cmd'
      type: 'autocomplete'
      message: 'command'
      list: listKey

    unless target in listKey
      throw new Error "invalid target '#{target}'"

    target # return

  execute_: ->

    map = await @load_()
    cmd = await @ask_ map

    lines = map[cmd]
    type = $.type lines

    if type == 'string'
      lines = [lines]
      type = $.type lines

    unless type == 'array'
      throw new Error "invalid command '#{cmd}'"

    await $.exec_ lines

    @ # return

  load_: ->

    unless data = await $.read_ "./data/cmd/#{$.os()}.yaml"
      $.info 'warning'
      , "invalid os '#{$.os()}'"
      return null
    
    data # return

# return
module.exports = ->
  m = new M()
  await m.execute_()