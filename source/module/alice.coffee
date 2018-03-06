# require

$$ = require 'fire-keeper'
{$, _} = $$.library

colors = require 'colors/safe'

m = require "#{process.cwd()}/source/module/qq.coffee"
Qq = m()

# class

class Alice

  constructor: -> null

  ###
  
  ask(question)
  bind()
  debug()
  execute(listCmd)
  roll(string)
  start()

  ###

  ask: (question) ->

    if !question?.length then return

    answer = switch question

      when 'master'
        "Alice's master is 'Mimiko'."

      when 'name', 'nickname', 'nick'
        "Alice nickname is '#{Qq.nickname}'."

      when 'room', 'chatroom'
        "Room name is '#{Qq.roomName}'."

      when 'time'
        "Current time is
        #{new Date().toLocaleString()}."

      else
        "Alice has got no information about '#{question}'"

    await Qq.say answer

  bind: ->

    {emitter} = Qq

    ###

    add-watch
    error
    hear
    login
    remove-watch
    say

    ###

    emitter.on 'add-watch', (data) ->
      $.info 'alice', "Alice is watching <#{data.type}: #{data.name}>"

    emitter.on 'error', (data) ->
      $.info 'alice', colors.red "Error: #{data}"

    emitter.on 'hear', (data) ->
      room = Qq.statusRoom
      for msg in data
        $.info "<#{room.type}: #{room.name}> #{colors.blue msg.name}#{colors.gray ':'} #{msg.content}"
    
    emitter.on 'login', -> $.info 'alice', 'Alice was ready'

    emitter.on 'remove-watch', ->
      $.info "Alice stopped watching <#{data.type}: #{data.name}>"

    emitter.on 'say', (data) ->
      $.info "#{colors.magenta data.name}#{colors.gray ':'} #{data.content}"

  debug: ->

    @isDebug = true

    Qq.say = (listMsg, isBreak = false) ->

      listMsg = switch $.type listMsg
          when 'array' then _.clone listMsg
          when 'number', 'string' then [listMsg]
          else throw new Error 'invalid type'

        if !isBreak
          return await @speak listMsg.join '\r\n'

        for msg in listMsg
          await @speak msg

    Qq.speak = (msg) ->

        await @delay()
        @emitter.emit 'say',
          content: msg
          name: @nickname

    Qq.nickname = 'Alice'
    Qq.statusRoom =
      type: 'discuss'
      name: 'Alice Room'

  execute: (listCmd, name) ->

    switch listCmd[0]

        when 'ask' then await @ask listCmd[1...].join ' '

        when 'help', 'h'

          listMsg = [
            '-ask xxx: get information about xxx'
            '-help: show help information'
            '-repeat [xxx]: repeat xxx'
            '-roll [dice] [description]: roll(dice should between 1d1 and 20d100)'
            '-star xxx: show x★x★x'
            '-test: run test'
          ]
          await Qq.say listMsg

        when 'repeat'

          msg = _.trim listCmd[1...].join ' '
          if !msg.length then return
          await Qq.say msg

        when 'roll', 'r'

          string = listCmd[1] or '1d100'
          if !string?.length then return

          stringValid = string
          .replace /[\+\-\*\/\(\)\dd]/g, ''
          if stringValid.length then return

          listDice = string.match /\d+d\d+/g
          if !listDice.length then return

          for dice in listDice
            unless res = @roll dice then return
            string = string.replace dice, res[1]

          string = string
          .replace /([\+\-\*\\])/g, ' $1 '
          .replace /\s+/g, ' '

          stringResult = unless ~string.search /[\+\-\*\\\(\)]/
            string
          else "#{string} = #{eval string}"

          stringDesc = listCmd[2...].join ' '
          if !stringDesc.length
            stringDesc = "To #{name}:"
          
          await Qq.say [
            stringDesc
            stringResult
          ]

        when 'star'

          msg = _.trim listCmd[1...].join ' '
          if !msg.length then return
          await Qq.say msg.split('').join '★'

        when 'test' then await Qq.say 'Alice test.'
  
  roll: (string) ->

    listCmd = string.split 'd'
    for a, i in listCmd
      listCmd[i] = parseInt a

    unless (1 <= listCmd[0] <= 20) then return null
    unless (1 <= listCmd[1] <= 100) then return null

    res = 0
    listText = []
    for i in [0...listCmd[0]]
      num = 1 + _.random listCmd[1] - 1
      res += num
      listText.push num

    # return
    [
      res
      if listText.length == 1
        "#{res}"
      else "(#{listText.join '+'})"
    ]
  
  start: ->

    # @debug()

    @bind()

    if !@isDebug

      await Qq.login()

    Qq.emitter.on 'hear', (data) =>

      for msg in data

        {content, name} = msg
        if content[0] != '-' then continue

        listCmd = _.trim content[1...]
        .replace /\s+/g, ' '
        .split ' '

        await @execute listCmd, name
        
      await Qq.leave()

    if !@isDebug

      listRoom = [
        ['discuss', 'Alice Test Team']
        ['friend', 'Brick Eyre']
        ['friend', '某御']
        ['group', 'Guru! Project Group']
      ]
      for room in listRoom
        Qq.addWatch room...

      await Qq.watch()

    if @isDebug

      Qq.emitter.emit 'hear', [
        name: 'mimiko'
        content: '- star 1d6'
      ]

# return
module.exports = (arg...) -> new Alice arg...