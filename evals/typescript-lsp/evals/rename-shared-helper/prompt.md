---
max_turns: 40
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Edit, Write, Bash, LSP]
---

Rename the shared helper function `requestDevice` defined in packages/tools/src/_shared/request-device.ts to `acquireDevice`, and update every place that uses this helper. Keep the file name. Do not rename anything that is not this helper. Then run `pnpm --filter @utility-sites/tools typecheck` and write exactly PASS or FAIL (its result) as the only content of typecheck.txt.
