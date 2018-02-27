# require

$$ = require 'fire-keeper'
{$, _} = $$.library

# class

class Alice

  constructor: -> null

  ###

  start()

  ###

  start: ->

    await $$.say [
      'Ashen one, could you hear me still?'
      'Oh...good hunter.'
    ]

# return
module.exports = (arg...) -> new Alice arg...