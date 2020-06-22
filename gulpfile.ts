import $ from './lib/fire-keeper'
import * as fs from 'fs'

// interface

type IFn = (...args: any[]) => unknown

// task
for (const filename of fs.readdirSync('./task')) {

  if (!filename.endsWith('.ts')) continue

  const name = filename.replace('.ts', '')
  $.task(name, async (...args: any[]) => {
    const fnAsync = (await import(`./task/${name}.ts`)).default as IFn
    await fnAsync(...args)
  })
}