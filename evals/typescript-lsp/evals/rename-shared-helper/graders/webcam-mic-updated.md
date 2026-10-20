---
type: regex
pattern: 'requestDevice'
match: not_contains
target: { source: file, path: packages/tools/src/webcam-mic-test/devices.ts }
---
