$ = require 'fire-keeper'
{_} = $

kleur = require 'kleur'

class M

  ###
  listAction
  mapResult
  mapRule

  check()
  execute_()
  format(string)
  getAction_()
  makeList_()
  makeRandomList(len, max)
  make_()
  validate(list, goal)
  ###

  listAction: [
    'check'
    'make'
  ]

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
      $.i "#{_.padStart (i + 1), 2, '0'}. #{@validate list, goal}"

    @ # return

  execute_: ->

    action = await @getAction_()

    if action == 'check'

      await @makeList_()
      @check()
      return @

    if action == 'make'
      await @make_()
      return @

    throw new Error "invalid action '#{action}'"
    @ # return

  format: (string) ->

    list = string.trim()
    .split ' '
    _.remove list, (item) -> item == '+'
    list =
      red: list[0...5]
      blue: list[5...]

    list # return

  getAction_: ->
    {target} = $.argv
    target or= await $.prompt_
      id: 'lottery'
      type: 'select'
      message: 'select action'
      list: @listAction
    unless target in @listAction
      throw new Error "invalid action '#{target}'"
    target # return

  make_: ->

    listRed = @makeRandomList 5, 35
    listBlue = @makeRandomList 2, 12

    message = [
      listRed...
      '+'
      listBlue...
    ].join ' '

    $.i kleur.green message

    value = await $.prompt_
      type: 'confirm'
      message: 'continue?'
      default: true

    if value
      return @make_()

    @ # return

  makeList_: ->

    @list = []

    for line in await $.read_ './data/lottery.yaml'
      @list.push @format line

    @ # return

  makeRandomList: (len, max) ->

    list = _.shuffle [1..max]

    listResult = []
    i = 0
    while i < len
      
      n = list[parseInt Math.random() * max - 1]

      if n in listResult
        continue

      listResult.push n

      i++

    # return
    listResult.sort (a, b) -> a - b

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