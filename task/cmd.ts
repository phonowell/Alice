import $ from '../lib/fire-keeper'

// function

class M {

  async ask_(map: object) {

    let { target } = $.argv()
    const listKey = Object.keys(map)

    target = target || await $.prompt_({
      id: 'cmd',
      type: 'auto',
      message: 'command',
      list: listKey
    })

    if (!listKey.includes(target))
      throw new Error(`invalid target '${target}'`)

    return target
  }

  async execute_() {

    const map = await this.load_()
    if (!map) return

    const cmd = await this.ask_(map)

    let lines = map[cmd]

    if (typeof lines === 'string')
      lines = [lines]

    if (!(lines instanceof Array))
      throw new Error(`invalid command '${cmd}'`)

    await $.exec_(lines)
  }

  async load_() {

    const data = await $.read_(`./data/cmd/${$.os()}.yaml`) as {
      [key: string]: string[] | string
    }
    if (!data) {
      $.info('warning', `invalid os '${$.os()}'`)
      return null
    }

    return data
  }
}

// export
export default async () => await (new M()).execute_()