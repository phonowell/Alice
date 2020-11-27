import $ from 'fire-keeper'
import jimp from 'jimp'
import { customAlphabet } from 'nanoid'

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
    `${path.storage}/webp/*.webp`
  ])

  for (const source of listSource) {

    const basename = $.getBasename(source)
    const target = `${path.storage}/jpg/${basename}.jpg`

    const img = await getImg_(source)
    img.write(target)

    await $.remove_(source)
  }

  await $.remove_([
    `${path.storage}/bmp`,
    `${path.storage}/png`,
    `${path.storage}/webp`
  ])
}

function genBasename(): string {
  return [
    nanoid(),
    'x',
    nanoid()
  ].join('-')
}

async function getImg_(
  source: string
): Promise<jimp> {

  return await jimp.read(source)
}

function getPath(): Path {

  const os = $.os()

  if (os === 'macos') return {
    storage: $.normalizePath('~/OneDrive/图片'),
    temp: $.normalizePath('~/Downloads')
  }

  if (os === 'windows') return {
    storage: $.normalizePath('E:/OneDrive/图片'),
    temp: $.normalizePath('F:')
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
  for (const extname of ['.gif', '.jpg', '.mp4', '.png', '.webm', '.webp']) {
    const listSource = await $.source_(`${path.temp}/*${extname}`)
    await $.move_(listSource, `${path.storage}/${extname.replace('.', '')}`)
  }

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
    `!${path.storage}/*`
  ])

  for (const source of listSource) {

    let basename = $.getBasename(source)
    if (validateBasename(basename)) continue

    basename = genBasename()
    await $.rename_(source, { basename })
  }
}

async function renameJpeg_(
  path: Path
): Promise<void> {

  $.info('step', 'renameJpeg')

  const listSource = await $.source_(`${path.storage}/**/*.jpeg`)
  for (const source of listSource)
    await $.rename_(source, {
      extname: '.jpg'
    })
}

async function resize_(
  path: Path
): Promise<void> {

  $.info('step', 'resize')

  const listSource = await $.source_(`${path.storage}/**/*.jpg`)
  for (const source of listSource) {

    const basename: string = $.getBasename(source)
    if (validateBasename(basename)) continue

    const img = await getImg_(source)

    // check size
    const { width, height } = img.bitmap
    if (width <= 1920 && height <= 1080) continue

    // scale
    img.scale(getScale(width, height))

    // save
    img.write(source)
  }
}

function validateBasename(name: string): boolean {

  if (name.length !== 19) return false
  return name.search(/-x-/) === 8
}

// export
export default main_