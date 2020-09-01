import $ from 'fire-keeper'

// function

async function main_(): Promise<void> {

  const map = {
    macos: '~/OneDrive',
    windows: 'E:/OneDrive'
  }

  const pathStorage = map[$.os()]
  if (!pathStorage)
    throw new Error(`invalid os '${$.os()}'`)

  await $.zip_(`${pathStorage}/**/*`, `${pathStorage}/..`, 'OneDrive.zip')
}

// export
export default main_