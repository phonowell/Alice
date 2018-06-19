# require

$ = require 'fire-keeper'
{_} = $

cheerio = require 'cheerio'
puppeteer = require 'puppeteer'

# class

class Sankaku

  ###
  base
  ###

  base: do ->
    mapPath =
      macos: '~/Downloads/sankaku'
      windows: 'F:/sankaku'
    mapPath[$.os] or throw new Error "invalid os '#{$.os}'"

  ###
  buildMap_()
  clean_()
  downloadImage_(target, url)
  download_(target)
  executeList_()
  execute_(target)
  getFilename(url)
  getList_(page)
  getMap_(target)
  getSource(html)
  getSource_(url)
  ###

  buildMap_: ->
    $.info 'step', 'buildMap_'
    
    listPost = await @getList_()

    map = {}
    for key in listPost
      map[key] = null

    await $.write_ "#{@base}/_index/#{@name}.json", map

    map # return

  clean_: -> await $.remove_ "#{@base}/_index"

  downloadImage_: (content, pathDownload) ->
    $.info 'step', 'downloadImage_'

    {cookie, filename, source} = content

    isExisted = await $.isExisted_ "#{@base}/#{@name}/#{filename}"
    if isExisted then return await $.delay_ 2e3

    listCookie = []

    for item in cookie
      if item.domain != 'chan.sankakucomplex.com' then continue
      listCookie.push "#{item.name}=#{item.value}"

    stringCookie = listCookie.join '; '

    await $.download_ source, pathDownload,
      filename: filename
      headers:
        cookies: stringCookie

  download_: ->
    $.info 'step', 'download_'

    pathIndex = "#{@base}/_index/#{@name}.json"
    pathDownload = "#{@base}/#{@name}"
    mapIndex = await $.read_ pathIndex

    for urlPost, filename of mapIndex

      if filename and $.isExisted_ "#{pathDownload}/#{filename}"
        continue

      content = await @getSource_ urlPost
      if !content then continue
      await @downloadImage_ content, pathDownload

      mapIndex[urlPost] = content.filename
      await $.write_ pathIndex, mapIndex

      # delay
      await $.delay_ 1e3

  executeList_: ->
    $.info 'step', 'executeList_'

    listName = [
      # 'branch (blackrabbits)'
      # 'faustsketcher'
      # 'fay'
      # 'gorgeous mushroom'
      # 'haitukun'
      # 'hakaba'
      # 'ke-ta'
      'kobayashi chisato'
      # 'kou mashiro'
      'lasterk'
      # 'letdie1414'
      # 'mamuru'
      # 'mercurymaster'
      # 'misak kurehito'
      # 'oda non'
      # 'osiimi'
      # 'osuma toruko'
      # 'roropull'
      # 'ryo'
      # 'sakimichan'
      # 'sawayaka samehada'
      # 'shimakaze'
      # 'souji hougu'
      # 'suzune rena'
      'nakadori (movgnsk)'
      # 'try'
      # 'yang-do'
    ]

    for name in listName

      if name[0] == '!' then continue

      name = name
      .replace /\s+/g, '_'
      .replace /\(/g, '%28'
      .replace /\)/g, '%29'
      
      await @execute_ name

  execute_: (target) ->
    $.info 'step', 'execute_'

    # set name
    @query = target
    @name = @query
    .replace /_+/g, ' '
    .replace /\%28/g, ''
    .replace /\%29/g, ''

    # list all post
    await @getMap_()
    
    # download
    await @download_()

    if @browser then await @browser.close()
    await $.say_ "mission '#{target}' completed"

  getFilename: (url) ->
    string = url.replace /\?.*/, ''
    _.last string.split '/'

  getList_: (page = 1, listResult = []) ->
    $.info 'step', 'getList_'

    url = "https://chan.sankakucomplex.com/post/index.content?tags=#{@query}&page=#{page}"

    try html = await $.get url
    catch then return listResult

    $$ = cheerio.load html
    $a = $$ 'a'
    
    if $a.length

      $a.each ->
        listResult.push $$(@).attr 'href'

      await $.delay_ 1e3
      return await @getList_ page + 1, listResult

    # return
    _.uniq listResult

  getMap_: (target) ->
    $.info 'step', 'getMap_'

    pathIndex = "#{@base}/_index/#{@name}.json"
    mapResult = await $.read_ pathIndex

    if mapResult then return mapResult

    await @buildMap_() # return

  getSource: (html) ->

    $$ = cheerio.load html

    $el = $$ '#image-link'
    if $el.length

      src = $el.attr 'href'
      if src then return src
      
      $el = $el.find 'img'
      src = $el.attr 'src'
      return src

    $el = $$ '#image'
    if $el.length
      return $el.attr 'src'

    return null

  getSource_: (urlPost) ->
    $.info 'step', 'getSource_'

    @browser or= await puppeteer.launch()

    # get content
    [html, cookie] = await new Promise (resolve) =>

      page = await @browser.newPage()

      page.once 'load', ->

        html = await page.content()
        cookie = await page.cookies()

        await page.close()

        # return
        resolve [html, cookie]

      await page.goto "https://chan.sankakucomplex.com#{urlPost}"

    source = @getSource html
    if !source then return null

    filename = @getFilename source
    source = "https:#{source}"

    # return
    {cookie, filename, source}
  
# return
module.exports = (arg...) -> new Sankaku arg...