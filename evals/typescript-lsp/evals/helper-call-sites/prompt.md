---
max_turns: 30
timeout_seconds: 400
allowed_tools: [Read, Glob, Grep, Write, Bash, LSP]
---

Which files call the shared helper `requestDevice` exported from packages/tools/src/_shared/request-device.ts? Write their paths, relative to the repository root, one per line to answer.txt. Leave out the helper's own file, and leave out anything that calls a different function with the same name. Do not change any other file.
