import $exec_ from 'fire-keeper/exec_'
import $os from 'fire-keeper/os'

// interface

type Os = 'macos' | 'windows'

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

const main = async (): Promise<void> => {

  const os = $os() as Os
  if (!['macos', 'windows'].includes(os))
    throw new Error(`invalid os '${os}'`)

  const cmd: string[] = mapCmd[os]

  await $exec_(cmd, {
    ignoreError: true,
  })
}

// export
export default main