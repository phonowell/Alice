import $exec_ from 'fire-keeper/exec_'
import $os from 'fire-keeper/os'

// variable

const mapCmd = {
  macos: [
    'npm run alice brew',
    'npm run alice image',
    'npm run alice backup',
    'npm run alice cmd resetlaunchpad',
  ],
  windows: [
    'npm run alice image',
    'npm run alice backup',
  ],
}

// function

const main = async () => {

  const os = $os()
  if (os !== 'macos' && os !== 'windows')
    throw new Error(`invalid os '${os}'`)

  await $exec_(mapCmd[os], {
    ignoreError: true,
  })
}

// export
export default main