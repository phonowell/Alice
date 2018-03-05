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
  
  bind()
  debug()
  execute(listCmd)
  home()
  roll(string)
  start()

  ###

  bind: ->

    {emitter} = Qq

    ###

    enter
    error
    hear
    leave
    login
    say

    ###

    emitter.on 'enter', (data) ->
      $.info 'alice', "Alice is watching <#{data.type}: #{data.name}>"
      await Qq.say 'Alice entered room.'

    emitter.on 'error', (data) =>
      await @home()
      await Qq.say "Error: #{data}"

    emitter.on 'leave', (data) ->
      $.info 'alice', "Alice stopped watching <#{data.type}: #{data.name}>"
    
    emitter.on 'login', -> $.info 'alice', 'Alice was ready'

    emitter.on 'say', (data) ->
      $.info "#{colors.magenta data.name}#{colors.gray ':'} #{data.content}"

    emitter.on 'hear', (data) ->
      $.info "#{colors.blue data.name}#{colors.gray ':'} #{data.content}"

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
    Qq.roomName = 'Alice Room'
    Qq.roomType = 'discuss'

  execute: (listCmd, name) ->

    switch listCmd[0]

        when 'ask'

          question = listCmd[1]
          if !question?.length then return

          msg = switch question

            when 'name', 'nickname', 'nick'
              "Alice nickname is '#{Qq.nickname}'."

            when 'room', 'chatroom'
              "Room name is '#{Qq.roomName}'."

            when 'time'
              "Current time is
              #{new Date().toLocaleString()}."

          await Qq.say msg

        when 'help', 'h'

          listMsg = [
            '-ask xxx: get information about xxx'
            '-help: show help information'
            '-leave: leave room'
            '-move: type name: move to <type:name>'
            '-repeat [xxx]: repeat xxx'
            '-roll [dice] [description]: roll(dice should between 1d1 and 20d100)'
            '-star xxx: show x★x★x'
            '-test: run test'
          ]
          await Qq.say listMsg

        when 'leave' then await @home()

        when 'move'

          if Qq.roomName != '某御' then return

          type = listCmd[1]
          roomName = listCmd[2...].join ' '
          unless type and roomName then return

          await Qq.leave()
          await Qq.enter type, roomName

        when 'repeat'

          msg = _.trim listCmd[1...].join ' '
          if !msg.length then return
          await Qq.say msg

        when 'roll'

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

        when 'test'

          listMsg = [
            '1. A robot may not harm a human being,
            or,
            through inaction,
            allow a human being to come to harm.'
            '2. A robot must obey the orders given to it by human beings,
            except where such orders would conflict with the First Law.'
            '3. A robot must protect its own existence,
            as long as such protection does not conflict with the First or Second Law.'
          ]
          await Qq.say listMsg

  home: ->
    await Qq.leave()
    await Qq.enter 'friend', '某御'
  
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

      await Qq.start()
      await Qq.login()
      
      await @home()

      # await Qq.enter 'discuss', 'Alice Test Team'
      # await Qq.enter 'friend', '某御'
      # await Qq.enter 'group', 'Guru! Project Group'

    Qq.emitter.on 'hear', (data) =>

      {content, name} = data

      if content[0] != '-' then return

      listCmd = _.trim content[1...]
      .replace /\s+/g, ' '
      .split ' '

      await @execute listCmd, name

    if @isDebug

      Qq.emitter.emit 'hear',
        name: 'mimiko'
        content: '- star 1d6'

# return
module.exports = (arg...) -> new Alice arg...