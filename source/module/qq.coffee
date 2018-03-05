# require

$$ = require 'fire-keeper'
{$, _} = $$.library

EventEmitter = require 'events'
class QqEmitter extends EventEmitter

cheerio = require 'cheerio'
{Chromeless} = require 'chromeless'
chrome = null
colors = require 'colors/safe'

# class

class Qq

  constructor: -> null

  ###

  emitter
  listHistory
  listRoomType
  listWatch
  timerWatch

  $(selector)
  addWatch(type, name)
  checkNotify()
  delay(time)
  end()
  enter(type, name)
  enterNav(name)
  error(msg)
  getMessageInfo($el)
  getOwnNickname()
  getRoomInfo($el)
  getSession()
  isIndoor()
  leave()
  login()
  removeWatch(type, name)
  say(listMsg)
  sleep()
  speak(msg)
  start()
  wake()
  watch()

  ###

  emitter: new QqEmitter()
  listHistory: []
  listRoomType: [
    'discuss'
    'friend'
    'group'
  ]
  listWatch: []
  timerWatch: null

  $: (selector) ->

    html = await chrome.html()

    dom = cheerio.load html
    
    # return
    [
      dom selector
      dom
    ]

  addWatch: (type, name) ->

    i = _.findIndex @listWatch, {type, name}
    if i != -1 then return

    @listWatch.push {type, name}

  checkNotify: ->
    [$item] = await @$ '#current_chat_list > li.notify'
    if !$item.length then return false
    data = @getRoomInfo $item.eq 0
    @emitter.emit 'notify', data
    data # return

  delay: (time = 500) ->

    token = 'alice.delay'

    $.info.pause token
    await $$.delay time
    $.info.resume token

  end: -> await chrome.end()

  enter: (type, name) ->

    if await @isIndoor()
      await @leave()

    @session = await @getSession()

    unless type in @listRoomType
      return @error "invalid room type '#{type}'"

    data = _.find @session, {type, name}
    if !data
      return @error "invalid room name '#{name}'"

    await chrome.click "##{data.id}"
    .html()

    await @delay()

    unless await @isIndoor()
      return await @enter type, name

    @statusRoom = data
    @listHistory[data.id] or= []

    @emitter.emit 'enter', {type, name}

  enterNav: (name) ->

    res = await chrome.exists "##{name}.selected"
    if res then return

    await chrome.click "##{name}"
    .html()

    await @delay()
    await @enterNav name

  error: (msg) -> @emitter.emit 'error', msg

  getMessageInfo: ($el) ->
    name = _.trim $el.children('p.chat_nick').text()
    content = _.trim $el.children('p.chat_content').text()
    {name, content}

  getOwnNickname: ->
    [$nickname] = await @$ '#mainTopAll span.user_nick'
    _.trim $nickname.text()

  getRoomInfo: ($el) ->

    id = $el.attr 'id'

    type = $el.attr '_type'
    unless type in @listRoomType then return

    $nick = $el.find 'p.member_nick'
    name = if ($true = $nick.children 'span').length
      $true.text()
    else $nick.text()
    name = _.trim name

    # return
    {id, type, name}

  getSession: ->

    data = []
    getRoomInfo = @getRoomInfo

    [$child, dom] = await @$ '#current_chat_list > li'
    $child.each ->
      $el = dom @
      data.push getRoomInfo $el

    data = _.sortBy data, 'name'
    data # return

  isIndoor: ->
    [$target] = await @$ '#panel-5'
    if !$target.length then return false
    $target.css('display') == 'block'

  say: (listMsg, isBreak = false) ->

    listMsg = switch $.type listMsg
      when 'array' then _.clone listMsg
      when 'number', 'string' then [listMsg]
      else throw new Error 'invalid type'

    if !isBreak
      return await @speak listMsg.join '\r\n'

    for msg in listMsg
      await @speak msg

  sleep: ->
    clearInterval @timerWatch
    @emitter.emit 'sleep'

  speak: (msg) ->

    unless await @isIndoor() then return

    selector = '#chat_textarea'
    await chrome.focus selector
    .type msg, selector
    .press 13

    await @delay()
    @emitter.emit 'say',
      content: msg
      name: @nickname

  leave: ->

    unless await @isIndoor() then return

    name = @roomName
    type = @roomType

    selector = '#panelRightButton-5'
    await chrome.click selector
    .html()

    await @delay()
    @emitter.emit 'leave', {type, name}

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

    @nickname = await @getOwnNickname()

    # await @enterNav 'session'

    @emitter.emit 'login'

  removeWatch: (type, name) ->

    i = _.findIndex @listWatch, {type, name}
    if i == -1 then return

    @listWatch.splice i, 1

  start: ->
    await @delay 0
    chrome = new Chromeless()

  wake: ->
    clearInterval @timerWatch
    @timerWatch = setInterval =>
      @watch()
    , 200
    @emitter.emit 'wake'

  watch: ->

    data = await @checkNotify()
    if !data then return

    {id, type, name} = data
    await @enter type, name

    return

    # [$child, dom] = await @$ '.chat_content_group.buddy'

    # listChat = []

    # $child.each ->
    #   $el = dom @
    #   listChat.push
    #     name: _.trim $el.children('p.chat_nick').text()
    #     content: _.trim $el.children('p.chat_content').text()

    # listChat.reverse()
    # index = _.findIndex listChat, @history[@roomName]
    # @history[@roomName] = listChat[0]
    # listChat = do ->
    #   if index == -1
    #     return listChat
    #   listChat[0...index]
    # listChat.reverse()

    # for item in listChat
    #   @emitter.emit 'hear', item

# return
module.exports = (arg...) -> new Qq arg...