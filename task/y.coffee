$ = require 'fire-keeper'
{_} = $

# return
module.exports = ->

  jimp = require 'jimp'

  listSource = await $.source_ '~/Downloads/karakuri/*.png'

  for source in listSource
    target = source
    .replace /\.png/, '.jpg'
    $img = await jimp.read source
    await $img.write target