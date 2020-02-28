import _ = require('lodash')
import $ = require('fire-keeper')
import cheerio = require('cheerio')

import browser from '../source/module/browser'

// interface

interface iItem {
  selector: string
  title: string
  url: string
}

interface iStat {
  ctime: Date
}

// function

class M {

  setting = {
    life: 3e5, // 5 min
    size: 200, // cache size
    temp: './temp/seek'
  }

  // ---

  async download_(
    { name, source, url }: { name: string, source: string, url: string }
  ) {
    await browser.launch_()
    const data = await browser.content_(url)
    await browser.close_()

    if (!data) {
      return
    }

    const { html } = data
    await $.write_(source, html)
    return html
  }

  async execute_() {
    let mapResult = {}

    const data = await $.read_('./data/seek.yaml') as iItem[]
    for (const name in data) {
      const { selector, title, url } = data[name]

      const source = `${this.setting.temp}/${name}.html`
      const stat: iStat = await $.stat_(source)

      let html: string
      if (stat && _.now() - stat.ctime.getTime() < this.setting.life) {
        html = await $.read_(source)
      } else {
        html = await this.download_({ name, source, url })
      }

      if (!html) {
        continue
      }

      const listLink = await this.getLink(html, selector)
      if (!listLink.length) {
        $.info('warning', `'${title}' might be not useable`)
        continue
      }

      mapResult[title] = await this.unique_(name, listLink)
    }

    const html = this.makeHtml(mapResult)
    await this.view_(html)

    return this
  }

  getLink(html: string, selector: string) {

    let listResult: {
      time: number
      title: string
      url: string
    }[] = []

    const dom = cheerio.load(html)
    dom(selector)
      .each(function () {
        const $a = dom(this)

        const time = _.now()
        const title = $a.text().trim()
        const url = $a.attr('href')

        listResult.push({ time, title, url })
      })

    return _.uniqBy(listResult, 'url')
  }

  makeHtml(map) {
    let html: string[] = []

    for (const title in map) {
      const list = map[title]
      if (!list.length) {
        continue
      }
      html.push(`<h1>${title}</h1>`)
      for (const item of list) {
        html.push(`<a href='${item.url}' target='_blank'>${item.title}</a>`)
      }

    }

    return html.join('<br>')
  }

  async unique_(name: string, list) {

    const source = `${this.setting.temp}/${name}.json`

    const listSource = await $.read_(source) || []
    const listResult = _.differenceBy(list, listSource, 'url')

    // save
    let listTarget = [
      ...listSource,
      ...list
    ]
    listTarget = _.uniqBy(listTarget, 'url')
    listTarget = _.sortBy(listTarget, 'time')
    listTarget = _.reverse(listTarget)
    listTarget = listTarget.splice(0, this.setting.size)
    await $.write_(source, listTarget)

    return listResult
  }

  async view_(html: string) {

    if (!html) {
      return $.info('seeker', 'got no result(s)')
    }

    const target = `${this.setting.temp}/result.html`

    let method: string
    switch ($.os()) {
      case 'linux':
      case 'macos':
        method = 'open'
        break
      case 'windows':
        method = 'start'
        break
      default:
        throw new Error(`invalid os '${$.os()}'`)
    }

    $.info().pause()
    await $.write_(target, html)
    await $.exec_(`${method} ${target}`)
    $.info().resume()

    return this

  }

}

// export
module.exports = async () => {
  const m = new M()
  await m.execute_()
}