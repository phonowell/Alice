# require

$ = require 'fire-keeper'
{_} = $

# class

class M

  constructor: (@host) ->

    @base = "~/OneDrive/密钥/Anitama/#{@host}"
    @source = './temp/shadowsocks.json'

  ###
  execute()
  ###

  execute: ->

    password = await $.read_ "#{@base}/password.txt"
    privateKey = await $.read_ "#{@base}/privateKey.txt"
    passphrase = await $.read_ "#{@base}/passphrase.txt"

    # generate

    data =
      server: '0.0.0.0'
      server_port: 443
      password: password
      timeout: 600
      method: 'rc4-md5'
      fast_open: true

    await $.write_ @source, data

    # connect

    server =
      host: @host
      port: 22
      username: 'root'
      privateKey: privateKey
      passphrase: passphrase

    await $.ssh.connect_ server

    await $.ssh.upload_ @source, '/etc', 'shadowsocks.json'
    await $.remove_ @source

    await $.ssh.shell_ [
      'ssserver -c /etc/shadowsocks.json -d stop'
      'ssserver -c /etc/shadowsocks.json -d start'
    ], ignoreError: true

    await $.ssh.disconnect_()

# return
module.exports = (arg...) -> new M arg...
