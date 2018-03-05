# require

$$ = require 'fire-keeper'
{$, _} = $$.library

EventEmitter = require 'events'
class QqEmitter extends EventEmitter

cheerio = require 'cheerio'
{Chromeless} = require 'chromeless'
chrome = null

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
  delay(time)
  enter(type, name)
  enterNav(name)
  error(msg)
  getDataMessage($el)
  getDataRoom($el)
  getListNotify()
  getListSession()
  getOwnNickname()
  isIndoor()
  leave()
  login()
  removeWatch(type, name)
  say(listMsg)
  speak(msg)
  start()
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
    await @delay()
    try html = await chrome.html()
    catch err
      # $.i err
      html = ''
    dom = cheerio.load html
    dom selector

  addWatch: (type, name) ->

    i = _.findIndex @listWatch, {type, name}
    if i != -1 then return

    @listWatch.push {type, name}
    @emitter.emit 'add-watch', {type, name}

  delay: (time = 500) ->
    token = 'alice.delay'
    $.info.pause token
    await $$.delay time
    $.info.resume token

  enter: (type, name) ->

    if await @isIndoor()
      await @leave()

    listSession = await @getListSession()

    unless type in @listRoomType
      return @error "invalid room type '#{type}'"

    data = _.find listSession, {type, name}
    if !data
      $.i listSession
      $.info 'listSession'
      return @error "invalid room name '#{name}'"
    {id} = data

    await chrome.click "##{id}"
    .html()

    await @delay()

    unless await @isIndoor()
      await @delay()
      return await @enter type, name

    @statusRoom = data
    @listHistory[id] or= {}

    @emitter.emit 'enter', {type, name}

  enterNav: (name) ->

    res = await chrome.exists "##{name}.selected"
    if res then return

    await chrome.click "##{name}"
    .html()

    await @delay()
    await @enterNav name

  error: (msg) -> @emitter.emit 'error', msg

  getDataMessage: ($el) ->
    name = _.trim $el.children('p.chat_nick').text()
    content = _.trim $el.children('p.chat_content').text()
    {name, content} # return

  getDataRoom: ($el) ->

    id = $el.attr 'id'

    type = $el.attr '_type'
    unless type in @listRoomType then return

    $nick = $el.find 'p.member_nick'
    name = if ($true = $nick.children 'span').length
      $true.text()
    else $nick.text()
    name = _.trim name

    {id, type, name} # return

  getListNotify: ->

    data = []

    $child = await @$ '#current_chat_list > li.notify'
    $child.each (i) =>
      data.push @getDataRoom $child.eq i

    data

  getListSession: ->

    data = []

    $child = await @$ '#current_chat_list > li'
    $child.each (i) =>
      data.push @getDataRoom $child.eq i

    data

  getOwnNickname: ->
    $nickname = await @$ '#mainTopAll span.user_nick'
    _.trim $nickname.text()

  isIndoor: ->
    $target = await @$ '#panel-5'
    if !$target.length then return false
    $target.css('display') == 'block'

  leave: ->

    unless await @isIndoor() then return

    {type, name} = @statusRoom

    selector = '#panelRightButton-5'
    await chrome.click selector
    .html()

    await @delay()
    @emitter.emit 'leave', {type, name}

  login: ->

    chrome = new Chromeless()

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

    $.info 'alice', 'Alice is waiting for login'

    selector = '#current_chat_list > li.list_item'
    await chrome.wait selector, timeout
    .html()

    @nickname = await @getOwnNickname()
    @emitter.emit 'login'

  removeWatch: (type, name) ->

    i = _.findIndex @listWatch, {type, name}
    if i == -1 then return

    @listWatch.splice i, 1
    @emitter.emit 'remove-watch', {type, name}

  say: (listMsg, isBreak = false) ->

    listMsg = switch $.type listMsg
      when 'array' then _.clone listMsg
      when 'number', 'string' then [listMsg]
      else throw new Error 'invalid type'

    if !isBreak
      return await @speak listMsg.join '\r\n'

    for msg in listMsg
      await @speak msg

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

  watch: ->

    listNotify = await @getListNotify()
    if !listNotify.length
      await @delay 200
      return await @watch()

    for dataRoom in listNotify

      {id, type, name} = dataRoom
      unless _.find @listWatch, {type, name} then continue

      await @enter type, name

      listMessage = []
      $child = await @$ '#panelBody-5 .chat_content_group.buddy'
      $child.each (i) =>
        listMessage.push @getDataMessage $child.eq i

      listMessage.reverse()
      index = _.findIndex listMessage, @listHistory[id]
      @listHistory[id] = listMessage[0]
      listMessage = do ->
        if index == -1
          return listMessage
        listMessage[0...index]
      listMessage.reverse()

      if !listMessage.length
        await @leave()
        continue

      @emitter.emit 'hear', listMessage

    # loop
    await @delay()
    await @watch()

# return
module.exports = (arg...) -> new Qq arg...