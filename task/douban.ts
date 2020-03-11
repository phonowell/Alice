import $ from '../source/fire-keeper'

// export
module.exports = async () => {
  const fnAsync = $.require('./source/module/douban')
  await fnAsync()
}