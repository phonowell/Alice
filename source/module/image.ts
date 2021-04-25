import $getBasename from 'fire-keeper/getBasename'
import $info from 'fire-keeper/info'
import $move_ from 'fire-keeper/move_'
import $normalizePath from 'fire-keeper/normalizePath'
import $os from 'fire-keeper/os'
import $remove_ from 'fire-keeper/remove_'
import $rename_ from 'fire-keeper/rename_'
import $source_ from 'fire-keeper/source_'
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

const clean = async (
  path: Path,
): Promise<void> => {

  $info('step', 'clean')
  await $remove_(await $source_(`${path.storage}/**/.DS_Store`))
}

const convert = async (
  path: Path,
): Promise<void> => {

  $info('step', 'convert')

  const listSource = await $source_([
    `${path.storage}/bmp/*.bmp`,
    `${path.storage}/png/*.png`,
    `${path.storage}/webp/*.webp`,
  ])

  const sub_ = async (
    source: string,
  ): Promise<void> => {

    const basename = $getBasename(source)
    const target = `${path.storage}/jpg/${basename}.jpg`

    const img = await getImg(source)
    img.write(target)

    await $remove_(source)
  }

  await Promise.all(listSource.map(sub_))

  await $remove_([
    `${path.storage}/bmp`,
    `${path.storage}/png`,
    `${path.storage}/webp`,
  ])
}

const genBasename = (): string => {
  return [
    nanoid(),
    'x',
    nanoid(),
  ].join('-')
}

const getImg = async (
  source: string,
): Promise<jimp> => {

  return jimp.read(source)
}

const getPath = (): Path => {

  const os = $os()

  if (os === 'macos') return {
    storage: $normalizePath('~/OneDrive/图片'),
    temp: $normalizePath('~/Downloads'),
  }

  if (os === 'windows') return {
    storage: $normalizePath('E:/OneDrive/图片'),
    temp: $normalizePath('F:'),
  }

  throw new Error(`invalid os '${os}'`)
}

const getScale = (
  width: number,
  height: number,
  maxWidth = 1920,
  maxHeight = 1080
): number => {

  return Math.min(
    maxWidth / width,
    maxHeight / height
  )
}

const main = async (): Promise<void> => {

  const path = getPath()

  await move(path)
  await clean(path)
  await convert(path)
  await renameJpeg(path)
  await resize(path)
  await rename(path)
}

const move = async (
  path: Path,
): Promise<void> => {

  $info('step', 'move')

  // common
  const sub_ = async (
    extname: string
  ): Promise<void> => {

    const listSource = await $source_(`${path.temp}/*${extname}`)
    await $move_(listSource, `${path.storage}/${extname.replace('.', '')}`)
  }
  await Promise.all(['.gif', '.jpg', '.mp4', '.png', '.webm', '.webp'].map(sub_))

  // jpeg
  const listSource = await $source_(`${path.temp}/*.jpeg`)
  await $move_(listSource, `${path.storage}/jpg`)
}

const rename = async (
  path: Path,
): Promise<void> => {

  $info('step', 'rename')

  const listSource = await $source_([
    `${path.storage}/**/*`,
    `!${path.storage}/*`,
  ])

  const sub_ = async (
    source: string
  ): Promise<void> => {

    let basename = $getBasename(source)
    if (validateBasename(basename)) return

    basename = genBasename()
    await $rename_(source, { basename })
  }
  await Promise.all(listSource.map(sub_))
}

const renameJpeg = async (
  path: Path,
): Promise<void> => {

  $info('step', 'renameJpeg')

  await Promise.all(
    (await $source_(`${path.storage}/**/*.jpeg`))
      .map(source => $rename_(source, {
        extname: '.jpg',
      }))
  )
}

const resize = async (
  path: Path,
): Promise<void> => {

  $info('step', 'resize')

  const sub_ = async (
    source: string,
  ): Promise<void> => {

    const basename: string = $getBasename(source)
    if (validateBasename(basename)) return

    const img = await getImg(source)

    // check size
    const { width, height } = img.bitmap
    if (width <= 1920 && height <= 1080) return

    // scale
    img.scale(getScale(width, height))

    // save
    img.write(source)
  }

  await Promise.all(
    (await $source_(`${path.storage}/**/*.jpg`))
      .map(sub_)
  )
}

const validateBasename = (name: string): boolean => {

  if (name.length !== 19) return false
  return name.search(/-x-/u) === 8
}

// export
export default main