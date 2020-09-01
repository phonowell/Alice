import $ from 'fire-keeper'

// variable

const map = {
  macos: [
    'gulp brew',
    'gulp image',
    'gulp backup --target OneDrive',
    'gulp cmd --target resetlaunchpad'
  ],
  windows: [
    'gulp backup --target Game_Save',
    'gulp image',
    'gulp backup --target OneDrive'
  ]
}

// export
export default async () => {

  const lines = map[$.os()]
  if (!lines)
    throw new Error(`invalid os '${$.os()}'`)

  await $.exec_(lines, {
    ignoreError: true
  })

  await $.say_('Mission Completed')
}