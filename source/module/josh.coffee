# require

$ = require 'fire-keeper'
{_} = $.library

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

  download: ->

    resourceList = await @getResourceList()

    base = switch $.os
      when 'macos' then '~/Downloads'
      when 'windows' then 'F:'

    open = switch $.os
      when 'macos' then 'open'
      when 'windows' then 'start'

    for title, list of resourceList
      for url in list

        filename = path.basename url
        if await $.isExisted "#{base}/midi/#{title}/#{filename}"
          continue

        await $.remove "#{base}/#{filename}"

        await $.shell "#{open} #{url}"

        await $.delay 5e3

        await $.copy "#{base}/#{filename}"
        , "#{base}/midi/#{title}"

        await $.remove "#{base}/#{filename}"

    $.info 'josh', 'task finished'

  downloadPage: ->

    tagList = 'abcdefghijklmnopqrstuvwxyz'.toUpperCase().split ''
    tagList.unshift '0-9'

    for tag in tagList

      target = './temp/josh/page'
      filename = "#{tag.toLowerCase()}.html"

      if await $.isExisted "#{target}/#{filename}" then continue

      url = "http://josh.agarrado.net/music/anime/index.php?startswith=#{tag}"

      await $.download url, target, filename

    $.info 'josh', 'all pages downloaded'

  getResourceList: ->

    # try to get list from disk

    source = './temp/josh/resource.json'

    if await $.isExisted source
      return await $.read source

    # if there has got no resource list
    # get list from net

    await @downloadPage()

    list = {}

    tagList = 'abcdefghijklmnopqrstuvwxyz'.split ''
    tagList.unshift '0-9'

    for tag in tagList

      html = await $.read "./temp/josh/page/#{tag}.html"

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

    await $.write source, content

    $.info 'josh', 'got resource list'

    # return
    await $.read source

# return
module.exports = (arg...) -> new Josh arg...