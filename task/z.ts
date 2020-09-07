import $ from 'fire-keeper'

// function

async function main_(): Promise<void> {

  class M {
    static value: number = 0
  }

  $.i(M.value)
}

// export
export default main_