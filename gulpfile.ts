import $ = require('fire-keeper')
import fs = require('fs')

// task
for (const filename of fs.readdirSync('./task')) {

  if (!filename.endsWith('.ts')) {
    continue
  }

  const name = filename.replace('.ts', '')
  $.task(name, async (...arg: any[]) => {
    const fnAsync = require(`./task/${name}.ts`)
    await fnAsync(...arg)
  })

}