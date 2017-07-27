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

class Wenku8

  constructor: ->

    ###

    download(url, target)

    ###

  download: co (url, target) ->

    iconv = require 'iconv-lite'

    html = yield $.get url

    buffer = iconv.encode html, 'binary'

    #buffer = new Buffer html, 'binary'
    html = iconv.decode buffer, 'gbk'

    dom = cheerio.load html

    dom('td.vcss').each ->

      $title = dom @

      title = _.trim $title.text()

      $.i title

# return
module.exports = (arg...) -> new Wenku8 arg...