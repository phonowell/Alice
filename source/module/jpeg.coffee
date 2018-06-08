# require

$ = require 'fire-keeper'
{_} = $.library

path = require 'path'
generate = require 'nanoid/generate'
GS = '1234567890abcdefghijklmnopqrstuvwxyz'
jimp = require 'jimp'

# function

###

getBasename(source)
getImage(source)
getPageName(filename)
getRandomBasename()
getScale(width, height, [maxWidth], [maxHeight])
isBasenameValid(filename)
isPageNameValid(filename)

###

getBasename = (source) ->
  extname = path.extname source
  path.basename source, extname

getImage = (source) ->
  await jimp.read source

getPageName = (filename) ->

  filename = filename
  .replace /.*_/, ''
  .replace /\D/g, ''
  page = parseInt filename

  unless page >= 0 then return null
  _.padStart page, 3, '0'

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

  if filename.length != 19
    return false

  filename.search(/-x-/) == 8

isPageNameValid = (filename) ->

  if filename.length != 3
    return false

  !!~filename.search /\d{3}/

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

    [@base, @download] = switch $.os

      when 'macos'
        [
          '~/OneDrive/图片'
          '~/Downloads'
        ]

      when 'windows'
        [
          'E:/OneDrive/图片'
          'F:'
        ]

      else throw new Error "invalid os <#{$.os}>"

  auto: ->
    await @move()
    await @clean()
    await @convert()
    await @renameJpeg()
    await @resize()
    await @rename()

  clean: ->

    $.info 'step', 'clean'

    listSource = await $.source "#{@base}/**/.DS_Store"
    if !listSource.length then return
    await $.remove listSource

  convert: ->

    $.info 'step', 'convert'

    listSource = await $.source [
      "#{@base}/**/*.bmp"
      "#{@base}/**/*.png"
      "#{@base}/**/*.webp"
    ]

    for source in listSource

      target = source.replace /\.(?:bmp|png|webp)/, '.jpg'

      img = await getImage source
      img.write target

      await $.remove source

  move: ->

    $.info 'step', 'move'

    for ext in ['gif', 'mp4', 'webm']

      listSource = await $.source "#{@download}/*.#{ext}"
      if !listSource.length then continue
      await $.move listSource, "#{@base}/小黄图/#{ext}"

  rename: ->

    $.info 'step', 'rename'

    list = []

    list.push
      source: await $.source [
        "#{@base}/**/*.*"
        "!#{@base}/本子/**/*.*/"
        "!#{@base}/*.*"
      ]
      valid: isBasenameValid
      getName: getRandomBasename

    list.push
      source: await $.source "#{@base}/本子/**/*.*"
      valid: isPageNameValid
      getName: getPageName

    for item in list
      
      for source in item.source

        basename = getBasename source
        if item.valid basename
          continue

        basename = item.getName basename
        if basename?
          await $.rename source, {basename}
        else await $.remove source

  renameJpeg: ->

    $.info 'step', 'renameJpeg'

    listSource = await $.source "#{@base}/**/*.jpeg"

    for source in listSource
      await $.rename source, extname: '.jpg'

  resize: ->

    $.info 'step', 'resize'

    list = []

    list.push
      source: await $.source [
        "#{@base}/**/*.jpg"
        "!#{@base}/本子/**/*.*"
      ]
      valid: isBasenameValid

    list.push
      source: await $.source "#{@base}/本子/**/*.jpg"
      valid: isPageNameValid

    for item in list

      for source in item.source

        basename = getBasename source
        if item.valid basename
          continue

        img = await getImage source

        # check size

        {width, height} = img.bitmap
        if width <= 1920 and height <= 1080
          continue

        $.i source

        img.scale getScale width, height
        img.write source

# return
module.exports = (arg...) -> new Jpeg arg...