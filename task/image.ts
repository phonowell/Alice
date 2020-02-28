import $ = require('fire-keeper')

// export
module.exports = async () => {

  let m = $.require('./source/module/image')
  m = m()

  const { target } = $.argv()
  await m.execute_(target)
}