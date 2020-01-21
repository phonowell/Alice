import _ = require('lodash')
import $ = require('fire-keeper')

// function

class M {

  ask_ = async (map) => {

    let { target } = $.argv()
    let listKey = _.keys(map)

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

  execute_ = async () => {

    let map = await this.load_()
    let cmd = await this.ask_(map)

    let lines = map[cmd]
    let type = $.type(lines)

    if (type === 'string') {
      lines = [lines]
      type = $.type(lines)
    }

    if (type !== 'array') {
      throw new Error(`invalid command '${cmd}'`)
    }

    await $.exec_(lines)

    return this

  }

  load_ = async () => {

    let data = await $.read_(`./data/cmd/${$.os()}.yaml`)
    if (!data) {
      $.info('warning', `invalid os '${$.os()}'`)
      return null
    }

    return data

  }

}

// export
module.exports = async () => {
  let m = new M()
  await m.execute_()
}