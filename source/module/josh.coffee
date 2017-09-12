# require

$$ = require 'fire-keeper'
{$, _, Promise} = $$.library
co = Promise.coroutine

path = require 'path'

cheerio = require 'cheerio'

# class

class Josh

  constructor: -> null

  ###

  download()
  downloadPage()
  getResourceList()

  ###

  download: co ->

    resourceList = yield @getResourceList()

    base = switch $$.os
      when 'macos' then '~/Downloads'
      when 'windows' then 'F:'

    open = switch $$.os
      when 'macos' then 'open'
      when 'windows' then 'start'

    for title, list of resourceList
      for url in list

        filename = path.basename url
        if yield $$.isExisted "#{base}/midi/#{title}/#{filename}"
          continue

        yield $$.remove "#{base}/#{filename}"

        yield $$.shell "#{open} #{url}"

        yield $$.delay 5e3

        yield $$.copy "#{base}/#{filename}"
        , "#{base}/midi/#{title}"

        yield $$.remove "#{base}/#{filename}"

    $.info 'josh', 'task finished'

  downloadPage: co ->

    tagList = 'abcdefghijklmnopqrstuvwxyz'.toUpperCase().split ''
    tagList.unshift '0-9'

    for tag in tagList

      target = './temp/josh/page'
      filename = "#{tag.toLowerCase()}.html"

      if yield $$.isExisted "#{target}/#{filename}" then continue

      url = "http://josh.agarrado.net/music/anime/index.php?startswith=#{tag}"

      yield $$.download url, target, filename

    $.info 'josh', 'all pages downloaded'

  getResourceList: co ->

    # try to get list from disk

    source = './temp/josh/resource.json'

    if yield $$.isExisted source
      return yield $$.read source

    # if there has got no resource list
    # get list from net

    yield @downloadPage()

    list = {}

    tagList = 'abcdefghijklmnopqrstuvwxyz'.split ''
    tagList.unshift '0-9'

    for tag in tagList

      html = yield $$.read "./temp/josh/page/#{tag}.html"

      dom = cheerio.load html
      dom('a').each ->

        $a = dom @
        if $a.text() != 'mid' then return

        title = $a.closest('div.srcdiv').prev().children('a').text()
        title = _.trim title.replace /[\\\/:*?"<>|]/g, ''
        title = title.replace /^\.+/, ''
        src = $a.attr 'href'

        if !~src.search 'http'
          src = "http://josh.agarrado.net/music/anime/#{src}"

        list[title] or= []
        list[title].push src

    # unique & sort

    res = {}

    for key in _.keys(list).sort()
      res[key] = _.uniq(list[key]).sort()

    # save

    content = $.parseString res
    content = content.replace /\s{2,}/g, ' '
    .replace /\\\w/g, ''

    yield $$.write source, content

    $.info 'josh', 'got resource list'

    # return
    yield $$.read source

# return
module.exports = (arg...) -> new Josh arg...
