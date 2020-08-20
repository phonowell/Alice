import * as $ from 'fire-keeper'

type ISource = string[] | string

interface FireKeeper {

  argv(): { [key: string]: string }

  copy_(source: ISource, target: string, option?: string | Object): Promise<FireKeeper>

  compile_(source: ISource, target?: string, option?: Object): Promise<FireKeeper>

  exec_(lines: string[] | string, option?: {
    ignoreError?: boolean
  }): Promise<string>

  getBasename(source: string): string

  getDirname(source: string): string

  getExtname(source: string): string

  getFilename(source: string): string

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
    silence_(fn: Function): Promise<FireKeeper>
  }
  info(message: unknown): string
  info(title: string, message: unknown): string

  isExisted_(source: ISource): Promise<boolean>

  isSame_(source: string[]): Promise<boolean>

  move_(source: ISource, target: string): Promise<FireKeeper>

  normalizePath(source: string): string

  os(): 'linux' | 'macos' | 'windows'
  os(input: 'linux' | 'macos' | 'windows'): boolean

  parseString(input: unknown): string

  prompt_(option: {
    default?: boolean
    id?: string
    message?: string
    type: 'confirm'
  }): Promise<boolean>
  prompt_(option: {
    default?: number
    max?: number
    message?: string
    min?: number
    type: 'number'
  }): Promise<number>
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

  read_(source: string): Promise<unknown>

  rename_(source: string, option: string | {
    extname?: string
    basename?: string
  }): Promise<FireKeeper>

  require(path: string): unknown

  remove_(source: ISource): Promise<FireKeeper>

  say_(text: string, option?: {
    lang?: string
  }): Promise<FireKeeper>

  sleep_(ms: number): Promise<FireKeeper>

  source_(source: ISource): Promise<string[]>

  stat_(source: string): Promise<{
    ctime: Date
    mtimeMs: number
  }>

  task(name: string): Function
  task(name: string, fn: Function): FireKeeper

  type(input: unknown): string

  watch(source: string[] | string, fn: Function): FireKeeper

  write_(target: string, content: unknown): Promise<FireKeeper>

  zip_(source: string, target: string, option: string): Promise<FireKeeper>
}

// export
export default $ as FireKeeper