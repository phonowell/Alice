import $ = require('fire-keeper')

interface FireKeeper {

  argv(): { [key: string]: string }

  copy_(source: string[] | string, target: string, option?: string): Promise<FireKeeper>

  compile_(source: string[] | string): Promise<FireKeeper>

  exec_(lines: string[] | string, option?: {
    ignoreError?: boolean
  }): Promise<string>

  getBasename(source: string): string

  getDirname(source: string): string

  getName(path: string): {
    basename: string
    dirname: string
    extname: string
    filename: string
  }

  i<T>(message: T): T

  info(): {
    pause(): FireKeeper
    resume(): FireKeeper
    silence_(fn: (...args: any[]) => any): Promise<FireKeeper>
  }
  info(message: any): string
  info(title: string, message: any): string

  isExisted_(source: string[] | string): Promise<boolean>

  isSame_(source: string[]): Promise<boolean>

  move_(source: string[] | string, target: string): Promise<FireKeeper>

  os(): 'linux' | 'macos' | 'windows'
  os(input: 'linux' | 'macos' | 'windows'): boolean

  parseString(input: any): string

  prompt_(option: {
    default?: boolean
    id?: string
    message?: string
    type: 'confirm'
  }): Promise<boolean>
  prompt_(option: {
    default?: string
    id?: string
    message?: string
    type: 'text'
  } | {
    default?: string
    id?: string
    list: { title: string, value: string }[] | string[]
    message?: string
    type: 'auto' | 'select'
  }): Promise<string>

  read_(source: string): Promise<any>

  rename_(source: string, option: string | {
    extname?: string
    basename?: string
  }): Promise<FireKeeper>

  require(path: string): any

  remove_(source: string | string[]): Promise<FireKeeper>

  stat_(source: string): Promise<{
    ctime: Date
    mtimeMs: number
  }>

  say_(text: string, option?: {
    lang?: string
  }): Promise<FireKeeper>

  source_(source: string[] | string): Promise<string[]>

  task(name: string): any
  task(name: string, fn: (...args: any[]) => any): FireKeeper

  type(input: any): string

  watch(source: string[] | string, fn: (...args: any[]) => any): FireKeeper

  write_(target: string, content: any): Promise<FireKeeper>

  zip_(source: string, target: string, option: string): Promise<FireKeeper>

}

export default $ as FireKeeper