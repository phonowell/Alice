# require

$$ = require 'fire-keeper'
{$, _, Promise} = $$.library
co = Promise.coroutine

path = require 'path'
generate = require 'nanoid/generate'
GS = '1234567890abcdefghijklmnopqrstuvwxyz'
jimp = require 'jimp'

# function

###

  getBasename(source)
  getImage(source)
  getRandomBasename()
  getScale(width, height, [maxWidth], [maxHeight])
  isBasenameValid(filename)

###

getBasename = (source) ->
  extname = path.extname source
  path.basename source, extname

getImage = co (source) ->
  yield jimp.read source

getRandomBasename = ->
  [
    generate GS, 8
    'x'
    generate GS, 8
  ].join '-'

getScale = (
  width, height
  maxWidth = 1920, maxHeight = 1080
) ->
  _.min [
    maxWidth / width
    maxHeight / height
  ]

isBasenameValid = (filename) ->
  if filename.length != 19 then return false
  if filename.search('-x-') != 8 then return false
  true

# class

class Jpeg

  constructor: ->

    @validTarget = [
      'auto'
      'clean'
      'convert'
      'move'
      'rename'
      'renameJpeg'
      'resize'
    ]

    [@base, @download] = switch $$.os

      when 'macos'
        [
          '~/OneDrive/图片'
          '~/Downloads'
        ]

      when 'windows'
        [
          'E:/OneDrive/图片'
          'F:/'
        ]

      else throw new Error "invalid os <#{$$.os}>"

  auto: co ->
    yield @move()
    yield @clean()
    yield @convert()
    yield @renameJpeg()
    yield @rename()
    yield @resize()

  clean: co ->

    $.info 'step', 'clean'

    listSource = yield $$.source "#{@base}/**/.DS_Store"
    if !listSource.length then return
    yield $$.remove listSource

  convert: co ->

    $.info 'step', 'convert'

    listSource = yield $$.source [
      "#{@base}/**/*.bmp"
      "#{@base}/**/*.png"
      "#{@base}/**/*.webp"
    ]

    for source in listSource

      target = source.replace /\.(?:bmp|png|webp)/, '.jpg'

      img = yield getImage source
      img.write target

      yield $$.remove source

  move: co ->

    $.info 'step', 'move'

    for ext in ['gif', 'webm']

      listSource = yield $$.source "#{@download}/*.#{ext}"
      if !listSource.length then continue
      yield $$.move listSource, "#{@base}/小黄图/#{ext}"

  rename: co ->

    $.info 'step', 'rename'

    listSource = yield $$.source [
      "#{@base}/**/*.*"
      "!#{@base}/*.*"
    ]

    for source in listSource

      basename = getBasename source
      if isBasenameValid basename
        continue

      basename = getRandomBasename()
      yield $$.rename source, {basename}

  renameJpeg: co ->

    $.info 'step', 'renameJpeg'

    listSource = yield $$.source "#{@base}/**/*.jpeg"

    for source in listSource
      yield $$.rename source, extname: '.jpg'

  resize: co ->

    $.info 'step', 'resize'

    listSource = yield $$.source "#{@base}/**/*.jpg"

    for source in listSource

      basename = getBasename source
      if isBasenameValid basename
        continue

      img = yield getImage source

      # check size

      {width, height} = img.bitmap
      if width <= 1920 and height <= 1080
        continue

      # resize
      img.scale getScale width, height

      # save
      img.write source

# return
module.exports = (arg...) -> new Jpeg arg...