$ = require 'fire-keeper'
kleur = require 'kleur'

class M

  ###
  ask_()
  execute_()
  loadData_()
  ###

  ask_: ->

    seed = parseInt Math.random() * @list.length
    [answer, char] = @list[seed].split ','

    seed = parseInt Math.random() * 2
    char = char[seed]

    value = await $.prompt_
      type: 'text'
      message: char
      default: 'exit'

    if value == 'exit'
      return @

    msg = "#{char} -> #{answer}"
    msg = if value == answer
      kleur.green msg
    else kleur.red msg

    $.i msg

    namespace = '50on.ask_'
    $.info.pause namespace
    $.say_ char,
      lang: 'ja'
    $.info.resume namespace
    
    # loop
    return @ask_()

    @ # return

  execute_: ->

    await @loadData_()

    await @ask_()

    @ # return

  loadData_: ->

    @list = await $.read_ './data/50on.yaml'

    @ # return

# reture
module.exports = ->
  m = new M()
  await m.execute_()
