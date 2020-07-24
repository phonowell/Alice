import $ from '../lib/fire-keeper'

// function

class M {

  list: string[]

  constructor() {
    this.list = []
  }

  async ask_() {
    const task = await $.prompt_({
      id: 'default-task',
      list: this.list,
      message: 'input a task name',
      type: 'auto'
    })
    if (!task) return
    await this.run_(task)
  }

  async execute_() {

    const task = $.argv()._[0]

    await this.load_()

    if (!task) {
      await this.ask_()
      return
    }

    if (this.list.includes(task)) {
      await this.run_(task)
      return
    }

    $.i(`found no task named as '${task}'`)
  }

  async load_() {
    const listSource = await $.source_('./task/*.ts')
    const listTask = [] as string[]
    for (const source of listSource) {
      const basename = $.getBasename(source)
      if (basename === 'alice') continue
      listTask.push(basename)
    }
    this.list = listTask
  }

  async run_(task: string) {
    const [source] = await $.source_(`./task/${task}.ts`)
    const fn_ = (await import(source)).default
    await fn_()
  }
}

// execute
new M().execute_()