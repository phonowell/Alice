import $ = require('fire-keeper')

// export
module.exports = async () => {
  const fn_ = $.require('./source/module/douban')
  await fn_()
}