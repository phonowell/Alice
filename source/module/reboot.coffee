# require

$$ = require 'fire-keeper'
{$, _, Promise} = $$.library
co = Promise.coroutine

# class

class Reboot

  constructor: ->

    @validHost = [
      'dev.anitama.net'
    ]

  ###

    execute(host)
    getPassword()

  ###

  execute: co (@host) ->

    password = yield @getPassword()

    # connect

    server =
      host: @host
      port: 22
      username: 'root'
      privateKey: password[0]
      passphrase: password[1]

    yield $$.ssh.connect server

    yield $$.ssh.upload "./source/shell/reboot/#{@host}.sh"
    , '/mimiko'
    , 'reboot.sh'

    yield $$.ssh.shell 'sh /mimiko/reboot.sh',
      ignoreError: true

    yield $$.ssh.disconnect()

  getPassword: co ->

    base = "~/OneDrive/密钥/Anitama/#{@host}"

    [
      yield $$.read "#{base}/privateKey.txt"
      yield $$.read "#{base}/passphrase.txt"
    ]

# return
module.exports = (arg...) -> new Reboot arg...
