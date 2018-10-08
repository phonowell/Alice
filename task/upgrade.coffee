$ = require 'fire-keeper'
{_} = $

# return
module.exports = ->

  await $.shell_ [
    'git stash'
    'git stash clear'
    'git pull'
    'npm update'
    'gulp prune'
  ]