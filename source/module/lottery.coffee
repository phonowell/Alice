$ = require 'fire-keeper'
kleur = require 'kleur'

class M

  ###
  mapResult
  mapRule

  check()
  execute_()
  format(string)
  makeList_()
  validate(list, goal)
  ###

  mapResult: [
    '-'
    '???'
    '???'
    '10,000'
    '3,000'
    '300'
    '200'
    '100'
    '15'
    '5'
  ]

  mapRule:
    '5+2': 1
    '5+1': 2
    '5+0': 3
    '4+2': 4
    '4+1': 5
    '3+2': 6
    '4+0': 7
    '3+1': 8
    '2+2': 8
    '3+0': 9
    '1+2': 9
    '2+1': 9
    '0+2': 9

  check: ->

    goal = @list[0]

    for list, i in @list[1...]
      $.i "#{$._.padStart (i + 1), 2, '0'}. #{@validate list, goal}"

    @ # return

  execute_: ->

    await @makeList_()
    @check()

    @ # return

  format: (string) ->

    list = string.trim()
    .split ' '
    $._.remove list, (item) -> item == '+'
    list =
      red: list[0...5]
      blue: list[5...]

    list # return

  makeList_: ->

    @list = []

    for line in await $.read_ './data/lottery.yaml'
      @list.push @format line

    @ # return

  validate: (list, goal) ->
    
    red = 0
    listRed = []
    for n in list.red
      if n in goal.red
        red++
        listRed.push kleur.green n
      else listRed.push n

    blue = 0
    listBlue = []
    for n in list.blue
      if n in goal.blue
        blue++
        listBlue.push kleur.green n
      else listBlue.push n

    key = "#{red}+#{blue}"
    rank = @mapRule[key] or 0

    result = @mapResult[rank]

    rank = if rank
      kleur.green "Rank #{rank}"
    else 'Rank -'

    # return
    [
      '['
      listRed.join ' '
      '+'
      listBlue.join ' '
      ']'
      rank
      # result
    ].join ' '

# reture
module.exports = ->
  m = new M()
  await m.execute_()