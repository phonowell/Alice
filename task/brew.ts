import $ from '../source/fire-keeper'

// function

class M {

  listIgnore = [
    'iterm2'
  ]

  // ---

  async check_(name: string) {

    const result = await $.exec_(`brew cask info ${name}`)
    const lines = result[1].split('\n')
    const version = lines[0].split(' ')[1].trim()

    if (!lines[2].includes(version)) {
      return true // outdated
    }

    return false // up-to-date

  }

  async list_() {

    const result = await $.exec_('brew cask list')
    const lines = result[1].split('\n')
    return lines

  }

  async execute_() {

    const list = await this.list_()

    const listResult = []
    for (const name of list) {

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

    const cmd = `brew cask reinstall ${listResult.join(' ')}`
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

  const m = new M()
  await m.execute_()

}