# require

$$ = require 'fire-keeper'
{$, _, Promise} = $$.library
co = Promise.coroutine

fs = require 'fs'
path = require 'path'

cheerio = require 'cheerio'

# function

fn = {}

###

  getResourceList()

###

fn.getResourceList = co ->

  # try to get list from disk

  if fs.existsSync './save/josh.json'
    res = $.parseJson $.parseString fs.readFileSync './save/josh.json'
    return res

  # if there has got no save file
  # get list from net

  res = {}

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

      title = _.trim $a.closest('div.srcdiv').prev().children('a').text()
      src = $a.attr 'href'

      if !~src.search 'http'
        src = "http://josh.agarrado.net/music/anime/#{src}"

      res[title] or= []
      res[title].push src

  # unique & sort
  for key in res
    res[key] = _.sort _.uniq res[key]

  # save
  yield $$.mkdir './save'
  fs.writeFileSync './save/josh.json', $.parseString res

  $.info 'josh', 'got resource list'

  # return
  res

# return
module.exports = fn