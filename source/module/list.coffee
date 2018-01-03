# require

$$ = require 'fire-keeper'
{$, _} = $$.library

colors = require 'colors/safe'

# class

class List

  constructor: ->

    @validTarget = [
      'host', 'ip'
    ]

  ###

    list()

  ###

  list: (target) ->

    switch target

      when 'host', 'ip'

        ListHost =
          admin: '192.168.100.3'
          ahz: '121.40.169.34'
          dev: '172.16.0.32'
          git: '192.168.100.2'
          ss: '45.79.75.246'
          'www-1': '121.40.167.221'
          'www-2': '118.178.128.8'

        for key, value of ListHost
          $.i "#{colors.blue key}: #{colors.magenta value}"

      else throw new Error "invalid target <#{target}>"

# return
module.exports = (arg...) -> new List arg...