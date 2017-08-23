# require

$$ = require 'fire-keeper'
{$, _, Promise} = $$.library
co = Promise.coroutine

fs = require 'fs'
path = require 'path'

cheerio = require 'cheerio'
colors = require 'colors/safe'

# class

class Seeker

  constructor: -> null

  ###

    diff(title, list, [cacheSize])
    download(list, [lifetime])
    getFilename(url)
    getList(option)
    seek(name)
    show(list)
    task(name)

  ###

  diff: co (title, list, cacheSize = 50) ->

    source = "./temp/seeker/list/#{title}.json"
    list = _.uniqBy list, 'url'
    list = _.sortBy list, 'time'

    sourceList = yield $$.read source
    sourceList or= []

    res = _.differenceBy list, sourceList, 'url'

    list = _.concat sourceList, list
    list = _.uniqBy list, 'url'
    list = _.sortBy list, 'time'
    list = _.reverse list
    if list.length > cacheSize then list = list[0...cacheSize]
    yield $$.write source, list

    return res

  download: co (list, lifetime = 3e5) ->

    res = false

    for url in list

      filename = @getFilename url
      stat = yield $$.stat "./temp/seeker/page/#{filename}"

      if stat and _.now() - stat.ctime.getTime() < lifetime
        continue

      yield $$.download url, './temp/seeker/page',
        filename: filename
        timeout: 1e4

      res = true

    # return
    res

  getFilename: (url) ->

    filename = url.replace /[:\/.]/g, ''
    "#{filename}.html"

  getList: co (option) ->

    {selector, url} = option

    urlList = switch $.type url
      when 'array' then url
      when 'string' then [url]
      else throw new Error 'invalid argument type'

    unless yield @download urlList, option.lifetime
      return []

    list = []

    for url, i in urlList

      filename = @getFilename url

      cont = yield $$.read "./temp/seeker/page/#{filename}"
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
    yield @diff option.title, list, option.cacheSize

  seek: co (name) ->

    if name then return yield @task name

    taskList = [
      'AcFun'
      'AlloyTeam'
      'AppInn'
      'iPlaySoft'
      'Ryf'
      'waitSun'
      'williamLong'
      'Zxx'
    ]

    for name in taskList
      yield @task name

  show: (title, list) ->

    if !list.length then return

    @show.divider or= colors.gray _.trim _.repeat('- ', 16)

    $.i colors.blue title
    $.i @show.divider
    $.i ("#{colors.magenta a.title}\n#{colors.gray a.url}" for a in list).join '\n\n'
    $.i @show.divider

  task: co (name) ->

    option = switch name.toLowerCase()

      when 'acfun'
        title: 'AcFun文章区'
        url: [
          'http://www.acfun.cn/v/list110/index.htm'
          'http://www.acfun.cn/v/list110/index_2.htm'
          'http://www.acfun.cn/v/list164/index.htm'
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
        selector: '.masonry h1 > a'

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
    list = yield @getList option
    $.info.resume 'seeker.task'

    @show option.title, list

# return
module.exports = (arg...) -> new Seeker arg...
