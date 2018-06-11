# require

$ = require 'fire-keeper'
{_} = $.library

path = require 'path'
generate = require 'nanoid/generate'
stringToken = '1234567890abcdefghijklmnopqrstuvwxyz'
jimp = require 'jimp'

# class

class Image

  ###
  storage
  temp
  ###

  storage: do ->

    mapPath =
      macos: '~/OneDrive/图片'
      windows: 'E:/OneDrive/图片'

    mapPath[$.os] or throw new Error "invalid os '#{$.os}'"

  temp: do ->
    
    mapPath =
      macos: '~/Downloads'
      windows: 'F:'

    mapPath[$.os] or throw new Error "invalid os '#{$.os}'"

  ###
  clean_()
  convert()
  execute_()
  genBasename()
  getBasename(source)
  getImg_(source)
  getScale(width, height, [maxWidth], [maxHeight])
  move_()
  rename()
  renameJpeg_()
  resize_()
  validateBasename(name)
  ###

  clean_: ->

    $.info 'step', 'clean'

    listSource = await $.source "#{@storage}/**/.DS_Store"
    await $.remove listSource

  convert_: ->

    $.info 'step', 'convert'

    listSource = await $.source [
      "#{@storage}/bmp/*.bmp"
      "#{@storage}/png/*.png"
      "#{@storage}/webp/*.webp"
    ]

    for source in listSource

      basename = @getBasename source
      target = "#{@storage}/jpg/#{basename}.jpg"

      img = await @getImg_ source
      img.write target

      await $.remove source

    await $.remove [
      "#{@storage}/bmp"
      "#{@storage}/png"
      "#{@storage}/webp"
    ]

  execute_: ->

    await @move_()
    await @clean_()
    await @convert_()
    await @renameJpeg_()
    await @resize_()
    await @rename_()

  genBasename: ->
    [
      generate stringToken, 8
      'x'
      generate stringToken, 8
    ].join '-'

  getBasename: (source) ->
    extname = path.extname source
    path.basename source, extname

  getImg_: (source) -> await jimp.read source

  getScale: (
    width, height
    maxWidth = 1920
    maxHeight = 1080
  ) ->
    _.min [
      maxWidth / width
      maxHeight / height
    ]

  move_: ->

    $.info 'step', 'move'

    # jpg & jpeg
    for ext in ['jpeg', 'jpg']
      listSource = await $.source "#{@temp}/*.#{ext}"
      await $.move listSource, "#{@storage}/jpg"

    # other
    for ext in ['bmp', 'gif', 'mp4', 'png', 'webm', 'webp']
      listSource = await $.source "#{@temp}/*.#{ext}"
      await $.move listSource, "#{@storage}/#{ext}"

  rename_: ->

    $.info 'step', 'rename'

    listSource = await $.source [
      "#{@storage}/**/*.*"
      "!#{@storage}/*.*"
    ]
      
    for source in listSource

      basename = @getBasename source
      if @validateBasename basename then continue

      basename = @genBasename()
      await $.rename source, {basename}

  renameJpeg_: ->

    $.info 'step', 'renameJpeg'

    listSource = await $.source "#{@storage}/**/*.jpeg"

    for source in listSource
      await $.rename source, extname: '.jpg'

  resize_: ->

    $.info 'step', 'resize'

    listSource = await $.source "#{@storage}/**/*.jpg"

    for source in listSource

      basename = @getBasename source
      if @validateBasename basename then continue

      img = await @getImg_ source

      # check size
      {width, height} = img.bitmap
      if width <= 1920 and height <= 1080 then continue

      # scale
      img.scale @getScale width, height

      # save
      img.write source

  validateBasename: (name) ->
    if name.length != 19 then return false
    name.search(/-x-/) == 8

# return
module.exports = (arg...) -> new Image arg...