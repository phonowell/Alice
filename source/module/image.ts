import * as _ from 'lodash'
import $ from '../../lib/fire-keeper'

import { customAlphabet } from 'nanoid'
const nanoid = customAlphabet('1234567890abcdefghijklmnopqrstuvwxyz', 8)
import * as jimp from 'jimp'

// function

class Image {

  storage: string
  temp: string

  // ---

  constructor() {

    // storage

    let map = {
      macos: '~/OneDrive/图片',
      windows: 'E:/OneDrive/图片'
    }

    this.storage = map[$.os()]
    if (!this.storage) {
      throw new Error(`invalid os '${$.os()}'`)
    }

    // temp

    map = {
      macos: '~/Downloads',
      windows: 'F:'
    }

    this.temp = map[$.os()]
    if (!this.temp) {
      throw new Error(`invalid os '${$.os()}'`)
    }

  }

  // ---

  async clean_() {
    $.info('step', 'clean')
    await $.remove_(await $.source_(`${this.storage}/**/.DS_Store`))
    return this
  }

  async convert_() {
    $.info('step', 'convert')

    const listSource: string[] = await $.source_([
      `${this.storage}/bmp/*.bmp`,
      `${this.storage}/png/*.png`,
      `${this.storage}/webp/*.webp`
    ])

    for (const source of listSource) {

      const basename: string = $.getBasename(source)
      const target = `${this.storage}/jpg/${basename}.jpg`

      const img = await this.getImg_(source)
      img.write(target)

      await $.remove_(source)

    }

    await $.remove_([
      `${this.storage}/bmp`,
      `${this.storage}/png`,
      `${this.storage}/webp`
    ])

    return this
  }

  async execute_() {

    await this.move_()
    await this.clean_()
    await this.convert_()
    await this.renameJpeg_()
    await this.resize_()
    await this.rename_()

    return this
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

  getScale(width: number, height: number, maxWidth = 1920, maxHeight = 1080) {
    return _.min([
      maxWidth / width,
      maxHeight / height
    ])
  }

  async move_() {
    $.info('step', 'move')

    // jpg & jpeg
    for (const extname of ['.jpeg', '.jpg']) {
      const listSource = await $.source_(`${this.temp}/*${extname}`)
      await $.move_(listSource, `${this.storage}/jpg`)
    }

    // other
    for (const extname of ['.gif', '.mp4', '.png', '.webm', '.webp']) {
      const listSource = await $.source_(`${this.temp}/*${extname}`)
      await $.move_(listSource, `${this.storage}/${extname.replace('.', '')}`)
    }

    return this
  }

  async rename_() {
    $.info('step', 'rename')

    const listSource: string[] = await $.source_([
      `${this.storage}/**/*`,
      `!${this.storage}/*`
    ])

    for (const source of listSource) {

      let basename: string = $.getBasename(source)
      if (this.validateBasename(basename)) {
        continue
      }

      basename = this.genBasename()
      await $.rename_(source, { basename })

    }

    return this
  }

  async renameJpeg_() {
    $.info('step', 'renameJpeg')

    const listSource: string[] = await $.source_(`${this.storage}/**/*.jpeg`)
    for (const source of listSource) {
      await $.rename_(source, {
        extname: '.jpg'
      })
    }

    return this
  }

  async resize_() {
    $.info('step', 'resize')

    const listSource: string[] = await $.source_(`${this.storage}/**/*.jpg`)
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

    return this
  }

  validateBasename(name: string) {
    if (name.length !== 19) {
      return false
    }
    return name.search(/-x-/) === 8
  }

}

// export
module.exports = () => {
  return new Image()
}