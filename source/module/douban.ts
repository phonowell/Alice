import _ = require('lodash')
import $ from '../../lib/fire-keeper'
import axios from 'axios'

// interface

interface IMovie {
  actor_count: number
  actors: string[]
  cover_url: string
  id: string
  is_playable: boolean
  is_watched: boolean
  rank: number
  rating: string[]
  region: string[]
  release_date: string
  score: string
  title: string
  types: string[]
  url: string
  vote_count: number
}

// function

class M {

  mapType = {
    '传记': 2,
    '儿童': 8,
    '冒险': 15,
    '剧情': 11,
    '动作': 5,
    '动画': 25,
    '历史': 4,
    '古装': 30,
    '同性': 26,
    '喜剧': 24,
    '奇幻': 16,
    '家庭': 28,
    '恐怖': 20,
    '悬疑': 10,
    '情色': 6,
    '惊悚': 19,
    '战争': 22,
    '歌舞': 7,
    '武侠': 29,
    '灾难': 12,
    '爱情': 13,
    '犯罪': 3,
    '短片': 23,
    '科幻': 17,
    '纪录片': 1,
    '西部': 27,
    '运动': 18,
    '音乐': 14,
    '黑色电影': 31
  }

  // ---

  async download_(id: number, zone: string) {

    const filename = `${id}-${zone.split(':')[0]}.json`
    const pathFile = `./temp/douban/${filename}`

    const isExisted = await $.isExisted_(pathFile)
    if (isExisted) {
      return await $.read_(pathFile) as IMovie[]
    }

    const url = [
      'https://movie.douban.com/j/chart/top_list',
      `?type=${id}`,
      `&interval_id=${zone}`,
      '&action=',
      '&start=0',
      '&limit=125'
    ].join('')
    const { data }: { data: IMovie[] } = await axios.get(url)
    await $.write_(pathFile, data)

    return data

  }

  async execute_() {

    $.info().pause()
    const type = await this.getType_()
    await this.seek_(type)
    $.info().resume()

    return this
  }

  async getType_() {

    let { type } = $.argv() as { type: string }

    type = type || await $.prompt_({
      id: 'douban',
      type: 'select',
      list: _.keys(this.mapType),
      message: '选择类型'
    })

    if (!this.mapType[type]) {
      throw new Error(`invalid type '${type}'`)
    }

    return type
  }

  async seek_(type: string) {

    const id = this.mapType[type]

    const list: IMovie[] = []
    for (const _item of [
      ...(await this.download_(id, '100:90')),
      ...(await this.download_(id, '90:80'))
    ]) {

      // score
      const score = parseFloat(_.get(_item, 'score'))
      if (!(score >= 8.4)) {
        continue
      }

      // vote count
      const count = Math.floor(_.get(_item, 'vote_count'))
      if (!(count >= 3e4)) {
        continue
      }

      // year
      const year = parseInt(_.get(_item, 'release_date').split('-')[0], 10)
      if (!(new Date().getFullYear() - year <= 15)) {
        continue
      }

      list.push(_item)
    }

    if (!list.length) {
      return $.i('什么也没找到')
    }

    let listTitle: string[] = await $.read_('./data/douban.json')
    listTitle = listTitle || []

    const listUnique: IMovie[] = []
    for (const _item of list) {
      const _title = _.get(_item, 'title')
      if (!listTitle.includes(_title)) {
        listUnique.push(_item)
      }
    }

    if (!listUnique.length) {
      return $.i('什么也没找到')
    }

    const item = listUnique[_.random(listUnique.length - 1)]

    let title: string = _.get(item, 'title')
    listTitle.push(title)
    listTitle.sort()
    await $.write_('./data/douban.json', _.uniq(listTitle))

    title = [
      title,
      _.get(item, 'score')
    ].join(' / ')
    const tag = [
      (_.get(item, 'release_date').split('-')[0]),
      ...(_.get(item, 'regions')),
      ...(_.get(item, 'types'))
    ].join(' / ')

    const msg = [
      title,
      tag
    ].join('\n')
    $.i(msg)

    // continue?
    const value: boolean = await $.prompt_({
      type: 'confirm',
      message: '是否继续？',
      default: true
    })

    if (value) {
      return await this.seek_(type)
    }

    return this

  }

}

// export
module.exports = async () => {
  const m = new M()
  await m.execute_()
}