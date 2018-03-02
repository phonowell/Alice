# require

$$ = require 'fire-keeper'
{$, _} = $$.library

EventEmitter = require 'events'
class AliceEmitter extends EventEmitter

cheerio = require 'cheerio'
{Chromeless} = require 'chromeless'
chrome = new Chromeless()
colors = require 'colors/safe'

# class

class Alice

  constructor: -> null

  ###

  $(selector)
  alice
  bind()
  delay(time)
  end()
  enter(type, name)
  enterNav(name)
  enterTab(type)
  getOwnNickname()
  getSession()
  leave()
  login()
  say(listMsg)
  speak(msg)
  start()
  watch()

  ###

  $: (selector) ->

    html = await chrome.html()

    dom = cheerio.load html
    
    # return
    [
      dom selector
      dom
    ]

  alice: new AliceEmitter()

  bind: ->

    @alice.on 'enter', (data) ->
      $.info 'alice', "Alice entered <#{data.type}: #{data.name}>"

    @alice.on 'leave', (data) ->
      $.info 'alice', "Alice left <#{data.ype}: #{data.name}>"
    
    @alice.on 'login', -> $.info 'alice', 'Alice was ready'

    @alice.on 'say', (data) ->
      $.info 'alice', colors.blue "#{data.name}: #{data.content}"

    @alice.on 'hear', (data) ->
      $.info 'alice', colors.grey "#{data.name}: #{data.content}"

  delay: (time = 1e3) ->

    token = 'alice.delay'

    $.info.pause token
    await $$.delay time
    $.info.resume token

  end: -> await chrome.end()

  enter: (type, name) ->

    item = _.find @session[type], {name}
    await @enterNav 'session'

    await chrome.click "##{item.id}"
    .html()

    await @delay()
    @roomName = name
    @roomType = type
    @watch true
    @alice.emit 'enter', {name, type}

  enterNav: (name) ->

    res = await chrome.exists "##{name}.selected"
    if res then return

    await chrome.click "##{name}"
    .html()

    await @delay()
    await @enterNav name

  enterTab: (type) ->

    res = await chrome.exists "#memberTab > li[param=\"#{type}\"].active"
    if res then return

    await chrome.click "#memberTab > li[param=\"#{type}\"]"
    .html()

    await @delay()
    await @enterTab type

  getOwnNickname: ->

    [$nickname] = await @$ '#mainTopAll span.user_nick'
    _.trim $nickname.text()

  getSession: ->

    await @enterNav 'session'

    listKey = [
      'discuss'
      'friend'
      'group'
    ]

    data = {}
    for key in listKey
      data[key] = []

    [$child, dom] = await @$ '#current_chat_list > li'

    $child.each ->

      $el = dom @

      type = $el.attr '_type'
      unless type in listKey then return

      data[type].push
        id: $el.attr 'id'
        name: _.trim $el.find('p.member_nick').text()

    # sort
    for key in listKey
      data[key] = _.sortBy data[key], 'name'

    data # return

  say: (listMsg) ->

    listMsg = switch $.type listMsg
      when 'array' then _.clone listMsg
      when 'number', 'string' then [listMsg]
      else throw new Error 'invalid type'

    for msg in listMsg
      await @speak msg

  speak: (msg) ->

    selector = '#chat_textarea'

    await chrome.focus selector
    .type msg, selector
    .press 13

    await @delay()
    @alice.emit 'say',
      content: msg
      name: @nickname

  start: ->

    @bind()
    await @login()

    @nickname = await @getOwnNickname()
    @session = await @getSession()

    # await @enter 'discuss', 'Alice Test Team'
    await @enter 'group', 'Guru! Project Group'

    @alice.on 'hear', (data) =>

      switch data.content

        when 'test'

          listMsg = []
          listMsg.push 'Alice test.'
          listMsg.push "Nickname is '#{@nickname}'."
          listMsg.push "Room name is '#{@roomName}'"
          listMsg.push "Room type is '#{@roomType}'"
          listMsg.push "Current time is #{new Date().toLocaleString()}"
          res = 1 + _.random 5
          listMsg.push "Throw 1d6: #{res}."
          res = 1 + _.random 19
          listMsg.push "Throw 20 + 1d20: 20 + #{res} = #{20 + res}."
          listMsg.push 'Test done.'
          await @say listMsg

        else

          await @say "repeat #{data.content}"

  leave: ->

    @watch false

    selector = '#panelRightButton-5'

    await chrome.click selector
    .html()

    await @delay()
    @alice.emit 'leave',
      name: @roomName
      type: @roomType

  login: ->

    $.info 'alice', 'Alice is waiting for login'

    userAgent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_3)
    AppleWebKit/537.36 (KHTML, like Gecko)
    Chrome/64.0.3282.186 Safari/537.36'

    timeout = 5 * 60 * 1e3

    await chrome.setUserAgent userAgent
    .setViewport
      width: 1280
      height: 800

    selector = 'iframe'
    await chrome.goto 'http://web2.qq.com/'
    .wait selector, timeout
    .html()

    selector = 'ul#current_chat_list > li.list_item'
    await chrome.wait selector, timeout
    .html()

    @alice.emit 'login'

  watch: (action = true) ->
    
    if !action
      clearInterval @timerWatch
      return

    @history or= {}
    @history[@roomName] or= {}
    
    @timerWatch = setInterval =>

      [$child, dom] = await @$ '.chat_content_group.buddy'

      listChat = []

      $child.each ->
        $el = dom @
        listChat.push
          name: _.trim $el.children('p.chat_nick').text()
          content: _.trim $el.children('p.chat_content').text()

      listChat.reverse()
      index = _.findIndex listChat, @history[@roomName]
      @history[@roomName] = listChat[0]
      listChat = do ->
        if index == -1
          return listChat
        listChat[0...index]
      listChat.reverse()

      for item in listChat
        @alice.emit 'hear', item

    , 1e3

# return
module.exports = (arg...) -> new Alice arg...