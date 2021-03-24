import $argv from 'fire-keeper/argv'
import $exec_ from 'fire-keeper/exec_'
import $os from 'fire-keeper/os'
import $prompt_ from 'fire-keeper/prompt_'
import $read_ from 'fire-keeper/read_'

// interface

type Os = 'macos'

type Data = {
  [key: string]: string | string[]
}

// function

const ask = async (
  data: Data
): Promise<string> => {

  const list = Object.keys(data)

  const value = await $prompt_({
    id: 'cmd',
    list,
    message: 'command',
    type: 'auto',
  })

  if (!list.includes(value))
    return ''

  return value
}

const main = async (): Promise<void> => {

  const os = $os() as Os
  if (!['macos'].includes(os))
    throw new Error(`invalid os '${os}'`)

  const data = await load(os)

  const target: string = $argv()._[1] || $argv().target || await ask(data)
  if (!target) return

  const item = data[target]
  const cmd = typeof item === 'string'
    ? [item]
    : item

  await $exec_(cmd)
}

const load = async (
  os: Os
): Promise<Data> => {

  type File = {
    [key: string]: Data
  }

  const data = await $read_('./data/cmd.yaml') as File
  return data[os]
}

// export
export default main