import _ = require('lodash')
import $ = require('fire-keeper')

// interface

interface iChoice {
  title: string
  value: string
}

// function

class M {

  async ask_(source: string, target: string) {

    const isExisted = [
      await $.isExisted_(source) as boolean,
      await $.isExisted_(target) as boolean
    ]

    let mtime: number[]
    if (isExisted[0] && isExisted[1]) {
      mtime = [
        await $.stat_(source).mtimeMs as number,
        await $.stat_(target).mtimeMs as number
      ]
    } else {
      mtime = [0, 0]
    }

    let choice: iChoice[] = []

    if (isExisted[0]) {
      choice.push({
        title: [
          'overwrite, export',
          mtime[0] > mtime[1] ? '(newer)' : ''
        ].join(' '),
        value: 'export'
      })
    }

    if (isExisted[1]) {
      choice.push({
        title: [
          'overwrite, import',
          mtime[1] > mtime[0] ? '(newer)' : ''
        ].join(' '),
        value: 'import'
      })
    }

    choice.push({
      title: 'skip',
      value: 'skip'
    })

    return await $.prompt_({
      list: choice,
      message: 'and you decide to...',
      type: 'select'
    }) as string

  }

  async execute_() {

    const data = await this.load_()

    // diff
    for (const line of data) {

      let [path, extra] = line.split('@') as [string, string]
      extra = extra || ''
      let [namespace, version] = extra.split('/') as [string, string]
      namespace = namespace || 'default'
      version = version || '0.0.1'

      const source = `./${path}`
      let target = `../midway/${path}`
      const { basename, dirname, extname } = $.getName(target) as {
        basename: string, dirname: string, extname: string
      }
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
    const listSource = await $.source_('./data/sync/**/*.yaml') as string[]
    let listData: string[][] = []
    for (const source of listSource) {
      const cont = await $.read_(source) as string[]
      listData.push(cont)
    }
    $.info().resume()

    let result: string[] = []

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
      const { dirname, filename } = $.getName(target) as {
        dirname: string, filename: string
      }
      await $.copy_(source, dirname, filename)
    } else if (value === 'import') {
      const { dirname, filename } = $.getName(target) as {
        dirname: string, filename: string
      }
      await $.copy_(target, dirname, filename)
    }
  }

}

// export
module.exports = async () => {
  const m = new M()
  await m.execute_()
}