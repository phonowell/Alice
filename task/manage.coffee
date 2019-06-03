$ = require 'fire-keeper'

class M

  ###
  list

  execute_()
  getAction_()
  getName_()
  remove_(name)
  ###

  list: [
    'remove'
  ]

  execute_: ->

    action = await @getAction_()
    name = await @getName_()

    method = "#{action}_"
    await @[method] name

    @ # return

  getAction_: ->
    
    {action} = $.argv
    action or= await $.prompt_
      type: 'select'
      message: 'select action'
      list: @list

    unless action in @list
      throw new Error "invalid action '#{action}'"

    action # return

  getName_: ->

    {name, target} = $.argv
    name or= target
    name or= await $.prompt_
      type: 'text'
      message: 'input name'

    unless name.length
      throw new Error "invvalid name '#{name}'"

    name # return

  remove_: (name) ->

    await $.remove_ [
      "./source/module/#{name}.coffee"
      "./task/#{name}.coffee"
    ]

    @ # return

# return
module.exports = ->

  m = new M()
  await m.execute_()
