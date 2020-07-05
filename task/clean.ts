import $ from '../lib/fire-keeper'

// function

class M {

  map = {
    '.ds_store': 'cleanDsStore_'
  }

  // ---

  async ask_() {

    let { target } = $.argv()
    const listTarget = Object.keys(this.map)

    target = target || await $.prompt_({
      id: 'clean',
      type: 'auto',
      message: 'input',
      list: listTarget
    })

    if (!listTarget.includes(target))
      throw new Error(`invalid target '${target}'`)

    const method: string = this.map[target]
    if (!method)
      throw new Error(`invalid target '${target}'`)

    return method
  }

  async cleanDsStore_() {

    if (!$.os('macos')) {
      $.info(`invalid os '${$.os()}'`)
      return
    }

    const source = await $.source_([
      '~/OneDrive/**/.DS_Store',
      '~/Project/**/.DS_Store'
    ])

    if (!source.length)
      return
    await $.remove_(source)
  }

  async execute_() {
    const method = await this.ask_()
    await this[method]()
  }
}

// export
export default async () => await (new M()).execute_()