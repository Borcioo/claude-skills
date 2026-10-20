---
name: codemap
description: Map a project's files of given types in one call, grouped by directory, optionally with the classes/functions/exports of each file. Use before reading files when you need every file of a type (e.g. all .php controllers, all .css/.scss sources) or an overview of what a directory defines. For one known filename or a single glob, use Glob instead.
allowed-tools: Bash(${CLAUDE_SKILL_DIR}/scripts/codemap *)
---

# codemap

Run the bundled script. It reads the working tree fresh on every call and prints a compact, sorted map; it never writes anything.

```bash
${CLAUDE_SKILL_DIR}/scripts/codemap --ext php,blade.php --dir app
${CLAUDE_SKILL_DIR}/scripts/codemap --ext css,scss --symbols
${CLAUDE_SKILL_DIR}/scripts/codemap --ext ts,tsx --dir src --symbols --max 150
```

Options: `--ext` (comma-separated, no dots needed), `--dir`, `--symbols`, `--max` (output line cap, default 300), `--exclude REGEX` (repeatable).

Output looks like:

```
# codemap: 12 files in 3 dirs (dir: app, ext: php, via rg)
Http/Controllers/
  UserController.php: class UserController, fn index, fn store
```

## When to use it

- You need all files of one or more types and do not know where they live.
- You are about to read several files only to learn what they define: run with `--symbols` first and read only the files that matter.
- A subagent starts on an unfamiliar area: pass it the codemap of that directory instead of letting it search from scratch.

## When not to use it

- You know the file name or a precise pattern: use Glob.
- You need text inside files: use Grep.
- You need definitions or references of a symbol and an LSP plugin is enabled: use the LSP tool.

## Gotchas

- `.gitignore` is honoured when ripgrep or git is available; `vendor/`, `node_modules/`, build output, minified files and source maps are always skipped.
- Symbols come from line-based patterns, not a parser: top-level PHP classes/functions, JS/TS `export`s, Python top-level `class`/`def`, Go `type`/`func`, CSS custom properties (as a count) and SCSS/Less mixins. Treat them as a table of contents, then read the file.
- When the output ends with `# ... truncated`, narrow with `--dir`, `--ext` or `--exclude` instead of raising `--max` far.
