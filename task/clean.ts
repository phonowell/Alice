import $ = require('fire-keeper')

// function

class M {

  map = {
    '.ds_store': 'cleanDsStore_',
    'kindle': 'cleanKindle_',
    'trash': 'cleanTrash_'
  }

  // ---

  ask_ = async () => {

    let { target } = $.argv()
    let listTarget = []
    for (let key in this.map) {
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

    let method = this.map[target]
    if (!method) {
      throw new Error(`invalid target '${target}'`)
    }

    return method

  }

  cleanDsStore_ = async () => {

    if (!$.os('macos')) {
      throw new Error(`invalid os '${$.os()}'`)
    }

    await $.remove_([
      '~/OneDrive/**/.DS_Store',
      '~/Project/**/.DS_Store'
    ])

    return this

  }

  cleanKindle_ = async () => {

    if (!$.os('macos')) {
      throw new Error(`invalid os '${$.os()}'`)
    }

    let pathKindle = '/Volumes/Kindle/documents'
    if (!await $.isExisted_(pathKindle)) {
      throw new Error(`invalid path '${pathKindle}'`)
    }

    let listExtname = [
      '.azw',
      '.azw3',
      '.kfx',
      '.mobi'
    ]

    let listBook = []
    for (let extname of listExtname) {
      let listTemp = await $.source_(`${pathKindle}/${extname}`)
      for (let book of listTemp) {
        listBook.push($.getBasename(book))
      }
    }

    let listSdr = await $.source_(`${pathKindle}/*.sdr`)
    for (let sdr of listSdr) {
      let basename = $.getBasename(sdr)
      if (listBook.includes(basename)) {
        continue
      }
      await $.remove_(sdr)
    }

    return this

  }

  cleanTrash_ = async () => {

    if (!$.os('macos')) {
      throw new Error(`invalid os '${$.os()}'`)
    }

    await $.remove_('~/.Trash/**/*')

    return this

  }

  execute_ = async () => {

    let method = await this.ask_()
    await this[method]()

    return this

  }

}

// export
module.exports = async () => {
  let m = new M()
  await m.execute_()
}