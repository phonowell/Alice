import puppeteer = require('puppeteer')

// function

class M {

  browser: puppeteer.Browser

  // ---

  async close_() {
    await this.browser.close()
    return this
  }

  async content_(url: string) {

    const page = await this.browser.newPage()

    const result = await page.goto(url, {
      waitUntil: 'load'
    })
    if (!result) {
      return
    }

    const html = await page.content()
    const cookie = await page.cookies()

    await page.close()

    return { cookie, html }

  }

  async launch_() {
    this.browser = await puppeteer.launch()
    return this
  }

}

// export
export default new M()