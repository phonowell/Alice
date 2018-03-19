# require

$$ = require 'fire-keeper'
{$, _} = $$.library

path = require 'path'
ffmpeg = require 'fluent-ffmpeg'
colors = require 'colors/safe'

# function

###
calcSize(n)
calcTime(n)
###

calcSize = (n) ->

  if !n then return '0 B'
  s = parseInt n

  switch
    when s > 1099511627776
      "#{(s / 1099511627776).toFixed 2} TB"
    when s > 1073741824
      "#{(s / 1073741824).toFixed 2} GB"
    when s > 1048576
      "#{(s / 1048576).toFixed 2} MB"
    when s > 1024
      "#{(s / 1024).toFixed 2} KB"
    else
      "#{s} B"

calcTime = (n) ->

  if !n then return '0 ms'
  s = parseInt n

  switch
    when s > 36e5
      "#{(s / 36e5).toFixed 2} h"
    when s > 60e3
      "#{(s / 60e3).toFixed 2} m"
    when s > 1e3
      "#{(s / 1e3).toFixed 2} s"
    else
      "#{s} ms"

# class

class Video

  constructor: -> null

  ###
  execute()
  format(source, target, [option])
  genMsg(data)
  getData(video)
  setParam(video, data, option)
  ###

  execute: ->

    target = '~/Downloads/video/output'
    await $$.remove target

    await @format [
      '~/OneDrive/图片/小黄图/webm/*.webm'
      '~/OneDrive/图片/小黄图/mp4/*.mp4'
    ]
    , target

    await $$.move "#{target}/*.mp4"
    , '~/OneDrive/图片/小黄图/mp4'

    await $$.remove '~/OneDrive/图片/小黄图/webm'

    await $$.say 'mission completed'
    
  format: (source, target, option = {}) ->

    genMsg = @genMsg

    source = await $$.source source
    target = $$.fn.normalizePath target

    $.info.pause 'Video.mkdir'
    await $$.mkdir target
    $.info.resume 'Video.mkdir'

    if $.type(option) == 'string'
      option = filename: option

    for src in source

      filename = option.filename or do ->
        extname = path.extname src
        basename = path.basename src, extname
        "#{basename}.mp4"

      await new Promise (resolve) =>

        st = _.now()
        video = ffmpeg src

        # check video information
        data = await @getData video
        {codec, width, height} = data.video
        # if codec == 'h264' and width <= 848 and height <= 480
        #   $.info 'video', "cancelled '#{src}'"
        #   return resolve()

        @setParam video, data, option

        # bind
        video.on 'error', (err) -> throw err
        .on 'start', (cmd) ->
          $.info 'video', "'#{cmd}'"
        .on 'progress', (data) -> $.i genMsg data
        .on 'end', ->
          $.info 'video', "finished in '#{calcTime _.now() - st}'"
          resolve()

        # output
        video.output "#{target}/#{filename}"
        .run()

  genMsg: (data = {}) ->

    listMsg = []

    # percent
    if value = data.percent
      listMsg.push colors.gray "#{value.toFixed 2}%"

    # timemark
    if value = data.timemark
      listMsg.push colors.blue "[#{value}]"

    # currentFps
    if value = data.currentFps
      listMsg.push "fps: #{colors.magenta value}"

    # currentKbps
    if value = data.currentKbps
      listMsg.push colors.gray '/'
      listMsg.push "kbps: #{colors.magenta value}"

    # targetSize
    if value = data.targetSize
      listMsg.push colors.gray '/'
      listMsg.push colors.gray calcSize value * 1024

    listMsg.join ' '

  getData: (video) ->

    new Promise (resolve) ->

      video.ffprobe (err, data) ->
        if err then throw err

        res = {}

        # video info
        if item = _.find data.streams, codec_type: 'video'
          res.video =
            bitrate: item.bit_rate
            codec: item.codec_name
            dar: item.display_aspect_ratio
            height: item.height
            width: item.width
        
        # audiu info
        if item = _.find data.streams, codec_type: 'audio'
          res.audio =
            bitrate: item.bit_rate
            channel: item.channels
            codec: item.codec_name
            layout: item.channel_layout
          
        # format info
        item = data.format
        res.file =
          bitrate: item.bit_rate
          size: item.size

        # return
        resolve res

  setParam: (video, data, option) ->
  
    video
    .withNativeFramerate()
    .keepDisplayAspectRatio()

    if data.video

      size = do ->
        {width, height} = data.video
        
        if option.width or option.height
          w = option.width or '?'
          h = option.height or '?'
          return "#{w}x#{h}"
        
        [w, h] = if width / 16 * 9 >= height
          [
            option.width or _.min [width, 848]
            '?'
          ]
        else
          [
            '?'
            option.height or _.min [height, 480]
          ]
        "#{w}x#{h}"

      $.info 'video', "set video size as '#{size} px'"
      
      video.videoCodec 'libx264'
      .size size
    
    else video.withNoVideo()

    if data.audio
      video.audioCodec 'aac'
    else video.withNoAudio()

# return
module.exports = (arg...) -> new Video arg...