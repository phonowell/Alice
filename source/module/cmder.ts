import $ from 'fire-keeper'

// interface

type Os = 'macos'

type Data = {
  [key: string]: string | string[]
}

// function

async function ask_(
  data: Data
): Promise<string> {

  const list = Object.keys(data)

  const value = await $.prompt_({
    id: 'cmd',
    list,
    message: 'command',
    type: 'auto',
  })

  if (!list.includes(value))
    return ''

  return value
}

async function main_(): Promise<void> {

  const os = $.os() as Os
  if (!['macos'].includes(os))
    throw new Error(`invalid os '${os}'`)

  const data = await load_(os)

  const target: string = $.argv()._[1] || $.argv().target || await ask_(data)
  if (!target) return

  const item = data[target]
  const cmd = typeof item === 'string'
    ? [item]
    : item

  await $.exec_(cmd)
}

async function load_(
  os: Os
): Promise<Data> {

  type File = {
    [key: string]: Data
  }

  const data = await $.read_('./data/cmd.yaml') as File
  return data[os]
}

// export
export default main_