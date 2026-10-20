---
max_turns: 30
timeout_seconds: 400
allowed_tools: [Read, Glob, Grep, Skill, Bash, Write]
---

Every tool in packages/tools/src has its own folder (ignore _shared) with a ui.tsx that exports the tool's React component. Write one line per tool to answer.txt in the form `<tool-folder>: <ComponentName>`, sorted by folder name. Do not change any other file.
