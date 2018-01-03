# require

$$ = require 'fire-keeper'
{$, _} = $$.library

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

  execute: (name) ->

    # check shell.sh

    source = "./source/shell/reboot/#{name}.sh"
    unless await $$.isExisted source
      throw new Error "'#{name}.sh' not existed"

    # server list

    listServer = switch name

      when 'api'
        [
          await @getServer 'api-1'
          await @getServer 'api-2'
        ]

      when 'dev.anitama.net'
        [
          await @getServer 'dev.anitama.net'
        ]

    # connect & execute

    for server in listServer

      await $$.ssh.connect server

      await $$.ssh.upload source
      , '/mimiko'
      , 'reboot.sh'

      await $$.ssh.shell 'sh /mimiko/reboot.sh',
        ignoreError: true

      await $$.ssh.disconnect()

  getServer: (name) ->

    base = '~/OneDrive/密钥/Anitama/token'

    switch name

      when 'api-1'

        token = await $$.read "#{base}/www.json"
        token.host = '121.40.226.20'

      when 'api-2'

        token = await $$.read "#{base}/www.json"
        token.host = '120.26.81.37'

      when 'dev.anitama.net'

        token = await $$.read "#{base}/dev.json"
        token.host = 'dev.anitama.net'
        
    # return
    token

# return
module.exports = (arg...) -> new Reboot arg...