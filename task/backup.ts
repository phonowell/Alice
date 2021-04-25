import $os from 'fire-keeper/os'
import $zip_ from 'fire-keeper/zip_'

// function

const main = async () => {

  const os = $os()
  if (os !== 'macos' && os !== 'windows')
    throw new Error(`invalid os '${os}'`)

  const path = {
    macos: '~/OneDrive',
    windows: 'E:/OneDrive',
  }[os]

  await $zip_(`${path}/**/*`, `${path}/..`, 'OneDrive.zip')
}

// export
export default main