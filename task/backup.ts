import $ from 'fire-keeper'

// function

async function main_(): Promise<void> {

  type Os = 'macos' | 'windows'

  const os = $.os() as Os
  if (!['macos', 'windows'].includes(os))
    throw new Error(`invalid os '${os}'`)

  const path = {
    macos: '~/OneDrive',
    windows: 'E:/OneDrive'
  }[os]

  await $.zip_(`${path}/**/*`, `${path}/..`, 'OneDrive.zip')
}

// export
export default main_