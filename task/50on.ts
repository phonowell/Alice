import $ from 'fire-keeper'
import kleur from 'kleur'

// function

class M {

  list: string[]
  path = './data/50on.yaml' as const

  // ---

  constructor() {
    this.list = []
  }

  // ---

  async ask_(): Promise<string> {

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

    if (value === 'exit') return ''

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

  async execute_(): Promise<void> {
    await this.load_()
    await this.ask_()
  }

  async load_(): Promise<void> {
    this.list = await $.read_(this.path) as string[]
  }
}

// export
const m = new M()
export default m.execute_.bind(m) as typeof m.execute_