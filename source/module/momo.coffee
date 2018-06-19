$ = require 'fire-keeper'
{_} = $

class Renderer

  ###
  renderBeep(line)
  renderBlock(line)
  renderClick(line)
  renderEqual(line)
  renderExit(line)
  renderFunction(line)
  renderIf(line)
  renderNote(line)
  renderNumber(line)
  renderOn(line)
  renderRaw(line)
  renderSend(line)
  renderSetTimer(line)
  ###

  renderBeep: (line) ->
    unless ~line.search /\$\.beep\(\)/ then return line
    line.replace '$.beep()', 'soundBeep'

  renderBlock: (line) ->
    unless ~line.search '= ->' then return line
    line.replace /\s*=\s*->/, ':'

  renderClick: (line) ->
    unless ~line.search /\$\.click/ then return line
    line.replace /\$\.click\s+'(.*?)'/, 'click, $1'

  renderEqual: (line) ->
    unless ~line.search ' = ' then return line
    line.replace /\s+=\s+/g, ' := '

  renderExit: (line) ->
    unless ~line.search /\$\.exit\(\)/ then return line
    line.replace '$.exit()', 'exitApp'

  renderFunction: (line) ->
    unless ~line.search /\(\)/ then return line
    line.replace /([^\s]+)\(\)/, 'goSub, $1'
    .replace /goSub, \$\.(\S+)/g, '$.$1()'

  renderIf: (line) ->
    unless ~line.search /(if|else)/ then return line
    line.replace /if\s+?(.*)/, 'if ($1) {'
    .replace /else/, 'else {'

  renderNote: (line) ->
    unless ~line.search '#' then return line
    line.replace /#/, ';'

  renderNumber: (line) ->
    unless ~line.search /\d+e\d+/ then return line
    line.replace /\d+e\d+/g, (string) ->
      listNumber = string.split 'e'
      lenPad = 1 + parseInt(listNumber[1])
      _.padEnd listNumber[0], lenPad, '0'

  renderRaw: (line) ->
    unless ~line.search /;!/ then return line
    line.replace /;!\s*/, ''

  renderOn: (line) ->
    unless ~line.search /\$\.on\s/ then return line
    line.replace /\$\.on\s+'(.+?)'\s*/, (s, string) ->
      string
      .replace /\s/g, ''
      .replace /\+/g, ''

      .replace /win/g, '#'
      .replace /alt/g, '!'
      .replace /ctrl/g, '^'
      .replace /control/g, '^'
      .replace /shift/g, '+'

      .replace /&/g, ' & '

    .replace /\s*,\s*->/, '::'

  renderSend: (line) ->
    unless ~line.search /\$\.send/ then return line
    line.replace /\$\.send\s+'(.+?)'/, 'send, {$1}'

  renderSetTimer: (line) ->
    unless ~line.search /\$\.setTimer/ then return line
    line.replace '$.setTimer', 'setTimer,'
    .replace 'false', 'off'

class Momo

  ###
  renderer
  ###

  renderer: new Renderer()

  ###
  compile_(pathSource)
  genList(source)
  pretty(content)
  render_(listLine)
  ###

  compile_: (pathSource) ->

    source = await $.read_ pathSource
    listLine = @genList source
    result = await @render_ listLine
    result = @pretty result

    pathOutput = pathSource.replace /\.coffee/, '.ahk'
    await $.write_ pathOutput, result

  genList: (source) ->
    
    # remove all break
    result = source
    .replace /\r\n/g, '\n'
    .replace /\r/g, '\n'
    .replace /\n{2,}/g, '\n'

    listResult = []
    for line, i in result.split '\n'
      
      string = _.trim line
      if !string.length then continue
      
      listResult.push
        content: string
        depth: line.search /\S/
    
    listResult.unshift
      content: ''
      depth: 0
    listResult.push
      content: '# EOF'
      depth: 0

    listResult # return

  pretty: (content) ->

    listContent = content.split '\n'
    listResult = []

    for line, i in listContent
      
      string = line
      stringPure = _.trim string

      if stringPure[0] == ';'
        string = "\n#{string}"

      if stringPure.search('return') == 0
        string += '\n'

      listResult.push string

    result = listResult.join '\n'

    result = result
    .replace /\n{3,}/g, '\n\n'

    result # return

  render_: (listLine) ->

    listMethod = [
      'note'
      'raw'
      'block'
      'if'
      'function'
      'equal'
      'number'
      'on'
      'send'
      'click'
      'set timer'
      'exit'
      'beep'
    ]
    listMethod = (_.camelCase "render #{key}" for key in listMethod)

    listResult = []
    listMark = []
    for line, i in listLine

      # pass blank line
      if !line.content.length then continue

      string = line.content

      for method in listMethod
        string = @renderer[method] string

      # depth
      lineLast = listLine[i - 1]
      depth = line.depth
      lastDepth = lineLast.depth
      if depth > lastDepth
        listMark[lastDepth] = if ~lineLast.content.search /->/
          'return'
        else '}'
      else if depth < lastDepth
        for mark, i in listMark[depth...] by -1 when mark
          listResult.push "#{_.repeat ' ', (depth + i) * 2}#{mark}"
          listMark[depth + i] = null

      listResult.push "#{_.repeat ' ', line.depth * 2}#{string}"

    # return
    listResult.join '\n' # return

# return
module.exports = (arg...) -> new Momo arg...