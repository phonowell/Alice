puppeteer = require 'puppeteer'

# function

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

    page = await @browser.newPage()

    result = page.goto url,
      waitUntil: 'load'
    unless result
      return

    html = await page.content()
    cookie = await page.cookies()

    await page.close()

    # return
    {cookie, html}

  launch_: ->
    @browser = await puppeteer.launch()
    @ # return

# return
module.exports = new M()