_ = require 'lodash'
$ = require 'fire-keeper'

class M

  ###
  ask_()
  execute_()
  load_()
  ###

  ask_: ->

    {target} = $.argv()
    listKey = _.keys @map

    target or= await $.prompt_
      id: 'cmd'
      type: 'autocomplete'
      message: 'command'
      list: listKey

    unless target in listKey
      throw new Error "invalid target '#{target}'"

    target # return

  execute_: ->

    await @load_()
    cmd = await @ask_()

    lines = @map[cmd]
    
    switch type = $.type lines
      when 'string'
        lines = [lines]
      else throw new Error "invalid command '#{cmd}'"
    
    unless lines
      throw new Error "invalid command '#{cmd}'"

    await $.exec_ lines

    @ # return

  load_: ->

    unless data = await $.read_ "./data/cmd/#{$.os()}.yaml"
      $.info 'warning'
      , "invalid os '#{$.os()}'"
      return @
    
    @map = data
    
    @ # return

# return
module.exports = ->
  m = new M()
  await m.execute_()