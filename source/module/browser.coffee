$ = require 'fire-keeper'

puppeteer = require 'puppeteer'

# class

class M

  ###
  close_()
  content_(url)
  launch_()
  ###

  close_: ->
    await @browser.close()
    @ # return

  content_: (url) ->

    content = await new Promise (resolve) =>

      page = await @browser.newPage()

      page.once 'load', ->

        html = await page.content()
        cookie = await page.cookies()

        await page.close()

        # return
        resolve {cookie, html}

      await page.goto url

    content # return

  launch_: ->
    @browser = await puppeteer.launch()
    @ # return

# return
module.exports = ->
  m = new M()