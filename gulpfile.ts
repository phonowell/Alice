import $ = require('fire-keeper')
import fs = require('fs')

// task
for (const filename of fs.readdirSync('./task')) {

  if (!filename.endsWith('.ts')) {
    continue
  }

  const name = filename.replace(/\.ts/, '')
  $.task(name, async (...arg: any[]) => {
    const fn_ = require(`./task/${name}.ts`)
    await fn_(...arg)
  })

}