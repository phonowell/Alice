import $ = require('fire-keeper')
import kleur = require('kleur')

// function

class M {

  list: []

  // ---

  ask_ = async () => {

    let seed = Math.floor(Math.random() * this.list.length)
    let [answer, char] = (this.list[seed] as string).split(',')

    seed = Math.floor(Math.random() * 2)
    char = char[seed]

    let value = await $.prompt_({
      type: 'text',
      message: char,
      default: 'exit'
    })

    if (value === 'exit') {
      return this
    }

    let msg = `${char} -> ${answer}`
    msg = value === answer ? kleur.green(msg) : kleur.red(msg)

    $.i(msg)

    await $.info().silence_(async () => {
      await $.say_(char, {
        lang: 'ja'
      })
    })

    // loop
    return this.ask_()

    // return this

  }

  execute_ = async () => {

    await this.loadData_()
    await this.ask_()

    return this

  }

  loadData_ = async () => {

    this.list = await $.read_('./data/50on.yaml')
    return this

  }

}

// export
module.exports = async () => {
  let m = new M()
  await m.execute_()
}