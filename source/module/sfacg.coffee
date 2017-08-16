# require

$$ = require 'fire-keeper'
{$, _, Promise} = $$.library
co = Promise.coroutine

fs = require 'fs'
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

  checkIsValid: co (url) ->

    html = yield $.get url
    dom = cheerio.load html

    $operation = dom '#BasicOperation'
    if !$operation.length then return false
    if !~$operation.text().search '更新章节' then return false

    true

  download: co (list) ->

    for a in list

      filename = path.basename a.source

      if yield $$.isExisted "#{@base}/#{filename}" then continue

      $.info.pause 'sfacg.download'
      yield $$.shell "#{@open} #{a.source}"
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

  get: co (url) ->

    urlList = @formatUrl url

    $.info 'sfacg', urlList[0]

    isValid = yield @checkIsValid urlList[0]
    if !isValid
      $.info 'sfacg', 'passed invalid url'
      return

    resourceList = yield @getResourceList urlList[1]
    if !resourceList.length then return

    yield @download resourceList

    time = 5e3 + (resourceList.length - 1) * 1e3
    $.info 'sfacg', "should wait '#{time} ms' for downloading"
    yield $$.delay time

    yield @rename resourceList
    yield @zip resourceList

  getResourceList: co (url) ->

    html = yield $.get url
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

  rename: co (list) ->

    for a in list

      filename = path.basename a.source

      unless yield $$.isExisted "#{@base}/#{filename}" then continue

      yield $$.rename "#{@base}/#{filename}", "#{a.title}.txt"

  zip: co (list) ->

    title = list[0].title.replace /.*【/g, ''
    .replace /】.*/, ''
    title = _.trim title

    fileList = ("#{@base}/#{a.title}.txt" for a in list)

    yield $$.zip fileList, "#{@base}/", "#{title}.zip"
    yield $$.remove fileList

# return
module.exports = (arg...) -> new Sfacg arg...