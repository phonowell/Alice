# require

$$ = require 'fire-keeper'
{$, _} = $$.library

path = require 'path'

cheerio = require 'cheerio'

# class

class Sfacg

  constructor: ->

    @base = switch $$.os
      when 'macos' then '~/Downloads'
      when 'windows' then 'F:'

    @open = switch $$.os
      when 'macos' then 'open'
      when 'windows' then 'start'

  ###

  checkIsValid(url)
  download(list)
  formatUrl(url)
  get(url)
  getResourceList(url)
  rename(list)
  zip(list)

  ###

  checkIsValid: (url) ->

    html = await $.get url
    dom = cheerio.load html

    $operation = dom '#BasicOperation'
    if !$operation.length then return false
    if !~$operation.text().search '更新章节' then return false

    true

  download: (list) ->

    for a in list

      filename = path.basename a.source

      if await $$.isExisted "#{@base}/#{filename}" then continue

      $.info.pause 'sfacg.download'
      await $$.shell "#{@open} #{a.source}"
      $.info.resume 'sfacg.download'

      $.info 'sfacg', "downloaded '#{a.source}'"

  formatUrl: (url) ->

    list = if ~url.search 'MainIndex'
      [
        url.replace /MainIndex/, ''
        url
      ]
    else
      [
        url
        "#{_.trim url, '/'}/MainIndex"
      ]

    ($.trim href, '/' for href in list)

  get: (url) ->

    urlList = @formatUrl url

    $.info 'sfacg', urlList[0]

    isValid = await @checkIsValid urlList[0]
    if !isValid
      $.info 'sfacg', 'passed invalid url'
      return

    resourceList = await @getResourceList urlList[1]
    if !resourceList.length then return

    await @download resourceList

    time = 5e3 + (resourceList.length - 1) * 1e3
    $.info 'sfacg', "should wait '#{time} ms' for downloading"
    await $$.delay time

    await @rename resourceList
    await @zip resourceList

  getResourceList: (url) ->

    html = await $.get url
    dom = cheerio.load html

    res = []

    dom 'h3.catalog-title'
    .each (i) ->

      # title

      $title = dom @
      title = $title.text()
      .replace /[\\\/:*?"<>|]/g, ''
      .replace /\[/g, '【'
      .replace /\]/g, '】'
      title = "#{1 + i} - #{_.trim title}"

      # source

      source = $title.next().find('p.row').eq(0).children('a').attr 'href'
      if !~source.search /http/
        source = "http://book.sfacg.com#{source}"

      res.push {title, source}

    # return
    res

  rename: (list) ->

    for a in list

      filename = path.basename a.source

      unless await $$.isExisted "#{@base}/#{filename}" then continue

      await $$.rename "#{@base}/#{filename}", "#{a.title}.txt"

  zip: (list) ->

    title = list[0].title.replace /.*【/g, ''
    .replace /】.*/, ''
    title = _.trim title

    fileList = ("#{@base}/#{a.title}.txt" for a in list)

    await $$.zip fileList, "#{@base}/", "#{title}.zip"
    await $$.remove fileList

# return
module.exports = (arg...) -> new Sfacg arg...