$ = require 'fire-keeper'
{_} = $

class M

  ###
  mapType

  download_(id, zone)
  execute_()
  getType_()
  seek_(type)
  ###

  mapType:
    '传记': 2
    '儿童': 8
    '冒险': 15
    '剧情': 11
    '动作': 5
    '动画': 25
    '历史': 4
    '古装': 30
    '同性': 26
    '喜剧': 24
    '奇幻': 16
    '家庭': 28
    '恐怖': 20
    '悬疑': 10
    '情色': 6
    '惊悚': 19
    '战争': 22
    '歌舞': 7
    '武侠': 29
    '灾难': 12
    '爱情': 13
    '犯罪': 3
    '短片': 23
    '科幻': 17
    '纪录片': 1
    '西部': 27
    '运动': 18
    '音乐': 14
    '黑色电影': 31

  download_: (id, zone) ->

    $.info.pause 'douban'

    filename = "#{id}-#{(zone.split ':')[0]}.json"
    pathFile = "./temp/douban/#{filename}"

    isExisted = await $.isExisted_ pathFile
    if isExisted
      return await $.read_ pathFile

    url = [
      'https://movie.douban.com/j/chart/top_list'
      "?type=#{id}"
      "&interval_id=#{zone}"
      '&action='
      '&start=0'
      '&limit=125'
    ].join ''
    data = await $.get_ url
    await $.write_ pathFile, data

    $.info.resume 'douban'

    data # return

  execute_: ->

    type = await @getType_()
    await @seek_ type
    
    @ # return

  getType_: ->
    {type} = $.argv
    type or= await $.prompt_
      id: 'douban'
      type: 'select'
      list: _.keys @mapType
      message: 'Select type'
    unless @mapType[type]
      throw new Error "invalid type '#{type}'"
    type # return

  seek_: (type) ->

    $.info.pause 'douban'

    id = @mapType[type]

    list = []
    for item in [
      (await @download_ id, '100:90')...
      (await @download_ id, '90:80')...
    ]
      
      # score
      score = parseFloat _.get item, 'score'
      unless score >= 8.4
        continue

      # vote count
      count = parseInt _.get item, 'vote_count'
      unless count >= 30000
        continue

      # year
      year = parseInt ((_.get item, 'release_date').split '-')[0]
      unless new Date().getFullYear() - year <= 15
        continue

      list.push item

    unless list.length
      return $.i 'No result.'

    listTitle = await $.read_ './data/douban.json'
    listTitle or= []

    listUnique = []
    for item in list
      title = _.get item, 'title'
      unless title in listTitle
        listUnique.push item

    unless listUnique.length
      return $.i 'No result.'

    item = listUnique[_.random listUnique.length - 1]

    title = _.get item, 'title'
    listTitle.push title
    listTitle.sort()
    await $.write_ './data/douban.json', _.uniq listTitle

    title = [
      title
      _.get item, 'score'
    ].join ' / '
    tag = [
      ((_.get item, 'release_date').split '-')[0]
      (_.get item, 'regions')...
      (_.get item, 'types')...
    ].join ' / '

    msg = [
      title
      tag
    ].join '\n'

    $.i msg

    # continue?
    value = await $.prompt_
      type: 'confirm'
      message: 'Continue?'
      default: true

    if value
      return await @seek_ type

    $.info.resume 'douban'

    @ # return

# reture
module.exports = ->
  m = new M()
  await m.execute_()