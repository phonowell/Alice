import _ = require('lodash')
import $ from '../source/fire-keeper'

// interface

interface IChoice {
  title: string
  value: string
}

// function

class M {

  async ask_(source: string, target: string) {

    const isExisted = [
      await $.isExisted_(source),
      await $.isExisted_(target)
    ]

    let mtime: number[]
    if (isExisted[0] && isExisted[1]) {
      mtime = [
        (await $.stat_(source)).mtimeMs,
        (await $.stat_(target)).mtimeMs
      ]
    } else {
      mtime = [0, 0]
    }

    const listChoice = [] as IChoice[]

    if (isExisted[0]) {
      listChoice.push({
        title: [
          'overwrite, export',
          mtime[0] > mtime[1] ? '(newer)' : ''
        ].join(' '),
        value: 'export'
      })
    }

    if (isExisted[1]) {
      listChoice.push({
        title: [
          'overwrite, import',
          mtime[1] > mtime[0] ? '(newer)' : ''
        ].join(' '),
        value: 'import'
      })
    }

    listChoice.push({
      title: 'skip',
      value: 'skip'
    })

    return await $.prompt_({
      list: listChoice,
      message: 'and you decide to...',
      type: 'select'
    })

  }

  async execute_() {

    const data = await this.load_()

    // diff
    for (const line of data) {

      let path: string
      let extra: string
      [path, extra] = line.split('@')
      extra = extra || ''

      let [namespace, version] = extra.split('/')
      namespace = namespace || 'default'
      version = version || '0.0.1'

      const source = `./${path}`
      let target = `../midway/${path}`
      const { basename, dirname, extname } = $.getName(target)
      target = `${dirname}/${basename}-${namespace}-${version}${extname}`

      if (await $.isSame_([source, target])) {
        continue
      }

      $.info(`'${source}' is different from '${target}'`)

      const value = await this.ask_(source, target)
      if (!value) {
        break
      }

      await this.overwrite_(value, source, target)

    }

  }

  async load_() {

    $.info().pause()
    const listSource = await $.source_('./data/sync/**/*.yaml')
    const listData = [] as string[][]
    for (const source of listSource) {
      const cont = await $.read_(source) as string[]
      listData.push(cont)
    }
    $.info().resume()

    let result = [] as string[]

    for (const data of listData) {
      result = [
        ...result,
        ...data
      ]
    }

    return _.uniq(result)

  }

  async overwrite_(value: string, source: string, target: string) {

    if (value === 'export') {
      const { dirname, filename } = $.getName(target)
      await $.copy_(source, dirname, filename)
      return
    }

    if (value === 'import') {
      const { dirname, filename } = $.getName(source)
      await $.copy_(target, dirname, filename)
      return
    }

  }

}

// export
module.exports = async () => {
  const m = new M()
  await m.execute_()
}