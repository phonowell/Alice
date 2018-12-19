$ = require 'fire-keeper'
{_} = $

# return
module.exports = ->

  await $.exec_ [
    'git stash'
    'git stash clear'
    'git pull'
    'npm update'
    'gulp prune'
  ]