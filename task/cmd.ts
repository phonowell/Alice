import _ = require('lodash')
import $ from '../source/fire-keeper'

// function

class M {

  async ask_(map) {

    let { target } = $.argv()
    const listKey = _.keys(map)

    target = target || await $.prompt_({
      id: 'cmd',
      type: 'auto',
      message: 'command',
      list: listKey
    })

    if (!listKey.includes(target)) {
      throw new Error(`invalid target '${target}'`)
    }

    return target

  }

  async execute_() {

    const map = await this.load_()
    const cmd = await this.ask_(map)

    let lines: string | string[] = map[cmd]
    let type: string = $.type(lines)

    if (type === 'string') {
      lines = [lines as string]
      type = $.type(lines)
    }

    if (type !== 'array') {
      throw new Error(`invalid command '${cmd}'`)
    }

    await $.exec_(lines)

    return this

  }

  async load_() {

    const data = await $.read_(`./data/cmd/${$.os()}.yaml`)
    if (!data) {
      $.info('warning', `invalid os '${$.os()}'`)
      return null
    }

    return data

  }

}

// export
module.exports = async () => {
  const m = new M()
  await m.execute_()
}