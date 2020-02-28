import $ = require('fire-keeper')

// export
module.exports = async () => {

  let list = Array.from({ length: 10 }, (item, index) => index + 1)
  $.i(list)

}