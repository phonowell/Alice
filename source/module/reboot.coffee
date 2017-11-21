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
    getPassword(name)
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

  getPassword: co (name) ->

    base = switch name
      when 'api' then 'www.anitama.cn'
      when 'dev.anitama.net' then 'dev.anitama.net'

    base = "~/OneDrive/密钥/Anitama/#{base}"

    [
      yield $$.read "#{base}/privateKey.txt"
      yield $$.read "#{base}/passphrase.txt"
    ]

  getServer: co (name) ->

    switch name

      when 'api-1'

        host = '121.40.226.20'
        password = yield @getPassword 'api'

      when 'api-2'

        host = '120.26.81.37'
        password = yield @getPassword 'api'

      when 'dev.anitama.net'

        host = 'dev.anitama.net'
        password = yield @getPassword 'dev.anitama.net'
        
    # return
    host: host
    passphrase: password[1]
    port: 22
    privateKey: password[0]
    username: 'root'

# return
module.exports = (arg...) -> new Reboot arg...
