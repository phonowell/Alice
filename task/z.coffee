$ = require 'fire-keeper'
{_} = $

path = require 'path'

# return
module.exports = ->

  listSource = await $.source_ '~/project/*'

  for source in listSource

    if ~source.search 'kokoro'
      continue

    isExisted = await $.isExisted_ "#{source}/coffeelint.json"
    unless isExisted
      continue

    lines = [
      "cd #{source}"
      'gulp kokoro'
    ]

    await $.exec_ lines

    # if ~source.search 'tamako'
    #   continue

    # data = await $.read_ "#{source}/package.json"
    # unless data
    #   continue

    # version = _.get data, 'dependencies.fire-keeper'
    # version or= _.get data, 'devDependencies.fire-keeper'
    
    # unless version
    #   continue

    # if ~version.search '0.0.138'
    #   continue

    # lines = [
    #   "cd #{source}"
    #   'gulp update'
    # ]

    # await $.exec_ lines

  await $.say_ 'mission completed'