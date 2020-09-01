import $ from 'fire-keeper'

// function

async function main_(): Promise<void> {

  if (!$.os('macos')) {
    $.info(`invalid os '${$.os()}'`)
    return
  }

  const listSource = await $.source_([
    '~/OneDrive/**/.DS_Store',
    '~/Project/**/.DS_Store'
  ])

  if (!listSource.length) return
  await $.remove_(listSource)
}

// export
export default main_