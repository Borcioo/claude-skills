---
type: regex
pattern: '(?=[\s\S]*tone-generator: ToneGenerator)(?=[\s\S]*headphone-test: HeadphoneTest)(?=[\s\S]*ghosting-test: GhostingTest)(?=[\s\S]*screen-resolution: ScreenResolution)'
target: { source: file, path: answer.txt }
---
