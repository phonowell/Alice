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

  constructor: ->

  ###

    getList(option)
    seek(name)
    show(list)
    task(name)

  ###

  getList: co (option) ->

    {url, selector} = option

    urlList = switch $.type url
      when 'array' then url
      when 'string' then [url]
      else throw new Error 'invalid argument type'

    list = []

    for url in urlList

      html = yield $.get url
      dom = cheerio.load html

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

        # return
        list.push {title, url}

    # return
    list

  seek: co (name) ->

    if name then return yield @task name

    yield @task 'AcFun'
    yield @task 'AppInn'
    yield @task 'iPlaySoft'
    yield @task 'Zxx'

  show: (title, list) ->

    $.info 'seeker', "<#{title}>"
    $.i ("#{colors.blue a.title}\n#{colors.gray a.url}" for a in list).join '\n\n'

  task: co (name) ->

    option = switch name.toLowerCase()

      when 'acfun'
        title: 'AcFun文章区'
        url: [
          'http://www.acfun.cn/v/list110/index.htm'
          'http://www.acfun.cn/v/list164/index.htm'
        ]
        selector: '#block-content-article a.title'
        urlBase: 'http://www.acfun.cn'

      when 'appinn'
        title: '小众软件'
        url: 'http://www.appinn.com/'
        selector: 'h2.entry-title > a'
        titleFrom: 'title'

      when 'iplaysoft'
        title: '异次元软件世界'
        url: 'http://www.iplaysoft.com/'
        selector: 'h2.entry-title > a'

      when 'zxx', 'zhangxinxu'
        title: '鑫空间'
        url: 'http://www.zhangxinxu.com/wordpress/'
        selector:'a.entry-title'
        titleReplace: (title) -> title.replace /的永久链接/, ''

      else throw new Error "invalid task name <#{name}>"

    list = yield @getList option
    @show option.title, list

# return
module.exports = (arg...) -> new Seeker arg...