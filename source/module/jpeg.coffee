# require

$$ = require 'fire-keeper'
{$, _, Promise} = $$.library
co = Promise.coroutine

path = require 'path'
generate = require 'nanoid/generate'
sharp = require 'sharp'

# function

###

  getBuffer(image)
  getImage(source)
  getList(base, check)
  getRandomBasename()
  getSource(item)

###

getBuffer = (image) ->
  image
  .resize 1920, 1080
  .max()
  .jpeg
    quality: 100
  .toBuffer()

getImage = co (source) ->

  $.info.pause 'getImage'
  img = sharp yield $$.read source
  $.info.resume 'getImage'

  # return
  img

getList = co (base, check) ->

  list = []

  yield $$.walk base, (item) ->

    source = getSource item
    if !source then return

    if check
      extname = path.extname source
      basename = path.basename source, extname
      unless check {source, extname, basename} then return

    list.push source

  # return
  list

getRandomBasename = -> generate '1234567890abcdefghijklmnopqrstuvwxyz', 16

getSource = (item) ->
  if !item.stats.isFile() then return null
  item.path

# class

class Jpeg

  constructor: ->

    @validAction = [
      'auto'
      'clean'
      'format'
      'rename'
      'renameJpeg'
      'resize'
    ]

    @base = switch $$.os
      when 'macos' then '~/OneDrive/图片'
      when 'windows' then 'E:/OneDrive/图片'
      else throw new Error "invalid os <#{$$.os}>"

  ###

    auto()
    clean()
    format()
    rename()
    renameJpeg()
    resize()

  ###

  auto: co ->
    yield @clean()
    yield @format()
    yield @renameJpeg()
    yield @rename()
    yield @resize()

  clean: co ->

    listSource = yield getList @base, ({basename}) ->
      basename == '.DS_Store'

    if !listSource.length then return
    yield $$.remove listSource

  format: co ->

    listSource = yield getList @base, ({extname}) ->
      extname in ['.bmp', '.png', '.webp']

    for source in listSource

      img = yield getImage source

      data = yield getBuffer img
      yield $$.write source, data

      yield $$.rename source,
        extname: '.jpg'

  rename: co ->

    listSource = yield getList "#{@base}/杂图"

    for source in listSource

      extname = path.extname source
      basename = path.basename source, extname

      if basename.length == 16
        continue

      basename = getRandomBasename()
      yield $$.rename source, {basename}

  renameJpeg: co ->

    listSource = yield getList @base, ({extname}) ->
      extname == '.jpeg'

    for source in listSource

      yield $$.rename source,
        extname: '.jpg'

  resize: co ->

    listSource = yield getList @base, ({extname}) ->
      extname == '.jpg'

    for source in listSource

      img = yield getImage source

      # check size

      {width, height} = yield img.metadata()
      if width <= 1920 and height <= 1080
        continue

      # resize

      data = yield getBuffer img
      yield $$.write source, data

# return
module.exports = (arg...) -> new Jpeg arg...
