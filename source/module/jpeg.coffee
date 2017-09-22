# require

$$ = require 'fire-keeper'
{$, _, Promise} = $$.library
co = Promise.coroutine

path = require 'path'
sharp = require 'sharp'

# function

###

  getBuffer(image)
  getImage(source)
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

getSource = (item) ->

  if !item.stats.isFile()
    return {}

  source = item.path
  extname = path.extname source

  # return
  {source, extname}

# class

class Jpeg

  constructor: ->

    @validAction = [
      'auto'
      'format'
      'rename'
      'resize'
    ]

    @base = switch $$.os
      when 'macos' then '~/OneDrive/图片'
      when 'windows' then 'E:/OneDrive/图片'
      else throw new Error "invalid os <#{$$.os}>"

  ###

    auto()
    format()
    rename()
    resize()

  ###

  auto: co ->
    yield @format()
    yield @rename()
    yield @resize()

  format: co ->

    listSource = []

    yield $$.walk @base, (item) ->

      {source, extname} = getSource item
      if !source then return
      unless extname in ['.bmp', '.png', '.webp']
        return

      listSource.push source

    for source in listSource

      img = yield getImage source

      data = yield getBuffer img
      yield $$.write source, data

      yield $$.rename source,
        extname: '.jpg'

  rename: co ->

    listSource = []

    yield $$.walk @base, (item) ->

      {source, extname} = getSource item
      if !source then return
      if extname != '.jpeg' then return

      listSource.push source

    for source in listSource

      yield $$.rename source,
        extname: '.jpg'

  resize: co ->

    listSource = []

    yield $$.walk @base, (item) ->

      {source, extname} = getSource item
      if !source then return
      if extname != '.jpg' then return

      listSource.push source

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
