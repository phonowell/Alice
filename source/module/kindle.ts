import $copy_ from 'fire-keeper/copy_'
import $exec_ from 'fire-keeper/exec_'
import $getBasename from 'fire-keeper/getBasename'
import $getName from 'fire-keeper/getName'
import $info from 'fire-keeper/info'
import $isExisted_ from 'fire-keeper/isExisted_'
import $os from 'fire-keeper/os'
import $read_ from 'fire-keeper/read_'
import $remove_ from 'fire-keeper/remove_'
import $rename_ from 'fire-keeper/rename_'
import $source_ from 'fire-keeper/source_'
import $wrapList from 'fire-keeper/wrapList'
import $write_ from 'fire-keeper/write_'

// variable

const path = {
  document: '/Volumes/Kindle/documents',
  kindlegen: '~/OneDrive/程序/kindlegen/kindlegen',
  storage: '~/OneDrive/书籍/同步/*.txt',
  temp: './temp/kindle',
} as const

// function

const checkUnicode = async (): Promise<boolean> => {

  const sub_ = async (
    source: string,
  ): Promise<boolean> => {

    const content = await $read_<string>(source)
    return !~content.search(/我/u)
  }

  const listSource = await $source_(path.storage)
  const listResult = await Promise.all(listSource.map(sub_))
  const listOutput: string[] = []
  listResult.forEach((result, i) => {
    if (result) listOutput.push($getBasename(listSource[i]))
  })

  if (listOutput.length)
    $info(`invalid file encoding: ${$wrapList(listOutput)}`)

  return listOutput.length === 0
}

const clean = async (): Promise<void> => {
  await $remove_(path.temp)
}

const html2mobi = async (
  source: string,
): Promise<void> => {

  const { basename } = $getName(source)
  const target = `${path.temp}/${basename}.html`

  const cmd = [
    path.kindlegen,
    `"${target}"`,
    '-c1',
    '-dont_append_source',
  ].join(' ')

  await $exec_(cmd)
}

const isExistedOnKindle = async (
  source: string,
): Promise<boolean> => {

  const { basename } = $getName(source)
  return $isExisted_(`${path.document}/${basename}.mobi`)
}

const main = async (): Promise<void> => {

  if (!await validateEnvironment()) return

  await renameBook()
  if (!await checkUnicode()) return

  const sub_ = async (
    source: string
  ): Promise<void> => {

    if (await isExistedOnKindle(source)) return

    await txt2html(source)
    await html2mobi(source)
    await moveToKindle(source)
  }

  await Promise.all(
    (await $source_(path.storage))
      .map(sub_)
  )

  await clean()
}

const moveToKindle = async (
  source: string,
): Promise<void> => {

  const { basename } = $getName(source)
  await $copy_(`${path.temp}/${basename}.mobi`, path.document)
}

const renameBook = async (): Promise<void> => {

  const sub_ = async (
    source: string,
  ): Promise<void> => {

    const { basename } = $getName(source)

    const _basename = basename
      .replace(/,/gu, '，')
      .replace(/:/gu, '：')
      .replace(/\(/gu, '（')
      .replace(/\)/gu, '）')
      .replace(/</gu, '《')
      .replace(/>/gu, '》')
      .replace(/\[/gu, '【')
      .replace(/\]/gu, '】')

    if (_basename === basename) return
    await $rename_(source, { basename: _basename })
  }

  await Promise.all(
    (await $source_(path.storage))
      .map(sub_)
  )
}

const txt2html = async (
  source: string,
): Promise<void> => {

  const { basename } = $getName(source)
  const target = `${path.temp}/${basename}.html`

  const listContent = (
    await $read_<string>(source)
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

  await $write_(target, content.join(''))
}

const validateEnvironment = async (): Promise<boolean> => {

  if (!$os('macos')) {
    $info(`invalid os '${$os()}'`)
    return false
  }

  if (!await $isExisted_(path.kindlegen)) {
    $info("found no 'kindlegen', run 'brew cask install kindlegen' to install it")
    return false
  }

  if (!await $isExisted_(path.document)) {
    $info(`found no '${path.document}', kindle must be connected`)
    return false
  }

  return true
}

// export
export default main