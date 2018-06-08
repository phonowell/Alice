# require

$ = require 'fire-keeper'
{_} = $.library

path = require 'path'

cheerio = require 'cheerio'
{Chromeless} = require 'chromeless'

# class

class Wnacg

  constructor: -> @

  ###

  download(list)
  execute()
  search(reg)

  ###

  download: (list) ->

    chrome = new Chromeless()

    for item in list

      html = await chrome
      .goto "http://www.wnacg.org/download-index-aid-#{item.id}.html"
      .html()

      dom = cheerio.load html

      url = dom('a.down_btn').eq(0).attr 'href'
      filename = _.trim "#{item.title}.zip"
      
      await $.download url
      , '~/Downloads/wnacg'
      , filename

    await chrome.end()

  execute: ->

    list = await @search /digital lover/i
    await @download list

  search: (reg) ->

    db = await $.read './temp/wnacg/db/db.json'

    list = []
    for item in db
      
      unless ~item.title.search reg
        continue

      list.push item

    list

# return
module.exports = (arg...) -> new Wnacg arg...