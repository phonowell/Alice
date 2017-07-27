# require

$$ = require 'fire-keeper'
{$, _, Promise} = $$.library
co = Promise.coroutine

fs = require 'fs'
path = require 'path'

cheerio = require 'cheerio'

# function

absPath = (source) -> source.replace /\.\//, "#{process.cwd()}/"

# class

class Josh

  constructor: ->

  ###

  download(resourceList)
  getCookie()
  getResourceList()

  ###

  download: co (resourceList, target) ->

    cookie = yield @getCookie()

    for title, list of resourceList
      for src in list

        filename = path.basename src
        if fs.existsSync "#{target}/#{title}/#{filename}" then continue

        $.info 'josh', "started to download '#{src}'"

        yield $$.download src
        , "#{target}/#{title}",
          headers: {cookie}

  getCookie: co ->

    axios = require 'axios'

    data = yield axios.get 'http://josh.agarrado.net/music/anime/index.php'
    cookieArray = data.request.res.headers['set-cookie']
    cookieArray.join '; '

  getResourceList: co ->

    # try to get list from disk

    if fs.existsSync './save/josh.json'
      res = require absPath './save/josh.json'
      return res

    # if there has got no save file
    # get list from net

    list = {}

    tagList = 'abcdefghijklmnopqrstuvwxyz'.toUpperCase().split ''
    tagList.unshift '0-9'

    for tag in tagList

      html = yield $.get 'http://josh.agarrado.net/music/anime/index.php',
        startswith: tag

      $.info 'josh', "loaded tag/#{tag}"

      dom = cheerio.load html
      dom('a').each ->

        $a = dom @
        if $a.text() != 'mid' then return

        title = $a.closest('div.srcdiv').prev().children('a').text()
        title = _.trim title.replace /[\\\/:*?"<>|]/g, ''
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

    yield $$.mkdir './save'
    fs.writeFileSync './save/josh.json', content

    $.info 'josh', 'got resource list'

    # return
    res

# return
module.exports = (arg...) -> new Josh arg...