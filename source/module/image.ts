import $ from '../../lib/fire-keeper'

import { customAlphabet } from 'nanoid'
const nanoid = customAlphabet('1234567890abcdefghijklmnopqrstuvwxyz', 8)
import * as jimp from 'jimp'

// function

class M {

  path: {
    storage: string
    temp: string
  }

  // ---

  constructor() {
    const path = this.getPath()
    if (!path)
      throw new Error(`invalid os '${$.os()}'`)
    this.path = path
  }

  // ---

  async clean_() {
    $.info('step', 'clean')
    await $.remove_(await $.source_(`${this.path.storage}/**/.DS_Store`))
  }

  async convert_() {
    $.info('step', 'convert')

    const listSource = await $.source_([
      `${this.path.storage}/bmp/*.bmp`,
      `${this.path.storage}/png/*.png`,
      `${this.path.storage}/webp/*.webp`
    ])

    for (const source of listSource) {

      const basename = $.getBasename(source)
      const target = `${this.path.storage}/jpg/${basename}.jpg`

      const img = await this.getImg_(source)
      img.write(target)

      await $.remove_(source)
    }

    await $.remove_([
      `${this.path.storage}/bmp`,
      `${this.path.storage}/png`,
      `${this.path.storage}/webp`
    ])
  }

  async execute_() {
    await this.move_()
    await this.clean_()
    await this.convert_()
    await this.renameJpeg_()
    await this.resize_()
    await this.rename_()
  }

  genBasename() {
    return [
      nanoid(),
      'x',
      nanoid()
    ].join('-')
  }

  async getImg_(source: string) {
    return await jimp.read(source)
  }

  getPath() {
    const os = $.os()

    if (os === 'macos') {
      return {
        storage: $.normalizePath('~/OneDrive/图片'),
        temp: $.normalizePath('~/Downloads')
      }
    }

    if (os === 'windows') {
      return {
        storage: $.normalizePath('E:/OneDrive/图片'),
        temp: $.normalizePath('F:')
      }
    }

    return null
  }

  getScale(width: number, height: number, maxWidth = 1920, maxHeight = 1080) {
    return Math.min(
      maxWidth / width,
      maxHeight / height
    )
  }

  async move_() {
    $.info('step', 'move')

    // common
    for (const extname of ['.gif', '.jpg', '.mp4', '.png', '.webm', '.webp']) {
      const listSource = await $.source_(`${this.path.temp}/*${extname}`)
      await $.move_(listSource, `${this.path.storage}/${extname.replace('.', '')}`)
    }

    // jpeg
    const listSource = await $.source_(`${this.path.temp}/*.jpeg`)
    await $.move_(listSource, `${this.path.storage}/jpg`)
  }

  async rename_() {
    $.info('step', 'rename')

    const listSource = await $.source_([
      `${this.path.storage}/**/*`,
      `!${this.path.storage}/*`
    ])

    for (const source of listSource) {

      let basename = $.getBasename(source)
      if (this.validateBasename(basename)) {
        continue
      }

      basename = this.genBasename()
      await $.rename_(source, { basename })
    }
  }

  async renameJpeg_() {
    $.info('step', 'renameJpeg')

    const listSource = await $.source_(`${this.path.storage}/**/*.jpeg`)
    for (const source of listSource) {
      await $.rename_(source, {
        extname: '.jpg'
      })
    }
  }

  async resize_() {
    $.info('step', 'resize')

    const listSource = await $.source_(`${this.path.storage}/**/*.jpg`)
    for (const source of listSource) {

      const basename: string = $.getBasename(source)
      if (this.validateBasename(basename)) {
        continue
      }

      const img = await this.getImg_(source)

      // check size
      const { width, height } = img.bitmap
      if (width <= 1920 && height <= 1080) {
        continue
      }

      // scale
      img.scale(this.getScale(width, height))

      // save
      img.write(source)
    }
  }

  validateBasename(name: string) {
    if (name.length !== 19)
      return false
    return name.search(/-x-/) === 8
  }
}

// export
export default new M()