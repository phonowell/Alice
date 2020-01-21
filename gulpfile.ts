import $ = require('fire-keeper')
import fs = require('fs')

// task
for (let filename of fs.readdirSync('./task')) {

  if (!filename.endsWith('.ts')) {
    continue
  }

  let name = filename.replace(/\.ts/, '')
  $.task(name, async (...arg) => {
    let fn_ = require(`./task/${name}.ts`)
    await fn_(...arg)
  })

}