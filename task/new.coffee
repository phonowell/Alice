$ = require 'fire-keeper'

class M

  ###
  execute_()
  init_()
  package_()
  prepare_()
  ###

  execute_: ->
    
    @name = await $.prompt
      type: 'text'
      message: 'input name of new project'

    unless @name.length
      throw new Error 'invaild name'

    await $.chain @
    .prepare_()
    .package_()
    .init_()

    @ # return

  init_: ->

    await $.exec_ [
      "cd #{@base}"
      'cnpm i fire-keeper --save-dev'
      'gulp kokoro'
    ]

    @ # return

  package_: ->

    data =
      name: @name
      version: '0.0.1'
      description: @name
      main: 'index.js'
      scripts: {}
      repository:
        type: 'git'
        url: "https://github.com/phonowell/#{@name}.git"
      keywords: [@name]
      author: 'Mimiko Phonowell <phonowell@gmail.com>'
      license: 'GPL-3.0+'
      url: "https://github.com/phonowell/#{@name}"
      bugs:
        url: "https://github.com/phonowell/#{@name}/issues"
      homepage: "https://github.com/phonowell/#{@name}"
      dependencies: {}

    await $.write_ "#{@base}/package.json", data

    await $.exec_ [
      "cd #{@base}"
      'git add ./package.json'
    ]

    @ # return

  prepare_: ->

    @base = "./../#{@name}"

    isExisted = await $.isExisted_ @base
    if isExisted
      throw new Error "'#{@name}' existed already"

    await $.chain $
    .mkdir_ @base
    .mkdir_ "#{@base}/source"
    .mkdir_ "#{@base}/task"
    .mkdir_ "#{@base}/test"
    .copy_ './gulpfile.coffee', @base

    @ # return

# return
module.exports = ->
  m = new M()
  await m.execute_()