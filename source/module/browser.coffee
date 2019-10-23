$ = require 'fire-keeper'
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

    handler = page.goto url,
      waitUntil: 'load'
    .then -> true
    .catch -> false

    unless await handler
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