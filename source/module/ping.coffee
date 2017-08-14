# require

$$ = require 'fire-keeper'
{$, _, Promise} = $$.library
co = Promise.coroutine

colors = require 'colors/safe'

# class

class Ping

  constructor: -> null

  ###

    getList()
    ping()
    showDivider()

  ###

  getList: co ->

    $$.compile './data/ping/list.yaml'
    yield $$.read './data/ping/list.json'

  ping: co ->

    list = yield @getList()

    yield $$.remove './temp/ping'

    for url in list

      $.info 'ping', "started to load '#{url}'"

      st = _.now()

      filename = url.replace /.*\/\//, ''
        .replace /\//g, '-'
      filename = _.trim filename, '-'

      yield $$.download url, './temp/ping', "#{filename}.html"
        .catch (err) -> $.info 'ping', "failed after '#{_.now() - st} ms'"
        .then -> $.info 'ping', "loaded in '#{_.now() - st} ms'"

      @showDivider()

    yield $$.remove './temp/ping'

  showDivider: ->

    @showDivider.divider or= colors.gray _.trim _.repeat('- ', 16)
    $.log @showDivider.divider

# return
module.exports = (arg...) -> new Ping arg...