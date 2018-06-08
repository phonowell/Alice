# require

$ = require 'fire-keeper'
{_} = $.library

# class

class SSServer

  constructor: (@host) ->

    @base = "~/OneDrive/密钥/Anitama/#{@host}"
    @source = './temp/shadowsocks.json'

  ###

  execute()

  ###

  execute: ->

    password = await $.read "#{@base}/password.txt"
    privateKey = await $.read "#{@base}/privateKey.txt"
    passphrase = await $.read "#{@base}/passphrase.txt"

    # generate

    data =
      server: '0.0.0.0'
      server_port: 443
      password: password
      timeout: 600
      method: 'rc4-md5'
      fast_open: true

    await $.write @source, data

    # connect

    server =
      host: @host
      port: 22
      username: 'root'
      privateKey: privateKey
      passphrase: passphrase

    await $.ssh.connect server

    await $.ssh.upload @source, '/etc', 'shadowsocks.json'
    await $.remove @source

    await $.ssh.shell [
      'ssserver -c /etc/shadowsocks.json -d stop'
      'ssserver -c /etc/shadowsocks.json -d start'
    ], ignoreError: true

    await $.ssh.disconnect()

# return
module.exports = (arg...) -> new SSServer arg...