---
type: regex
pattern: '^[a-z0-9-]+: [A-Z][A-Za-z0-9]+\s*$'
flags: m
match: "count:16"
target: { source: file, path: answer.txt }
---
