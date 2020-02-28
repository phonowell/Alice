$ = require 'fire-keeper'

# function

class M

  path:
    document: '/Volumes/Kindle/documents'
    kindlegen: '/usr/local/bin/kindlegen'
    storage: '~/OneDrive/书籍/同步/*.txt'
    temp: './temp/kindle'

  # ---

  clean_: ->
    await $.remove_ @path.temp
    @ # return

  execute_: ->

    unless await @validate_()
      return

    await @rename_()

    listSource = await $.source_ @path.storage

    for source in listSource

      if await @isExisted_ source
        continue

      await @txt2html_ source
      await @html2mobi_ source
      await @move_ source

    await @clean_()

    @ # return

  html2mobi_: (source) ->
    {basename} = $.getName source
    target = "#{@path.temp}/#{basename}.html"

    cmd = [
      @path.kindlegen
      target
      '-c1'
      '-dont_append_source'
    ].join ' '

    await $.exec_ cmd
    @ # return

  isExisted_: (source) ->
    {basename} = $.getName source
    await $.isExisted_ "#{@path.document}/#{basename}.mobi"

  move_: (source) ->
    {basename} = $.getName source
    await $.copy_ "#{@path.temp}/#{basename}.mobi", @path.document
    @ # return

  rename_: ->

    listSource = await $.source_ @path.storage

    for source in listSource
      {basename} = $.getName source

      unless /[\s()[]]/.test basename
        continue

      basename = basename
      .replace /[\s()[]]/g, ''

      await $.rename_ source, {basename}

    @ # return

  txt2html_: (source) ->

    {basename} = $.getName source
    target = "#{@path.temp}/#{basename}.html"

    cont = await $.read_ source
    list = cont.split '\n'
    result = []

    for line in list
      unless line = line.trim()
        continue
      result.push "<p>#{line}</p>"

    result = [
      '<html lang="zh-cmn-Hans">'
        '<head>'
          '<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>'
        '</head>'
        '<body>'
          result.join '\n'
        '</body>'
      '</html>'
    ].join ''
    await $.write_ target, result
    @ # return

  validate_: ->
    
    unless $.os 'macos'
      $.info "invalid os '#{$.os()}'"
      return false
    
    unless await $.isExisted_ @path.kindlegen
      $.info "found no 'kindlegen', run 'brew cask install kindlegen' to install it"
      return false
    
    unless await $.isExisted_ @path.document
      $.info "found no '#{@path.document}'"
      return false

    true # return

# export
module.exports = ->
  m = new M()
  await m.execute_()