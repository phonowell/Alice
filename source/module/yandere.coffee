$ = require 'fire-keeper'
{_} = $

cheerio = require 'cheerio'

class M

  ###
  listIndex
  mapRule
  pathStorage

  ask_()
  downloadImage_()
  downloadIndex_(pageNo)
  execute_()
  getFilename(string)
  getIndex_()
  seekContent_(pageNo)
  seekIndex_()
  ###

  listIndex: []
  mapRule:
    origin:
      attr: 'href'
      selector: '#post-list-posts a.directlink'
      timeout: 60e3
    thumb:
      attr: 'src'
      selector: '#post-list-posts a.thumb > img'
      timeout: 20e3
  pathStorage: '~/Downloads/yandere'

  ask_: ->
    
    if @keyword and @type
      return

    {keyword, type} = $.argv

    # keyword

    keyword or= await $.prompt_
      id: 'keyword-yandere'
      type: 'text'
      message: 'input a keyword'

    unless keyword?.length
      throw new Error "invalid keyword '#{keyword}'"

    @keyword = keyword

    # type

    listType = [
      'origin'
      'thumb'
    ]

    type or= await $.prompt_
      id: 'type-yandere'
      type: 'select'
      message: 'select type'
      list: listType

    unless type in listType
      throw new Error "invalid type '#{type}'"

    @type = type

    @ # return

  downloadImage_: ->

    pathStorage = "#{@pathStorage}/#{@keyword}/#{@type}"
    {timeout} = @mapRule[@type]
    
    for url in @listIndex
      
      filename = @getFilename url
      isExisted = await $.isExisted_ "#{pathStorage}/#{filename}"
      if isExisted
        # $.i "'#{filename}' already existed"
        continue

      await $.download_ url, pathStorage, {filename, timeout}

    @ # return

  downloadIndex_: (pageNo = 1) ->
    
    filename = "#{pageNo}.html"
    pathTemp = "./temp/yandere/#{@keyword}"
    url = [
      'https://yande.re/post?'
      "page=#{pageNo}"
      '&tags='
      _.trim(@keyword).replace /\s+/g, '+'
    ].join ''

    isExisted = await $.isExisted_ "#{pathTemp}/#{filename}"
    if isExisted
      return

    await $.download_ url, pathTemp, filename
    
    @ # return

  execute_: ->
    
    await @ask_()
    await @getIndex_()

    try
      await @downloadImage_()
      await $.say_ 'mission completed'
    catch e
      $.i e.stack
      await @execute_()
      process.exit()

    @ # return

  getFilename: (string) ->

    filename = $.getFilename string
    .replace /\%20/g, ' '
    .replace /\%28/g, ''
    .replace /\%29/g, ''
    .replace 'yande.re', ''

    # return
    _.trim filename

  getIndex_: ->

    pathIndex = "./temp/yandere/#{@keyword}/#{@type}.json"

    isExisted = await $.isExisted_ pathIndex
    unless isExisted
      await @seekIndex_()
      return @

    stat = await $.stat_ pathIndex
    unless _.now() - stat.ctime < 864e5
      await @seekIndex_()
      return @

    @listIndex = await $.read_ pathIndex
    @ # return

  seekContent_: (pageNo) ->

    dom = cheerio.load await $.read_ "./temp/yandere/#{@keyword}/#{pageNo}.html"

    {attr, selector} = @mapRule[@type]

    $el = dom selector

    listResult = []
    $el.each (n) ->
      listResult.push $el.eq(n).attr attr

    @listIndex = [@listIndex..., listResult...]

    @ # return

  seekIndex_: ->

    # first page
    await @downloadIndex_ 1

    # get max
    dom = cheerio.load await $.read_ "./temp/yandere/#{@keyword}/1.html"
    $el = dom '#paginator'
    text = _.trim($el.text()).replace /\s+/g, '|'
    listNumber = text.split '|'
    max = _.max (parseInt n for n in listNumber)
    max or= 1

    # if max > 10
    #   answer = await $.prompt_
    #     type: 'confirm'
    #     message: "found '#{max}' pages, continue?"
    #     default: true
    #   unless answer
    #     throw new Error 'user canceled'

    # download all index pages
    for n in [2..max]
      await @downloadIndex_ n

    # seek content from index pages
    for n in [1..max]
      await @seekContent_ n

    @listIndex = _.uniq @listIndex
    await $.write_ "./temp/yandere/#{@keyword}/#{@type}.json", @listIndex

    @ # return
  

# return
module.exports = ->
  m = new M()
  await m.execute_()