---
type: regex
pattern: '(?=[\s\S]*requestDevice\(options: \{ filters)(?=[\s\S]*hid\.requestDevice\(\{ filters: DIRECT_FILTERS)'
target: { source: file, path: packages/tools/src/gamepad-test/hid/device.ts }
---
