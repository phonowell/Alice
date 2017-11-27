# require

$$ = require 'fire-keeper'
{$, _, Promise} = $$.library
co = Promise.coroutine

# class

class Reboot

  constructor: ->

    @validTarget = [
      'api'
      'dev.anitama.net'
    ]

  ###

    execute(name)
    getServer(name)

  ###

  execute: co (name) ->

    # check shell.sh

    source = "./source/shell/reboot/#{name}.sh"
    unless yield $$.isExisted source
      throw new Error "'#{name}.sh' not existed"

    # server list

    listServer = switch name

      when 'api'
        [
          yield @getServer 'api-1'
          yield @getServer 'api-2'
        ]

      when 'dev.anitama.net'
        [
          yield @getServer 'dev.anitama.net'
        ]

    # connect & execute

    for server in listServer

      yield $$.ssh.connect server

      yield $$.ssh.upload source
      , '/mimiko'
      , 'reboot.sh'

      yield $$.ssh.shell 'sh /mimiko/reboot.sh',
        ignoreError: true

      yield $$.ssh.disconnect()

  getServer: co (name) ->

    base = '~/OneDrive/密钥/Anitama/token'

    switch name

      when 'api-1'

        token = yield $$.read "#{base}/www.json"
        token.host = '121.40.226.20'

      when 'api-2'

        token = yield $$.read "#{base}/www.json"
        token.host = '120.26.81.37'

      when 'dev.anitama.net'

        token = yield $$.read "#{base}/dev.json"
        token.host = 'dev.anitama.net'
        
    # return
    token

# return
module.exports = (arg...) -> new Reboot arg...