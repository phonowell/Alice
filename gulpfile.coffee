$$ = require 'fire-keeper'
{$, _, Promise, gulp} = $$.library
co = Promise.coroutine

fs = require 'fs'
path = require 'path'

# task

$$.task 'init', co ->

  yield $$.remove './.gitignore'
  yield $$.copy './../kokoro/.gitignore', './'
  yield $$.shell 'git add -f ./.gitignore'

  yield $$.remove './.npmignore'
  yield $$.copy './../kokoro/.npmignore', './'
  yield $$.shell 'git add -f ./.npmignore'

  yield $$.remove './coffeelint.yml'
  yield $$.copy './../kokoro/coffeelint.yml', './'
  yield $$.shell 'git add -f ./coffeelint.yml'

$$.task 'prepare', co ->

  yield $$.compile './coffeelint.yml'

$$.task 'lint', co -> yield $$.lint 'coffee'

$$.task 'update', co ->

  pkg = './package.json'
  $$.backup pkg

  p = require pkg

  list = (key for key, value of p.dependencies)
  listRemove = []
  listAdd = []

  listRemove = listRemove.concat ("npm r --save #{key}" for key in list)
  listAdd = listAdd.concat ("npm i --save #{key}" for key in list)

  list = (key for key, value of p.devDependencies)

  listRemove = listRemove.concat ("npm r --save-dev #{key}" for key in list)
  listAdd = listAdd.concat ("npm i --save-dev #{key}" for key in list)

  yield $$.shell listRemove
  yield $$.shell listAdd

  $$.remove "#{pkg}.bak"

$$.task 'backup', co ->

  # load
  yield $$.compile './data/data.yml'
  LIST = require './data/data.json'
  TARGET = 'E:/OneDrive/存档'

  # zip files
  for source in LIST

    if !fs.existsSync source then continue

    src = "#{source}/**/*.*"
    tar = "#{TARGET}/#{path.basename source}.zip"

    yield $$.remove tar
    yield $$.zip src, tar

  # backup OneDrive
  yield $$.remove 'E:/OneDrive.zip'
  yield $$.zip 'E:/OneDrive/**/*.*', 'E:/OneDrive.zip'