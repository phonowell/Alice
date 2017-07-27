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

class Sfacg

  constructor: ->

  ###

    download(list)
    getResourceList(url)
    rename(list)

  ###

  download: co (list) ->

    for a in list

      filename = path.basename a.source

      if fs.existsSync "F:/#{filename}" then continue

      yield $$.shell "start #{a.source}"

  getResourceList: co (url) ->

    html = yield $.get url
    dom = cheerio.load html

    res = []

    dom('h3.catalog-title').each ->

      # title

      $title = dom @
      title = _.trim $title.text()

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

      if !fs.existsSync "F:/#{filename}" then continue

      yield $$.copy "F:/#{filename}", 'F:/', "#{a.title}.txt"
      yield $$.remove "F:/#{filename}"

# return
module.exports = (arg...) -> new Sfacg arg...