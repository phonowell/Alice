import $info from 'fire-keeper/info'
import $os from 'fire-keeper/os'
import $remove_ from 'fire-keeper/remove_'
import $source_ from 'fire-keeper/source_'

// function

const main = async (): Promise<void> => {

  if (!$os('macos')) {
    $info(`invalid os '${$os()}'`)
    return
  }

  const listSource = await $source_([
    '~/OneDrive/**/.DS_Store',
    '~/Project/**/.DS_Store',
  ])

  if (!listSource.length) return
  await $remove_(listSource)
}

// export
export default main