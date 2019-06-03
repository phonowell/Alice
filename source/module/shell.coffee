$ = require 'fire-keeper'

class M

  ###
  execute_()
  loadData_()
  ###

  execute_: ->

    await @loadData_()

    {target} = $.argv

    listKey = $._.keys @map
    target or= await $.prompt_
      id: 'shell'
      type: 'select'
      message: 'select a target'
      list: listKey

    unless target in listKey
      throw new Error "invalid target '#{target}'"

    lines = @map[target]
    type = $.type lines
    switch type
      when 'array'
        null
      when 'string'
        lines = [lines]
      else throw new Error "invalid target '#{target}'"
    unless lines
      throw new Error "invalid target '#{target}'"

    await $.exec_ lines

    @ # return

  loadData_: ->
    pathSource = "./data/shell/#{$.os}.yaml"
    data = await $.read_ pathSource
    unless data
      $.info 'warning'
      , "invalid os '#{$.os}'"
      return @
    @map = data
    @ # return

# return
module.exports = ->
  m = new M()
  await m.execute_()
