$ = require 'fire-keeper'

# return
module.exports = ->
  
  listName = await $.read_ './data/sankaku.yaml'

  for name in listName
    
    name = name
    .replace /\s/g, '_'
    .replace /[\(\)]/g, ''
    
    await $.exec_ "gulp yandere --keyword #{name} --type origin"
