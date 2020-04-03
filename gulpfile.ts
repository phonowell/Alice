import $ from './lib/fire-keeper'
import * as fs from 'fs'

// task
for (const filename of fs.readdirSync('./task')) {

  if (!filename.endsWith('.ts')) {
    continue
  }

  const name = filename.replace('.ts', '')
  $.task(name, async (...arg: any[]) => {
    const fnAsync = (await import(`./task/${name}.ts`)).default
    await fnAsync(...arg)
  })

}