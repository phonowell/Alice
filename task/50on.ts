import $ from '../lib/fire-keeper'
import * as kleur from 'kleur'

// function

class M {

  list: string[]
  path = './data/50on.yaml'

  // ---

  constructor() {
    this.list = []
  }

  // ---

  async ask_() {

    let seed = Math.floor(Math.random() * this.list.length)
    let answer: string
    let char: string
    [answer, char] = (this.list[seed]).split(',')

    seed = Math.floor(Math.random() * 2)
    char = char[seed]

    const value = await $.prompt_({
      type: 'text',
      message: char,
      default: 'exit'
    })

    if (value === 'exit') return

    let msg = `${char} -> ${answer}`
    msg = value === answer
      ? kleur.green(msg)
      : kleur.red(msg)
    $.i(msg)

    $.info().pause()
    await $.say_(char, {
      lang: 'ja'
    })
    $.info().resume()

    // loop
    return this.ask_()
  }

  async execute_() {
    await this.loadData_()
    await this.ask_()
  }

  async loadData_() {
    this.list = await $.read_(this.path) as string[]
  }
}

// export
export default async () => await (new M()).execute_()