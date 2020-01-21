import $ = require('fire-keeper')

// export
module.exports = async () => {
  let fn_ = $.require('./srouce/module/douban')
  await fn_()
}