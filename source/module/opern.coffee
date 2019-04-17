$ = require 'fire-keeper'
{_} = $

class M

  ###
  delay
  long
  mapKey

  execute_()
  format(listIn)
  load_(pathSource)
  save_(pathTarget, listIn)
  translate(listIn)
  ###

  delay: 50
  mapKey:
    '0': '0'
    '1': '1'
    '2': '2'
    '3': '3'
    '4': '4'
    '5': '5'
    '6': '6'
    '7': '7'
    '8': '8'
    '+': 'shift'
    '-': 'ctrl'
    '#': '='
    'b': '-'

  execute_: ->

    listSource = await $.source_ './../*.txt'
    for source in listSource

      long = parseInt $.getFilename source
      @long = long or 400

      target = source
      .replace /\.txt/, '.ahk'
    
      list = await @load_ source
      list = @format list
      list = @translate list
      await @save_ target, list
    
    @ # return

  format: (listIn) ->

    listOut = []
    for item in listIn

      # pitch
      pitch = item.match /\d/
      unless pitch
        throw new Error "invalid item '#{item}'"
      pitch = pitch[0]

      # #/b
      for sign in ['#', 'b']
        unless ~item.search sign
          continue
        pitch = "#{sign}#{pitch}"

      # +/-
      for sign in ['+', '-']
        unless ~item.search "\\#{sign}"
          continue
        pitch = "#{sign}#{pitch}"

      # duration
      listDuration = item.match /\/+/
      duration = if listDuration
        [1, 0.5, 0.25][listDuration[0].length]
      else 1

      # wait
      wait = if ~item.search /\(/
        parseInt (item.split '(')[1]
      else 0

      # join
      listOut.push {
        pitch, duration, wait
      }

    listOut # return

  load_: (pathSource) ->
    
    cont = await $.read_ pathSource
    unless cont?.length
      throw new Error "invalid path '#{pathSource}'"

    cont = cont
    .replace /\r\n/g, ' '
    .replace /\|/g, ''
    .replace /\s+/g, ' '
    cont = _.trim cont

    # return
    cont.split ' '

  save_: (pathTarget, listIn) ->

    contWrapper = await $.read_ './data/opern/wrapper.txt'

    cont = contWrapper.replace /xxx/
    , listIn.join '\n'

    # for windows
    cont = cont
    .replace /\n/g, '\r\n'
    
    await $.write_ pathTarget, cont
    
    @ # return

  translate: (listIn) ->

    listOut = []

    for item in listIn
      
      {pitch, duration, wait} = item
      listKey = []

      if pitch[0] in ['+', '-']
        listKey.push @mapKey[pitch[0]]
      for sign in ['#', 'b']
        if ~pitch.search sign
          listKey.push @mapKey[sign]
      key = (_.padStart pitch, 3)[2]
      listKey.push @mapKey[key]

      time = duration * @long + wait * 0.5 * @long - @delay

      [stringDown, stringUp] = unless key == '0'
        string = ("{#{key} xxx}" for key in listKey).join ''
        [
          "send #{string.replace /xxx/g, 'down'}"
          "send #{string.replace /xxx/g, 'up'}"
        ]
      else ['', '']

      # result
      stringResult = [
        stringDown
        "sleep #{time}"
        stringUp
      ].join '\n'
      stringResult = _.trim stringResult, '\n'
      stringResult += "\nsleep #{@delay}"

      listOut.push stringResult

    listOut # return

# reture
module.exports = ->
  m = new M()
  await m.execute_()