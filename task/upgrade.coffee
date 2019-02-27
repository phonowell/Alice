$ = require 'fire-keeper'

# return
module.exports = ->

  await $.exec_ [
    'git stash'
    'git stash clear'
    'git pull'
    'npm update'
    'gulp prune'
  ]