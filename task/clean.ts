import $ = require('fire-keeper')

// function

class M {

  map = {
    '.ds_store': 'cleanDsStore_',
    'kindle': 'cleanKindle_',
    'trash': 'cleanTrash_'
  }

  // ---

  async ask_() {

    let { target } = $.argv()
    let listTarget = []
    for (const key in this.map) {
      listTarget.push(key)
    }

    target = target || await $.prompt_({
      id: 'clean',
      type: 'auto',
      message: 'input',
      list: listTarget
    })

    if (!listTarget.includes(target)) {
      throw new Error(`invalid target '${target}'`)
    }

    const method: string = this.map[target]
    if (!method) {
      throw new Error(`invalid target '${target}'`)
    }

    return method

  }

  async cleanDsStore_() {

    if (!$.os('macos')) {
      throw new Error(`invalid os '${$.os()}'`)
    }

    await $.remove_([
      '~/OneDrive/**/.DS_Store',
      '~/Project/**/.DS_Store'
    ])

    return this

  }

  async cleanKindle_() {

    if (!$.os('macos')) {
      throw new Error(`invalid os '${$.os()}'`)
    }

    const pathKindle = '/Volumes/Kindle/documents'
    if (!await $.isExisted_(pathKindle)) {
      throw new Error(`invalid path '${pathKindle}'`)
    }

    const listExtname = [
      '.azw',
      '.azw3',
      '.kfx',
      '.mobi'
    ]

    let listBook = []
    for (const extname of listExtname) {
      const listTemp: string[] = await $.source_(`${pathKindle}/${extname}`)
      for (const book of listTemp) {
        listBook.push($.getBasename(book))
      }
    }

    const listSdr: string[] = await $.source_(`${pathKindle}/*.sdr`)
    for (const sdr of listSdr) {
      const basename = $.getBasename(sdr)
      if (listBook.includes(basename)) {
        continue
      }
      await $.remove_(sdr)
    }

    return this

  }

  async cleanTrash_() {

    if (!$.os('macos')) {
      throw new Error(`invalid os '${$.os()}'`)
    }

    await $.remove_('~/.Trash/**/*')

    return this

  }

  async execute_() {

    const method = await this.ask_()
    await this[method]()

    return this

  }

}

// export
module.exports = async () => {
  const m = new M()
  await m.execute_()
}