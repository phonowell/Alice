import $ from '../lib/fire-keeper'

// export
export default async () => {

  if (!$.os('macos')) {
    $.info(`invalid os '${$.os()}'`)
    return
  }

  await $.exec_([
    'brew update',
    'brew upgrade',
    'brew cask upgrade'
  ])
}