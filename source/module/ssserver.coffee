# require

$$ = require 'fire-keeper'
{$, _, Promise} = $$.library
co = Promise.coroutine

# class

class SSServer

  constructor: (@host) ->

    @base = "~/OneDrive/密钥/Anitama/#{@host}"
    @source = './temp/shadowsocks.json'

  ###

    execute()

  ###

  execute: co ->

    password = yield $$.read "#{@base}/password.txt"
    privateKey = yield $$.read "#{@base}/privateKey.txt"
    passphrase = yield $$.read "#{@base}/passphrase.txt"

    # genernate

    data =
      server: '0.0.0.0'
      server_port: 443
      password: password
      timeout: 600
      method: 'rc4-md5'
      fast_open: true

    yield $$.write @source, data

    # connect

    server =
      host: @host
      port: 22
      username: 'root'
      privateKey: privateKey
      passphrase: passphrase

    yield $$.ssh.connect server

    yield $$.ssh.upload @source, '/etc', 'shadowsocks.json'
    yield $$.remove @source

    yield $$.ssh.shell [
      'ssserver -c /etc/shadowsocks.json -d stop'
      'ssserver -c /etc/shadowsocks.json -d start'
    ], ignoreError: true

    yield $$.ssh.disconnect()

# return
module.exports = (arg...) -> new SSServer arg...
