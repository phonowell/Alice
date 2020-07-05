import $ from '../lib/fire-keeper'

// function

class M {

  pathStorage: string

  map = {
    'Game Save': 'backupGameSave_',
    'OneDrive': 'backupOneDrive_'
  } as {
    [key: string]: string
  }

  // ---

  constructor() {

    const map = {
      macos: '~/OneDrive',
      windows: 'E:/OneDrive'
    }

    this.pathStorage = map[$.os()]
    if (!this.pathStorage)
      throw new Error(`invalid os '${$.os()}'`)
  }

  // ---

  async ask_() {

    let { target } = $.argv()
    const listTarget = Object.keys(this.map)

    target = target || await $.prompt_({
      type: 'auto',
      message: 'input',
      list: listTarget
    })

    target = target
      .replace(/_/g, ' ')

    if (!listTarget.includes(target))
      throw new Error(`invalid target '${target}'`)

    const method = this.map[target]
    if (!method)
      throw new Error(`invalid target '${target}'`)

    return method
  }

  async backupOneDrive_() {
    await $.zip_(`${this.pathStorage}/**/*`, `${this.pathStorage}/..`, 'OneDrive.zip')
  }

  async execute_() {
    const method = await this.ask_()
    await this[method]()
  }
}

// export
export default async () => await (new M()).execute_()