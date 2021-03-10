import $exec_ from 'fire-keeper/exec_'
import $info from 'fire-keeper/info'
import $os from 'fire-keeper/os'

// function

const main_ = async (): Promise<void> => {

  if (!$os('macos')) {
    $info(`invalid os '${$os()}'`)
    return
  }

  await $exec_([
    'brew update',
    'brew upgrade',
    'brew upgrade --cask',
  ])
}

// export
export default main_