import $ from 'fire-keeper'

// function

async function main_(): Promise<void> {

  if (!$.os('macos')) {
    $.info(`invalid os '${$.os()}'`)
    return
  }

  await $.exec_([
    'brew update',
    'brew upgrade',
    'brew upgrade --cask'
  ])
}

// export
export default main_