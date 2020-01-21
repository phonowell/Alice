import $ = require('fire-keeper')

// function

class M {

  listIgnore = [
    'iterm2'
  ]

  // ---

  check_ = async (name) => {

    let result = await $.exec_(`brew cask info ${name}`)
    let lines = result[1].split('\n')
    let version = lines[0].split(' ')[1].trim()

    if (!~lines[2].includes(version)) {
      return true // outdated
    }

    return false // up-to-date

  }

  list_ = async () => {

    let result = await $.exec_('brew cask list')
    let lines = result[1].split('\n')
    return lines

  }

  execute_ = async () => {

    let list = await this.list_()

    let listResult = []
    for (let name of list) {

      if (this.listIgnore.includes(name)) {
        continue
      }

      if (await this.check_(name)) {
        listResult.push(name)
      }

    }

    if (!listResult.length) {
      return this
    }

    let cmd = `brew cask reinstall ${listResult.join(' ')}`
    await $.exec_(cmd)

    return this

  }

}

// export
module.exports = async () => {

  if (!$.os('macos')) {
    throw new Error(`invalid os '${$.os()}'`)
  }

  await $.exec_([
    'brew update',
    'brew upgrade',
    'brew cask upgrade'
  ])

  let m = new M()
  await m.execute_()

}