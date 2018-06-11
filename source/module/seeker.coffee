# require

$ = require 'fire-keeper'
{_} = $.library

cheerio = require 'cheerio'

# class

class Seeker

  ###
  base
  map
  setting
  ###

  base: './temp'

  map:

    acfun:
      title: 'AcFun文章区'
      url: 'http://www.acfun.cn/v/list63/index.htm'
      selector: 'a.atc-title'
      option:
        replaceUrl: (url) -> "http://www.acfun.cn#{url}"

    alloyteam:
      title: 'AlloyTeam'
      url: 'http://www.alloyteam.com/page/0'
      selector: '#content a.blogTitle'

    appinn:
      title: '小众软件'
      url: 'http://www.appinn.com'
      selector: 'h2.entry-title > a'
      option:
        titleByTitle: true

    iplaysoft:
      title: '异次元软件世界'
      url: 'http://www.iplaysoft.com'
      selector: 'h2.entry-title > a'

    ryf:
      title: '阮一峰的网络日志'
      url: 'http://www.ruanyifeng.com/blog/archives.html'
      selector: '#alpha-inner ul.module-list a'

    waitsun:
      title: '爱情守望者'
      url: [
        'https://www.waitsun.com/page/2'
        'https://www.waitsun.com/page/3'
      ]
      selector: 'article .header a'

    williamlong:
      title: '月光博客'
      url: 'http://www.williamlong.info'
      selector: 'h2.post-title > a'

    zxx:
      title: '鑫空间'
      url: 'http://www.zhangxinxu.com/wordpress'
      selector: 'a.entry-title'
      # option:
      #   replaceTitle: (title) -> title.replace /的永久链接/, ''

  setting:
    expire: 3e5 # 5 min
    size: 200 # cache size

  ###
  clear_()
  downloadPage_(data)
  execute_(name)
  genHtml(map)
  getData_(name)
  getFilename(url)
  getHtml_(data)
  getLink(listHtml, data)
  openPage_(html)
  unique_(listLink, data)
  ###

  clear_: -> await $.remove './temp/seeker'

  downloadPage_: (data) ->

    for url in data.url

      filename = @getFilename url
      stat = await $.stat "#{@base}/seeker/page/#{filename}"

      if stat and _.now() - stat.ctime.getTime() < @setting.expire
        continue

      await $.download url, "#{@base}/seeker/page",
        filename: filename
        timeout: 1e4

  execute_: (name) ->

    # await @clear_()

    listTask = if name
      [name]
    else [
      'AcFun'
      'AlloyTeam'
      'AppInn'
      'iPlaySoft'
      'Ryf'
      'waitSun'
      'williamLong'
      'Zxx'
    ]

    map = {}
    for name in listTask

      $.info.pause 'seeker.execute_'

      data = await @getData_ name
      await @downloadPage_ data
      listHtml = await @getHtml_ data
      listLink = @getLink listHtml, data

      $.info.resume 'seeker.execute_'
      
      if !listLink.length
        $.info 'warning', "'#{data.title}' might be not useable"

      $.info.pause 'seeker.execute_'
      
      map[data.title] = await @unique_ listLink, data

      $.info.resume 'seeker.execute_'

    html = @genHtml map
    await @openPage_ html

  genHtml: (map) ->

    html = []

    for title, listLink of map when listLink.length
      html.push "<h1>#{title}</h1>"
      for item in listLink
        html.push "<a href='#{item.url}' target='_blank'>#{item.title}</a>"

    # return
    html.join '<br>'

  getData_: (name) ->

    if !name
      throw new Error 'empty name'

    name = name.toLowerCase()
    data = _.get @map, name

    if !data
      throw new Error "invalid name '#{name}'"

    # url

    url = data.url
    type = $.type url

    if type == 'string'
      data.url = [url]
    else if type != 'array'
      throw new Error "invalid type '#{type}'"

    # option
    data.option or= {}
    
    data # return

  getFilename: (url) ->

    url = _.trim url.replace(/.*\/{2}/, ''), '/'
    url = url.replace /www\./, ''
    .replace /\.(?:asp|aspx|htm|html|php|shtml)/, ''
    .replace /\//g, '-'

    "#{url}.html"

  getHtml_: (data) ->

    listResult = []

    for url in data.url

      filename = @getFilename url
      html = await $.read "#{@base}/seeker/page/#{filename}"

      listResult.push html

    listResult # return

  getLink: (listHtml, data) ->

    ts = _.now()
    listResult = []

    for html in listHtml

      dom = cheerio.load html

      dom data.selector
      .each ->

        $a = dom @

        # time
        time = ts++

        # title

        value = data.option.titleByTitle
        title = if value
          $a.attr 'title'
        else $a.text()

        fn = data.option.replaceTitle
        if fn
          title = fn title

        title = _.trim title
        title or= 'blank'

        # url

        url = $a.attr 'href'

        fn = data.option.replaceUrl
        if fn
          url = fn url

        # push
        listResult.push {time, title, url}

    # return
    _.uniqBy listResult, 'url'

  openPage_: (html) ->

    if !html.length
      return $.info 'seeker', 'got no result(s)'

    target = "#{@base}/seeker/result.html"

    method = switch $.os
      when 'linux', 'macos' then 'open'
      when 'windows' then 'start'
      else throw new Error "invalid os <#{$.os}>"

    $.info.pause 'seeker.openPage_'
    await $.write target, html
    await $.shell "#{method} #{target}"
    $.info.resume 'seeker.openPage_'

  unique_: (listLink, data) ->

    source = "#{@base}/seeker/list/#{data.title}.json"
    listSource = await $.read source
    listSource or= []

    listResult = _.differenceBy listLink, listSource, 'url'

    # save to disk
    listTarget = _.concat listSource, listLink
    listTarget = _.uniqBy listTarget, 'url'
    listTarget = _.sortBy listTarget, 'time'
    listTarget = _.reverse listTarget
    listTarget = listTarget[0...@setting.size]
    await $.write source, listTarget

    listResult # return

# return
module.exports = (arg...) -> new Seeker arg...