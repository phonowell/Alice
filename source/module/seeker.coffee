# require

$$ = require 'fire-keeper'
{$, _} = $$.library

cheerio = require 'cheerio'
colors = require 'colors/safe'

# class

class Seeker

  constructor: ->

    @base = './temp'

  ###

  diff(title, list, [cacheSize])
  download(list, [lifetime])
  generate(title, list)
  getFilename(url)
  getList(option)
  open()
  seek(name)
  task(name)

  ###

  diff: (title, list, cacheSize = 50) ->

    source = "#{@base}/seeker/list/#{title}.json"
    list = _.uniqBy list, 'url'
    list = _.sortBy list, 'time'

    sourceList = await $$.read source
    sourceList or= []

    res = _.differenceBy list, sourceList, 'url'

    list = _.concat sourceList, list
    list = _.uniqBy list, 'url'
    list = _.sortBy list, 'time'
    list = _.reverse list
    if list.length > cacheSize then list = list[0...cacheSize]
    await $$.write source, list

    return res

  download: (list, lifetime = 3e5) ->

    res = false

    for url in list

      filename = @getFilename url
      stat = await $$.stat "#{@base}/seeker/page/#{filename}"

      if stat and _.now() - stat.ctime.getTime() < lifetime
        continue

      await $$.download url, "#{@base}/seeker/page",
        filename: filename
        timeout: 1e4

      res = true

    # return
    res

  generate: (map) ->

    html = []

    for title, list of map when list.length
      html.push "<h1>#{title}</h1>"
      for a in list
        html.push "<a href='#{a.url}' target='_blank'>#{a.title}</a>"

    # return
    html.join '<br>'

  getFilename: (url) ->

    url = _.trim url.replace(/.*\/{2}/, ''), '/'
    url = url.replace /www\./, ''
    .replace /\.(?:asp|aspx|htm|html|php|shtml)/, ''
    .replace /\//g, '-'

    "#{url}.html"

  getList: (option) ->

    {selector, url} = option

    urlList = switch $.type url
      when 'array' then url
      when 'string' then [url]
      else throw new Error 'invalid argument type'

    unless await @download urlList, option.lifetime
      return []

    list = []

    for url, i in urlList

      filename = @getFilename url

      cont = await $$.read "#{@base}/seeker/page/#{filename}"
      dom = cheerio.load cont.toString()

      dom(selector).each ->

        $a = dom @

        # title

        title = switch option.titleFrom
          when 'title' then $a.attr 'title'
          else $a.text()

        if fn = option.titleReplace
          title = fn title

        # url

        url = $a.attr 'href'

        if base = option.urlBase
          url = "#{base}#{url}"

        # time
        time = _.now() + i

        # return
        list.push {time, title, url}

    # return
    await @diff option.title, list, option.cacheSize

  open: (html) ->

    if !html.length
      return $.info 'seeker', 'got no result(s)'

    target = "#{@base}/seeker/result.html"

    method = switch $$.os
      when 'linux', 'macos' then 'open'
      when 'windows' then 'start'
      else throw new Error "invalid os <#{$$.os}>"

    await $$.write target, html
    await $$.shell "#{method} #{target}"

  seek: (name) ->

    listTask = if name then [name]
    else [
      'AcFun'
      'AlloyTeam'
      'AppInn'
      'iPlaySoft'
      # 'Ryf'
      'waitSun'
      'williamLong'
      'Zxx'
    ]

    map = {}
    for name in listTask
      {title, list} = await @task name
      map[title] = list

    html = @generate map
    await @open html

  task: (name) ->

    option = switch name.toLowerCase()

      when 'acfun'
        title: 'AcFun文章区'
        url: [
          'http://www.acfun.cn/v/list110/index_1.htm'
          'http://www.acfun.cn/v/list110/index_2.htm'
          'http://www.acfun.cn/v/list164/index_1.htm'
          'http://www.acfun.cn/v/list164/index_2.htm'
        ]
        selector: '#block-content-article a.title'
        urlBase: 'http://www.acfun.cn'
        lifetime: 6e4
        cacheSize: 200

      when 'alloyteam'
        title: 'AlloyTeam'
        url: 'http://www.alloyteam.com/page/0/'
        selector: '#content a.blogTitle'

      when 'appinn'
        title: '小众软件'
        url: 'http://www.appinn.com/'
        selector: 'h2.entry-title > a'
        titleFrom: 'title'

      when 'iplaysoft'
        title: '异次元软件世界'
        url: 'http://www.iplaysoft.com/'
        selector: 'h2.entry-title > a'

      when 'ryf'
        title: '阮一峰的网络日志'
        url: 'http://www.ruanyifeng.com/blog/'
        selector: 'h2.entry-title > a, #homepage li.module-list-item > span ~ a'

      when 'waitsun'
        title: '爱情守望者'
        url: [
          'https://www.waitsun.com/'
          'https://www.waitsun.com/page/2'
        ]
        selector: 'ul.posts-list h2.post-title > a'

      when 'williamlong'
        title: '月光博客'
        url: 'http://www.williamlong.info/'
        selector: 'h2.post-title > a'

      when 'zxx'
        title: '鑫空间'
        url: 'http://www.zhangxinxu.com/wordpress/'
        selector:'a.entry-title'
        titleReplace: (title) -> title.replace /的永久链接/, ''
        lifetime: 35e5

      else throw new Error "invalid task name <#{name}>"

    $.info.pause 'seeker.task'
    list = try await @getList option catch err then err
    $.info.resume 'seeker.task'

    if _.isError list
      $.info $.info 'error', "#{option.title}: #{list}"
      list = []

    # return
    title = option.title
    {title, list}

# return
module.exports = (arg...) -> new Seeker arg...