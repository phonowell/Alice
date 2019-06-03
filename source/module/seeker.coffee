$ = require 'fire-keeper'
{_} = $

cheerio = require 'cheerio'

class M

  ###
  browser
  pathTemp
  setting

  download_(rule)
  execute_(name)
  getFilename(url)
  getHtml_(data)
  getLink_(rule)
  getRule(name)
  loadRule_()
  makeHtml(map)
  seekTitle($el, [option])
  seekUrl($el, [option])
  setTarget_()
  unique_(listLink, rule)
  view_(html)
  ###

  browser: do ->
    m = $.fn.require './source/module/browser.coffee'
    m()

  pathTemp: './temp/seeker'

  setting:
    expire: 3e5 # 5 min
    size: 200 # cache size

  download_: (rule) ->

    for url in rule.url

      filename = @getFilename url
      stat = await $.stat_ "#{@pathTemp}/page/#{filename}"

      if stat and _.now() - stat.ctime.getTime() < @setting.expire
        continue

      # download
      try
        if rule.option.viaBrowser
          await @browser.launch_()
          {html} = await @browser.content_ url
          await @browser.close_()
          await $.write_ "#{@pathTemp}/page/#{filename}", html
        else
          await $.download_ url, "#{@pathTemp}/page",
            filename: filename
            timeout: 1e4
      catch err
        $.i err.stack

    @ # return

  execute_: ->

    # load rule
    await @loadRule_()
    await @setTarget_()

    mapResult = {}
    for name in @listTarget

      rule = @getRule name
      await @download_ rule
      listLink = await @getLink_ rule

      unless listLink.length
        $.info 'warning'
        , "'#{rule.title}' may be not useable"
        continue

      mapResult[rule.title] = await @unique_ listLink, rule

    html = @makeHtml mapResult
    await @view_ html

    @ # return

  getFilename: (url) ->

    url = _.trim url.replace(/.*\/{2}/, ''), '/'
    url = url.replace /www\./, ''
    .replace /\.(?:asp|aspx|htm|html|php|shtml)/, ''
    .replace /\//g, '-'

    "#{url}.html" # return

  getHtml_: (rule) ->

    listResult = []

    for url in rule.url

      filename = @getFilename url
      html = await $.read_ "#{@pathTemp}/page/#{filename}"

      unless html
        continue

      listResult.push html

    listResult # return

  getLink_: (rule) ->

    ts = _.now()
    listResult = []

    for html in await @getHtml_ rule

      unless html
        continue

      dom = cheerio.load html
      seekTitle = @seekTitle
      seekUrl = @seekUrl

      dom rule.selector
      .each ->

        $a = dom @

        # time
        time = ts++

        title = seekTitle $a, rule.option
        url = seekUrl $a, rule.option

        # push
        listResult.push {time, title, url}

    # return
    _.uniqBy listResult, 'url'

  getRule: (name) ->
    
    data = @mapRule[name]

    # url

    url = data.url
    type = $.type url

    unless type in ['array', 'string']
      throw new Error "invalid type '#{type}'"

    if type == 'string'
      data.url = [url]

    # option
    data.option or= {}
    
    data # return

  loadRule_: ->
    
    @mapRule = {}
    listSource = await $.source_ './data/seeker/*.yaml'
    for source in listSource
      name = $.getBasename source
      @mapRule[name] = await $.read_ source

    @ # return

  makeHtml: (map) ->

    html = []

    for title, listLink of map when listLink.length
      html.push "<h1>#{title}</h1>"
      for item in listLink
        html.push "<a href='#{item.url}' target='_blank'>#{item.title}</a>"

    html.join '<br>' # return

  seekTitle: ($el, option = {}) ->

    title = $el.text()

    fn = option.replaceTitle
    if fn
      title = fn title

    title = _.trim title
    title or= 'blank' # return

  seekUrl: ($el, option = {}) ->

    url = $el.attr 'href'

    string = option.replaceUrl
    if string
      url = string.replace /#\{url\}/g, url

    url # return

  setTarget_: ->

    listTarget = _.keys @mapRule
    listTarget.unshift 'all'

    {target} = $.argv
    target or= 'all'
    unless target in listTarget
      throw new Error "invalid target '#{target}'"
    @listTarget = if target == 'all'
      listTarget[1...]
    else [target]

    @ # return

  unique_: (listLink, rule) ->

    pathSource = "#{@pathTemp}/list/#{rule.title}.json"
    listSource = await $.read_ pathSource
    listSource or= []

    listResult = _.differenceBy listLink, listSource, 'url'

    # save to disk
    listTarget = _.concat listSource, listLink
    listTarget = _.uniqBy listTarget, 'url'
    listTarget = _.sortBy listTarget, 'time'
    listTarget = _.reverse listTarget
    listTarget = listTarget[0...@setting.size]
    await $.write_ pathSource, listTarget

    listResult # return

  view_: (html) ->

    unless html.length
      return $.info 'seeker', 'got no result(s)'

    target = "#{@pathTemp}/result.html"

    method = switch $.os
      when 'linux', 'macos' then 'open'
      when 'windows' then 'start'
      else throw new Error "invalid os <#{$.os}>"

    namespace = 'seeker.view'
    $.info.pause namespace
    await $.write_ target, html
    await $.exec_ "#{method} #{target}"
    $.info.resume namespace

    @ # return

# return
module.exports = ->
  m = new M()
  await m.execute_()
