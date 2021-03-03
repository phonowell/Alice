import $ from 'fire-keeper'

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

async function main_(): Promise<void> {

  type Os = 'macos' | 'windows'

  const os = $.os() as Os
  if (!['macos', 'windows'].includes(os))
    throw new Error(`invalid os '${os}'`)

  const cmd: string[] = mapCmd[os]

  await $.exec_(cmd, {
    ignoreError: true,
  })

  await $.say_('Mission Completed')
}

// export
export default main_