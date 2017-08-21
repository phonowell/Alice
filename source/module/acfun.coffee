# require

$$ = require 'fire-keeper'
{$, _, Promise} = $$.library
co = Promise.coroutine

cheerio = require 'cheerio'

# class

class Acfun

  constructor: -> null

  ###

    getHtml(uid)
    getInfo(uid, html)
    seek()

  ###

  downloadAvatar: co (info) ->

    {uid, name, avatar} = info

    if avatar == 'http://cdn.aixifan.com/dotnet/20120923/style/image/avatar.jpg'
      return

    filename = "#{uid} - #{name}.jpg".replace /[\\\/:*?"<>|]/g, ''
    dirname = "~/Downloads/AcFun Avatar"

    if yield $$.isExisted "#{dirname}/#{filename}"
      return

    yield $$.download avatar, dirname, filename

  getHtml: co (uid) ->

    filename = "#{uid}.html"
    source = "./temp/acfun/page/#{filename}"

    unless yield $$.isExisted source
      url = "http://www.acfun.cn/u/#{uid}.aspx"
      try yield $$.download url, './temp/acfun/page', filename
      catch err then yield $$.write source, 'empty'

    # return
    yield $$.read source

  getInfo: co (uid) ->

    filename = "#{uid}.json"
    source = "./temp/acfun/list/#{filename}"

    if yield $$.isExisted source
      return yield $$.read source

    html = yield @getHtml uid
    if html.length < 1e2 then return null

    dom = cheerio.load html

    $name = dom '#anchorMes .name'
    $avatar = dom '#anchorMes .cover .img'

    name = _.trim $name.text()
    avatar = $avatar.attr 'style'
    .replace /.*\('/, ''
    .replace /'\).*/, ''

    res = {uid, name, avatar}
    yield $$.write source, res

    # return
    res

  seek: co ->

    for uid in [2e3...5e3]

      info = yield @getInfo uid
      if !info then continue

      yield @downloadAvatar info

# return
module.exports = (arg...) -> new Acfun arg...
