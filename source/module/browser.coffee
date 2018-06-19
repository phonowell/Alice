# require

$ = require 'fire-keeper'
{_} = $

puppeteer = require 'puppeteer'

# class

class Browser

  ###
  close_()
  content_(url)
  launch_()
  ###

  close_: -> await @browser.close()

  content_: (url) ->

    new Promise (resolve) =>

      page = await @browser.newPage()

      page.once 'load', ->

        html = await page.content()
        cookie = await page.cookies()

        await page.close()

        # return
        resolve {cookie, html}

      await page.goto url

  launch_: -> @browser = await puppeteer.launch()

# return
module.exports = (arg...) -> new Browser arg...