---
type: regex
pattern: '(gamepad-test|e2e/)'
match: not_contains
target: { source: file, path: answer.txt }
---
