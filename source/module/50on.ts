import $ from 'fire-keeper'
import kleur from 'kleur'

// function

const path = './data/50on.yaml' as const

async function ask_(
  list: string[]
): Promise<string> {

  let seed = Math.floor(Math.random() * list.length)
  let answer: string
  let char: string
  [answer, char] = (list[seed]).split(',')

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
  return ask_(list)
}

async function main_(): Promise<void> {
  await ask_(await load_())
}

async function load_(): Promise<string[]> {
  return await $.read_(path) as string[]
}

// export
export default main_