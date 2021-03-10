import $i from 'fire-keeper/i'
import $info from 'fire-keeper/info'
import $prompt_ from 'fire-keeper/prompt_'
import $read_ from 'fire-keeper/read_'
import $say_ from 'fire-keeper/say_'
import kleur from 'kleur'

// function

const path = './data/50on.yaml' as const

const ask_ = async (
  list: string[]
): Promise<string> => {

  let seed = Math.floor(Math.random() * list.length)
  const _list = list[seed].split(',')
  const answer = _list[0]
  let char = _list[1]

  seed = Math.floor(Math.random() * 2)
  char = char[seed]

  const value = await $prompt_({
    default: 'exit',
    message: char,
    type: 'text',
  })

  if (value === 'exit') return ''

  let msg = `${char} -> ${answer}`
  msg = value === answer
    ? kleur.green(msg)
    : kleur.red(msg)
  $i(msg)

  $info().pause()
  await $say_(char, {
    lang: 'ja',
  })
  $info().resume()

  // loop
  return ask_(list)
}

const main_ = async (): Promise<void> => {
  await ask_(await load_())
}

const load_ = async (): Promise<string[]> => {
  return await $read_(path) as string[]
}

// export
export default main_