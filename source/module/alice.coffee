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
  start()

  ###

  bind: ->

    {emitter} = Qq

    emitter.on 'enter', (data) ->
      $.info 'alice', "Alice entered <#{data.type}: #{data.name}>"

    emitter.on 'leave', (data) ->
      $.info 'alice', "Alice left <#{data.type}: #{data.name}>"
    
    emitter.on 'login', -> $.info 'alice', 'Alice was ready'

    emitter.on 'say', (data) ->
      $.info 'alice', colors.blue "#{data.name}: #{data.content}"

    emitter.on 'hear', (data) ->
      $.info 'alice', colors.grey "#{data.name}: #{data.content}"

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

        when 'help'

          listMsg = []
          listMsg.push '-ask xxx: get information about xxx'
          listMsg.push '-help: show help information'
          listMsg.push '-meth: leave chatroom'
          listMsg.push '-repeat xxx: repeat xxx'
          listMsg.push '-roll xdx: throw a dice(from 1d1 to 100d100)'
          listMsg.push '-test: run test'
          await Qq.say listMsg

        when 'meth' then await Qq.leave()

        when 'repeat'

          msg = _.trim listCmd[1...].join ' '
          if !msg.length then return
          await Qq.say msg

        when 'roll'

          dice = listCmd[1] or '1d100'
          if !dice?.length then return
          unless ~dice.search /\d+d\d+/ then return

          listDice = dice.split 'd'
          for a, i in listDice
            listDice[i] = parseInt a

          unless (1 <= listDice[0] <= 100) then return
          unless (1 <= listDice[1] <= 100) then return

          res = 0
          listMsg = []
          for i in [0...listDice[0]]
            num = 1 + _.random listDice[1] - 1
            res += num
            listMsg.push num

          msg = "#{name} threw #{dice}: "
          msg += if listMsg.length == 1
            "#{res}"
          else "#{listMsg.join ' + '} = #{res}"
          await Qq.say msg

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

  start: ->

    # @debug()

    @bind()

    if !@isDebug

      await Qq.start()
      await Qq.login()

      # await Qq.enter 'discuss', 'Alice Test Team'
      await Qq.enter 'group', 'Guru! Project Group'

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
        content: '- roll 1d6'

# return
module.exports = (arg...) -> new Alice arg...