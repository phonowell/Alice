import $ from 'fire-keeper'
import { customAlphabet } from 'nanoid'
import jimp from 'jimp'

// interface

type Path = {
  storage: string
  temp: string
}

// variable

const nanoid = customAlphabet('1234567890abcdefghijklmnopqrstuvwxyz', 8)

// function

async function clean_(
  path: Path
): Promise<void> {

  $.info('step', 'clean')
  await $.remove_(await $.source_(`${path.storage}/**/.DS_Store`))
}

async function convert_(
  path: Path
): Promise<void> {

  $.info('step', 'convert')

  const listSource = await $.source_([
    `${path.storage}/bmp/*.bmp`,
    `${path.storage}/png/*.png`,
    `${path.storage}/webp/*.webp`,
  ])

  async function sub_(
    source: string
  ): Promise<void> {

    const basename = $.getBasename(source)
    const target = `${path.storage}/jpg/${basename}.jpg`

    const img = await getImg_(source)
    img.write(target)

    await $.remove_(source)
  }

  await Promise.all(listSource.map(sub_))

  await $.remove_([
    `${path.storage}/bmp`,
    `${path.storage}/png`,
    `${path.storage}/webp`,
  ])
}

function genBasename(): string {
  return [
    nanoid(),
    'x',
    nanoid(),
  ].join('-')
}

async function getImg_(
  source: string
): Promise<jimp> {

  return jimp.read(source)
}

function getPath(): Path {

  const os = $.os()

  if (os === 'macos') return {
    storage: $.normalizePath('~/OneDrive/图片'),
    temp: $.normalizePath('~/Downloads'),
  }

  if (os === 'windows') return {
    storage: $.normalizePath('E:/OneDrive/图片'),
    temp: $.normalizePath('F:'),
  }

  throw new Error(`invalid os '${os}'`)
}

function getScale(
  width: number,
  height: number,
  maxWidth = 1920,
  maxHeight = 1080
): number {

  return Math.min(
    maxWidth / width,
    maxHeight / height
  )
}

async function main_(): Promise<void> {

  const path = getPath()

  await move_(path)
  await clean_(path)
  await convert_(path)
  await renameJpeg_(path)
  await resize_(path)
  await rename_(path)
}

async function move_(
  path: Path
): Promise<void> {

  $.info('step', 'move')

  // common
  async function sub_(
    extname: string
  ): Promise<void> {

    const listSource = await $.source_(`${path.temp}/*${extname}`)
    await $.move_(listSource, `${path.storage}/${extname.replace('.', '')}`)
  }
  await Promise.all(['.gif', '.jpg', '.mp4', '.png', '.webm', '.webp'].map(sub_))

  // jpeg
  const listSource = await $.source_(`${path.temp}/*.jpeg`)
  await $.move_(listSource, `${path.storage}/jpg`)
}

async function rename_(
  path: Path
): Promise<void> {

  $.info('step', 'rename')

  const listSource = await $.source_([
    `${path.storage}/**/*`,
    `!${path.storage}/*`,
  ])

  async function sub_(
    source: string
  ): Promise<void> {

    let basename = $.getBasename(source)
    if (validateBasename(basename)) return

    basename = genBasename()
    await $.rename_(source, { basename })
  }
  await Promise.all(listSource.map(sub_))
}

async function renameJpeg_(
  path: Path
): Promise<void> {

  $.info('step', 'renameJpeg')

  await Promise.all(
    (await $.source_(`${path.storage}/**/*.jpeg`))
      .map(source => $.rename_(source, {
        extname: '.jpg',
      }))
  )
}

async function resize_(
  path: Path
): Promise<void> {

  $.info('step', 'resize')

  async function sub_(
    source: string
  ): Promise<void> {

    const basename: string = $.getBasename(source)
    if (validateBasename(basename)) return

    const img = await getImg_(source)

    // check size
    const { width, height } = img.bitmap
    if (width <= 1920 && height <= 1080) return

    // scale
    img.scale(getScale(width, height))

    // save
    img.write(source)
  }

  await Promise.all(
    (await $.source_(`${path.storage}/**/*.jpg`))
      .map(sub_)
  )
}

function validateBasename(name: string): boolean {

  if (name.length !== 19) return false
  return name.search(/-x-/u) === 8
}

// export
export default main_