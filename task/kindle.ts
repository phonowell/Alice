import $ from '../source/fire-keeper'

// function

class M {

  path = {
    document: '/Volumes/Kindle/documents',
    kindlegen: '/usr/local/bin/kindlegen',
    storage: '~/OneDrive/书籍/同步/*.txt',
    temp: './temp/kindle'
  }

  // ---

  async clean_() {
    await $.remove_(this.path.temp)
    return this
  }

  async execute_() {

    if (!await this.validate_()) {
      return
    }

    await this.rename_()

    for (const source of await $.source_(this.path.storage)) {

      if (await this.isExisted_(source)) {
        continue
      }

      await this.txt2html_(source)
      await this.html2mobi_(source)
      await this.move_(source)

    }

    await this.clean_()
    return this
  }

  async html2mobi_(source: string) {

    const { basename } = $.getName(source)
    const target = `${this.path.temp}/${basename}.html`

    const cmd = [
      this.path.kindlegen,
      `"${target}"`,
      '-c1',
      '-dont_append_source'
    ].join(' ')

    await $.exec_(cmd)
    return this
  }

  async isExisted_(source: string) {
    const { basename } = $.getName(source)
    return await $.isExisted_(`${this.path.document}/${basename}.mobi`)
  }

  async move_(source: string) {
    const { basename }: { basename: string } = $.getName(source)
    await $.copy_(`${this.path.temp}/${basename}.mobi`, this.path.document)
    return this
  }

  async rename_() {

    const listSource = await $.source_(this.path.storage)
    for (const source of listSource) {
      let { basename }: { basename: string } = $.getName(source)

      if (!(/[\s()[]]/).test(basename)) {
        continue
      }

      basename = basename
        .replace(/[\s()[]]/g, '')

      await $.rename_(source, { basename })
    }

    return this
  }

  async txt2html_(source: string) {

    const { basename }: { basename: string } = $.getName(source)
    const target = `${this.path.temp}/${basename}.html`

    const cont: string = await $.read_(source)
    const list = cont.split('\n')
    let result: string[] = []

    for (let line of list) {
      line = line.trim()
      if (!line) {
        continue
      }
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
    return this
  }

  async validate_() {

    if (!$.os('macos')) {
      $.info(`invalid os '${$.os()}'`)
      return false
    }

    if (!await $.isExisted_(this.path.kindlegen)) {
      $.info("found no 'kindlegen', run 'brew cask install kindlegen' to install it")
      return false
    }

    if (!await $.isExisted_(this.path.document)) {
      $.info(`found no '${this.path.document}'`)
      return false
    }

    return true
  }

}

// export
module.exports = async () => {
  const m = new M()
  await m.execute_()
}