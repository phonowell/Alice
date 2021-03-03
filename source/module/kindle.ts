import $ from 'fire-keeper'

// variable

const path = {
  document: '/Volumes/Kindle/documents',
  kindlegen: '~/OneDrive/程序/kindlegen/kindlegen',
  storage: '~/OneDrive/书籍/同步/*.txt',
  temp: './temp/kindle',
} as const

// function

async function checkUnicode_(): Promise<boolean> {

  async function sub_(
    source: string
  ): Promise<boolean> {

    const content = await $.read_(source) as string
    return !~content.search(/我/u)
  }

  const listSource = await $.source_(path.storage)
  const listResult = await Promise.all(listSource.map(sub_))
  const listOutput: string[] = []
  listResult.forEach((result, i) => {
    if (result) listOutput.push($.getBasename(listSource[i]))
  })

  if (listOutput.length)
    $.info(`invalid file encoding: ${$.wrapList(listOutput)}`)

  return listOutput.length === 0
}

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
    '-dont_append_source',
  ].join(' ')

  await $.exec_(cmd)
}

async function isExistedOnKindle_(
  source: string
): Promise<boolean> {

  const { basename } = $.getName(source)
  return $.isExisted_(`${path.document}/${basename}.mobi`)
}

async function main_(): Promise<void> {

  if (!await validateEnvironment_()) return

  await renameBook_()
  if (!await checkUnicode_()) return

  async function sub_(
    source: string
  ): Promise<void> {

    if (await isExistedOnKindle_(source)) return

    await txt2html_(source)
    await html2mobi_(source)
    await moveToKindle_(source)
  }

  await Promise.all(
    (await $.source_(path.storage))
      .map(sub_)
  )

  await clean_()
}

async function moveToKindle_(
  source: string
): Promise<void> {

  const { basename } = $.getName(source)
  await $.copy_(`${path.temp}/${basename}.mobi`, path.document)
}

async function renameBook_(): Promise<void> {

  async function sub_(
    source: string
  ): Promise<void> {

    const { basename } = $.getName(source)

    const _basename = basename
      .replace(/,/gu, '，')
      .replace(/:/gu, '：')
      .replace(/\(/gu, '（')
      .replace(/\)/gu, '）')
      .replace(/</gu, '《')
      .replace(/>/gu, '》')
      .replace(/\[/gu, '【')
      .replace(/\]/gu, '】')
    // .replace(/\s/g, '')

    if (_basename === basename) return
    await $.rename_(source, { basename: _basename })
  }

  await Promise.all(
    (await $.source_(path.storage))
      .map(sub_)
  )
}

async function txt2html_(
  source: string
): Promise<void> {

  const { basename } = $.getName(source)
  const target = `${path.temp}/${basename}.html`

  const listContent = (
    await $.read_(source) as string
  ).split('\n')
  const listResult: string[] = []

  for (let line of listContent) {
    line = line.trim()
    if (!line) continue
    listResult.push(`<p>${line}</p>`)
  }

  const content = [
    '<html lang="zh-cmn-Hans">',
    '<head>',
    '<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>',
    '</head>',
    '<body>',
    listResult.join('\n'),
    '</body>',
    '</html>',
  ]

  await $.write_(target, content.join(''))
}

async function validateEnvironment_(): Promise<boolean> {

  if (!$.os('macos')) {
    $.info(`invalid os '${$.os()}'`)
    return false
  }

  if (!await $.isExisted_(path.kindlegen)) {
    $.info("found no 'kindlegen', run 'brew cask install kindlegen' to install it")
    return false
  }

  if (!await $.isExisted_(path.document)) {
    $.info(`found no '${path.document}', kindle must be connected`)
    return false
  }

  return true
}

// export
export default main_