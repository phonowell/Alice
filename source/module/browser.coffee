$ = require 'fire-keeper'
puppeteer = require 'puppeteer'

class M

  ###
  browser
  ---
  close_()
  content_(url)
  launch_()
  ###

  browser: null

  # ---

  close_: ->
    await @browser.close()
    @ # return

  content_: (url) ->

    await new Promise (resolve) =>

      page = await @browser.newPage()
      
      await page.goto url,
        waitUntil: 'load'

      html = await page.content()
      cookie = await page.cookies()

      await page.close()

      resolve {cookie, html}

  launch_: ->
    @browser = await puppeteer.launch()
    @ # return

# return
module.exports = new M()