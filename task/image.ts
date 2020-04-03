import $ from '../lib/fire-keeper'

// export
export default async () => {

  let m = $.require('./source/module/image')
  m = m()

  const { target } = $.argv()
  await m.execute_(target)
}