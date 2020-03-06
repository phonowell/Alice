import $ = require('fire-keeper')

// export
module.exports = async () => {

  await $.remove_([
    './source/**/*.coffee',
    './task/**/*.coffee'
  ])

}