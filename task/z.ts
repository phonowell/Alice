import $ from '../lib/fire-keeper'

// export
export default async () => {
  $.i(await $.exec_(`brew cask info qq`))
}