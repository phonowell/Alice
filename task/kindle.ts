import $ from 'fire-keeper'

// variable

const path = {
  document: '/Volumes/Kindle/documents',
  kindlegen: '~/OneDrive/程序/kindlegen/kindlegen',
  storage: '~/OneDrive/书籍/同步/*.txt',
  temp: './temp/kindle'
} as const

// function

async function clean_(): Promise<void> {
  await $.remove_(path.temp)
}

async function html2mobi_(
  source: string
): Promise<void> {

  const { basename } = $.getName(source)
  const target = `${path.temp}/${basename}.html`

  const cmd = [
    path.kindlegen,
    `"${target}"`,
    '-c1',
    '-dont_append_source'
  ].join(' ')

  await $.exec_(cmd)
}

async function isExisted_(
  source: string
): Promise<boolean> {

  const { basename } = $.getName(source)
  return await $.isExisted_(`${path.document}/${basename}.mobi`)
}

async function main_(): Promise<void> {

  if (!await validate_()) return

  await rename_()

  for (const source of await $.source_(path.storage)) {

    if (await isExisted_(source)) continue

    await txt2html_(source)
    await html2mobi_(source)
    await move_(source)
  }

  await clean_()
}

async function move_(
  source: string
): Promise<void> {

  const { basename } = $.getName(source)
  await $.copy_(`${path.temp}/${basename}.mobi`, path.document)
}

async function rename_(): Promise<void> {

  const listSource = await $.source_(path.storage)
  for (const source of listSource) {
    let { basename } = $.getName(source)

    if (!(/[\s()[]]/).test(basename)) continue

    basename = basename
      .replace(/[\s()[]]/g, '')

    await $.rename_(source, { basename })
  }
}

async function txt2html_(
  source: string
): Promise<void> {

  const { basename } = $.getName(source)
  const target = `${path.temp}/${basename}.html`

  const cont = await $.read_(source) as string
  const list = cont.split('\n')
  let result = [] as string[]

  for (let line of list) {
    line = line.trim()
    if (!line) continue
    result.push(`<p>${line}</p>`)
  }

  result = [
    '<html lang="zh-cmn-Hans">',
    '<head>',
    '<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>',
    '</head>',
    '<body>',
    result.join('\n'),
    '</body>',
    '</html>'
  ]

  await $.write_(target, result.join(''))
}

async function validate_(): Promise<boolean> {

  if (!$.os('macos')) {
    $.info(`invalid os '${$.os()}'`)
    return false
  }

  if (!await $.isExisted_(path.kindlegen)) {
    $.info("found no 'kindlegen', run 'brew cask install kindlegen' to install it")
    return false
  }

  if (!await $.isExisted_(path.document)) {
    $.info(`found no '${path.document}'`)
    return false
  }

  return true
}

// export
export default main_