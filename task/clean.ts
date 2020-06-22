import $ from '../lib/fire-keeper'

// function

class M {

  map = {
    '.ds_store': 'cleanDsStore_',
    'trash': 'cleanTrash_'
  }

  // ---

  async ask_() {

    let { target } = $.argv()
    const listTarget = [] as string[]
    for (const key in this.map) {
      if (!this.map.hasOwnProperty(key)) {
        continue
      }
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
      $.info(`invalid os '${$.os()}'`)
      return
    }

    await $.remove_([
      '~/OneDrive/**/.DS_Store',
      '~/Project/**/.DS_Store'
    ])
  }

  async cleanTrash_() {

    if (!$.os('macos')) {
      $.info(`invalid os '${$.os()}'`)
      return
    }

    await $.remove_('~/.Trash/**/*')
  }

  async execute_() {
    const method = await this.ask_()
    await this[method]()
  }
}

// export
export default async () => await (new M()).execute_()