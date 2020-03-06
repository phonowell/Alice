import puppeteer = require('puppeteer')

// function

class M {

  browser: any = null

  // ---

  async close_() {
    await this.browser.close()
    return this
  }

  async content_(url: string) {

    const page = await this.browser.newPage()

    const result = await page.got(url, {
      waitUntil: 'load'
    })
    if (!result) {
      return
    }

    const html = await page.content() as string
    const cookie = await page.cookies() as string

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