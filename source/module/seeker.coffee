# require

$ = require 'fire-keeper'
{_} = $

path = require 'path'
cheerio = require 'cheerio'

# class

class M

  ###
  base
  browser
  setting
  ###

  base: './temp'

  browser: do ->
    source = $.fn.normalizePath './source/module/browser.coffee'
    m = require source
    m()

  setting:
    expire: 3e5 # 5 min
    size: 200 # cache size

  ###
  clear_()
  downloadPage_(data)
  execute_(name)
  genHtml(map)
  getData_(name)
  getFilename(url)
  getHtml_(data)
  getLink(listHtml, data)
  getRule_()
  openPage_(html)
  unique_(listLink, data)
  ###

  clear_: -> await $.remove_ './temp/seeker'

  downloadPage_: (data) ->

    for url in data.url

      filename = @getFilename url
      stat = await $.stat_ "#{@base}/seeker/page/#{filename}"

      if stat and _.now() - stat.ctime.getTime() < @setting.expire
        continue

      # download page
      if data.option.viaBrowser
        await @browser.launch_()
        {html} = await @browser.content_ url
        await @browser.close_()
        await $.write_ "#{@base}/seeker/page/#{filename}", html
      else
        await $.download_ url, "#{@base}/seeker/page",
          filename: filename
          timeout: 1e4

  execute_: (name) ->

    listRule = await @getRule_()

    listTask = if name
      [name]
    else _.keys listRule

    map = {}
    for name in listTask

      data = @getData listRule, name
      await @downloadPage_ data
      listHtml = await @getHtml_ data
      listLink = @getLink listHtml, data

      if !listLink.length
        $.info 'warning', "'#{data.title}' might be not useable"

      map[data.title] = await @unique_ listLink, data

    html = @genHtml map
    await @openPage_ html

  genHtml: (map) ->

    html = []

    for title, listLink of map when listLink.length
      html.push "<h1>#{title}</h1>"
      for item in listLink
        html.push "<a href='#{item.url}' target='_blank'>#{item.title}</a>"

    # return
    html.join '<br>'

  getData: (listRule, name) ->

    if !name
      throw new Error 'empty name'

    name = name.toLowerCase()
    data = _.get listRule, name

    if !data
      throw new Error "invalid name '#{name}'"

    # url

    url = data.url
    type = $.type url

    if type == 'string'
      data.url = [url]
    else if type != 'array'
      throw new Error "invalid type '#{type}'"

    # option
    data.option or= {}
    
    data # return

  getFilename: (url) ->

    url = _.trim url.replace(/.*\/{2}/, ''), '/'
    url = url.replace /www\./, ''
    .replace /\.(?:asp|aspx|htm|html|php|shtml)/, ''
    .replace /\//g, '-'

    "#{url}.html"

  getHtml_: (data) ->

    listResult = []

    for url in data.url

      filename = @getFilename url
      html = await $.read_ "#{@base}/seeker/page/#{filename}"

      listResult.push html

    listResult # return

  getLink: (listHtml, data) ->

    ts = _.now()
    listResult = []

    for html in listHtml

      dom = cheerio.load html

      dom data.selector
      .each ->

        $a = dom @

        # time
        time = ts++

        # title

        value = data.option.getTitleViaTitle
        title = if value
          $a.attr 'title'
        else $a.text()

        fn = data.option.replaceTitle
        if fn
          title = fn title

        title = _.trim title
        title or= 'blank'

        # url

        url = $a.attr 'href'

        string = data.option.replaceUrl
        if string
          url = string.replace /#\{url\}/g, url

        # push
        listResult.push {time, title, url}

    # return
    _.uniqBy listResult, 'url'

  getRule_: ->
    
    listSource = await $.source_ './data/seeker/*.yaml'
    
    map = {}
    for source in listSource
      name = $.getBasename source
      map[name] = await $.read_ source

    map # return

  openPage_: (html) ->

    if !html.length
      return $.info 'seeker', 'got no result(s)'

    target = "#{@base}/seeker/result.html"

    method = switch $.os
      when 'linux', 'macos' then 'open'
      when 'windows' then 'start'
      else throw new Error "invalid os <#{$.os}>"

    $.info.pause 'seeker.openPage_'
    await $.write_ target, html
    await $.exec_ "#{method} #{target}"
    $.info.resume 'seeker.openPage_'

  unique_: (listLink, data) ->

    source = "#{@base}/seeker/list/#{data.title}.json"
    listSource = await $.read_ source
    listSource or= []

    listResult = _.differenceBy listLink, listSource, 'url'

    # save to disk
    listTarget = _.concat listSource, listLink
    listTarget = _.uniqBy listTarget, 'url'
    listTarget = _.sortBy listTarget, 'time'
    listTarget = _.reverse listTarget
    listTarget = listTarget[0...@setting.size]
    await $.write_ source, listTarget

    listResult # return

# return
module.exports = (arg...) -> new M arg...