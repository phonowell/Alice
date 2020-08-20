import $ from '../lib/fire-keeper'

// export
export default async () => {
  const listSource = await $.source_([
    '../midway/*-0.0.1.*',
    '../midway/data/**/*-0.0.1.*',
    '../midway/doc/**/*-0.0.1.*',
    '../midway/lib/**/*-0.0.1.*',
    '../midway/source/**/*-0.0.1.*',
    '../midway/task/**/*-0.0.1.*',
    '../midway/toolkit/**/*-0.0.1.*'
  ])
  await $.remove_(listSource)
}