import $ from '../lib/fire-keeper'

// export
export default async () => {
  const fnAsync = $.require('./source/module/douban')
  await fnAsync()
}