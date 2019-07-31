$ = require 'fire-keeper'
_ = require 'lodash'
cheerio = require 'cheerio'

class M

  ###
  setting
    life
    size
    temp
  ---
  download_(option)
  execute_()
  getLink_(html, selector)
  makeHtml(map)
  unique_(name, list)
  view_(html)
  ###

  setting:
    life: 3e5 # 5 min
    size: 200 # cache size
    temp: './temp/seek'

  # ---

  download_: ({name, source, url}) ->

    browser = $.require './source/module/browser'

    await browser.launch_()
    {html} = await browser.content_ url
    await browser.close_()
    
    await $.write_ source, html

    html # return

  execute_: ->

    mapResult = {}

    for name, data of await $.read_ './data/seek.yaml'

      {selector, title, url} = data

      source = "#{@setting.temp}/#{name}.html"
      stat = await $.stat_ source

      html = if stat and _.now() - stat.ctime.getTime() < @setting.life
        await $.read_ source
      else await @download_ {name, source, url}

      listLink = await @getLink html, selector
      unless listLink.length
        $.info 'warning'
        , "'#{title}' might be not useable"
        continue

      mapResult[title] = await @unique_ name, listLink

    html = @makeHtml mapResult
    await @view_ html

    @ # return

  getLink: (html, selector) ->

    listResult = []
    dom = cheerio.load html

    dom selector
    .each ->

      $a = dom @

      time = _.now()
      title = $a.text().trim()
      url = $a.attr 'href'

      listResult.push {time, title, url}

    # return
    _.uniqBy listResult, 'url'

  makeHtml: (map) ->

    html = []

    for title, list of map when list.length
      html.push "<h1>#{title}</h1>"
      for item in list
        html.push "<a href='#{item.url}' target='_blank'>#{item.title}</a>"

    # return
    html.join '<br>'

  unique_: (name, list) ->

    source = "#{@setting.temp}/#{name}.json"
    
    listSource = await $.read_ source
    listSource or= []

    listResult = _.differenceBy list, listSource, 'url'

    # save
    listTarget = [
      listSource...
      list...
    ]
    listTarget = _.uniqBy listTarget, 'url'
    listTarget = _.sortBy listTarget, 'time'
    listTarget = _.reverse listTarget
    listTarget = listTarget[0...@setting.size]
    await $.write_ source, listTarget

    listResult # return

  view_: (html) ->

    unless html.length
      return $.info 'seeker', 'got no result(s)'

    target = "#{@setting.temp}/result.html"

    method = switch $.os()
      when 'linux', 'macos' then 'open'
      when 'windows' then 'start'
      else throw new Error "invalid os <#{$.os()}>"

    await $.info().silence_ ->
      await $.write_ target, html
      await $.exec_ "#{method} #{target}"

    @ # return

# return
module.exports = ->
  m = new M()
  await m.execute_()