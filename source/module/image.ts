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

class M {

  path: Path

  constructor() {
    const path = this.getPath()
    if (!path)
      throw new Error(`invalid os '${$.os()}'`)
    this.path = path
  }

  async clean_(): Promise<void> {

    $.info('step', 'clean')
    await $.remove_(await $.source_(`${this.path.storage}/**/.DS_Store`))
  }

  async convert_(): Promise<void> {

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

  async execute_(): Promise<void> {

    await this.move_()
    await this.clean_()
    await this.convert_()
    await this.renameJpeg_()
    await this.resize_()
    await this.rename_()
  }

  genBasename(): string {
    return [
      nanoid(),
      'x',
      nanoid()
    ].join('-')
  }

  async getImg_(source: string): Promise<jimp> {
    return await jimp.read(source)
  }

  getPath(): Path | undefined {

    if ($.os('macos')) {
      return {
        storage: $.normalizePath('~/OneDrive/图片'),
        temp: $.normalizePath('~/Downloads')
      }
    }

    if ($.os('windows')) {
      return {
        storage: $.normalizePath('E:/OneDrive/图片'),
        temp: $.normalizePath('F:')
      }
    }

    return
  }

  getScale(
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

  async move_(): Promise<void> {

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

  async rename_(): Promise<void> {

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

  async renameJpeg_(): Promise<void> {

    $.info('step', 'renameJpeg')

    const listSource = await $.source_(`${this.path.storage}/**/*.jpeg`)
    for (const source of listSource) {
      await $.rename_(source, {
        extname: '.jpg'
      })
    }
  }

  async resize_(): Promise<void> {

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

  validateBasename(name: string): boolean {

    if (name.length !== 19)
      return false
    return name.search(/-x-/) === 8
  }
}

// export
export default new M()