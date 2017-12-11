# require

$$ = require 'fire-keeper'
{$, _, Promise} = $$.library
co = Promise.coroutine

# class

class Alice

  constructor: -> null

  ###

    start()

  ###

  start: co ->

    yield $$.say [
      'Ashen one, could you hear me still?'
      'Oh...good hunter.'
    ]

# return
module.exports = (arg...) -> new Alice arg...