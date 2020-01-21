import puppeteer = require('puppeteer')

// function

class M {

  browser: any = null

  // ---

  close_ = async () => {
    await this.browser.close()
    return this
  }

  content_ = async (url) => {

    let page = await this.browser.newPage()

    let result = await page.got(url, {
      waitUntil: 'load'
    })
    if (!result) {
      return
    }

    let html = await page.content()
    let cookie = await page.cookies()

    await page.close()

    return { cookie, html }

  }

  launch_ = async () => {
    this.browser = await puppeteer.launch()
    return this
  }

}

// export
module.exports = new M()