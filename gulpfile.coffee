$$ = require 'fire-keeper'
{$, _, Promise} = $$.library
co = Promise.coroutine

fs = require 'fs'
path = require 'path'

# task

###

  backup
  josh
  launchpad
  lint
  seek
  sfacg

###

$$.task 'backup', co ->

  m = require './source/module/oneDrive.coffee'
  od = new m 'E:/OneDrive'

  yield od.backupGameSave()
  yield od.backup()

$$.task 'josh', co ->

  m = require './source/module/josh.coffee'
  josh = new m()

  yield josh.download()

$$.task 'launchpad', co  ->

  if $$.os != 'macos'
    return $.info 'launchpad', 'invalid os'

  yield $$.shell 'defaults write com.apple.dock ResetLaunchPad -bool true && killall Dock'

$$.task 'lint', co ->

  yield $$.task('kokoro')()

  yield $$.lint [
    './gulpfile.coffee'
    './source/**/*.coffee'
  ]

$$.task 'seek', co ->

  {target} = $$.argv

  m = require './source/module/seeker.coffee'
  seeker = new m()

  yield seeker.seek target

$$.task 'sfacg', co ->

  {url} = $$.argv
  if !url then throw new Error 'invalid url'

  m = require './source/module/sfacg.coffee'
  sf = new m()

  yield sf.get url