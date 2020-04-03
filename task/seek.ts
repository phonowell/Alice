import $ from '../lib/fire-keeper'
import * as _ from 'lodash'
import * as cheerio from 'cheerio'

import browser from '../source/module/browser'

// interface

interface IItem {
  selector: string
  title: string
  url: string
}

interface ILink {
  time: number
  title: string
  url: string
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
    const mapResult = {}

    const data = await $.read_('./data/seek.yaml') as IItem[]
    for (const name in data) {
      if (!data.hasOwnProperty(name)) {
        continue
      }

      const { selector, title, url } = data[name]

      const source = `${this.setting.temp}/${name}.html`
      const stat = await $.stat_(source)

      let _html: string
      if (stat && _.now() - stat.ctime.getTime() < this.setting.life) {
        _html = await $.read_(source)
      } else {
        _html = await this.download_({ name, source, url })
      }

      if (!_html) {
        continue
      }

      const listLink = this.getLink(_html, selector)
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

    const listResult: ILink[] = []

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

  makeHtml(map: { [key: string]: ILink[] }) {
    const html: string[] = []

    for (const title in map) {
      if (!map.hasOwnProperty(title)) {
        continue
      }

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

  async unique_(name: string, list: ILink[]) {

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
export default async () => await (new M()).execute_()