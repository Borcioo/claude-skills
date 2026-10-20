# Claude Code / Agent Skills & plugin ecosystem (Oct 2026) — what a team already on obra/superpowers should add, replace, or ignore

Data collected 2026-10-19 by shallow-cloning each repo (`git clone --depth 1`, read only, nothing executed), `git ls-remote` for SHAs/tags, img.shields.io for stars/releases/licenses, and web sources. The `gh` CLI and api.github.com were blocked, so neither was used. "Stale" means no commit in the 3+ months before 2026-10-19 (last commit before 2026-07-19). Star counts come from shields.io unless marked otherwise. Two of them (obra/superpowers and mattpocock/skills) were cross-checked against the GitHub page or the author's post.

## 1. What obra/superpowers contains today (v7.0.0), its sibling repos, and what it does NOT cover

### Takeaway
Superpowers v7.0.0 (tagged 2026-10-09, commit bb92a777…, which is also current HEAD) has 15 process skills and one SessionStart hook. It covers brainstorming → planning → subagent/native execution → TDD → debugging → code review → branch finishing, and nothing else. It ships no language or framework knowledge, no frontend/UI design, no security, performance or observability guidance, no CI/CD, docs/ADR or issue-tracker workflow, and no code intelligence. Those gaps are where additions pay off. The sibling repos are optional and some are stale.

### Cited Findings
**Version, tags and manifests**
- The latest tag is **v7.0.0**. Annotated tag object `7f043e5eaf3522dc19178c673b76328de9b0c355` peels to commit **`bb92a77741419a4ab5f06e711a283343f1ada0c3`**, which is also `HEAD` of `main` (commit date 2026-10-09T17:28:04-07:00). Earlier tags: v6.4.2 → `8ca22dba9a94f28898bbce59f2537ff4d87c747d` and v6.4.1 → `5bf4e78011075bcfc0dc295f0724994cd123ee71` — [obra/superpowers](https://github.com/obra/superpowers) (git ls-remote --tags)
- The repo has `.claude-plugin/plugin.json` (name `superpowers`, version 7.0.0, MIT, author Jesse Vincent) and `.claude-plugin/marketplace.json` (marketplace name `superpowers-dev`, one plugin `superpowers`, source `./`) — [plugin.json](https://github.com/obra/superpowers/blob/main/.claude-plugin/plugin.json)
- It also ships manifests for other agents: `.codex-plugin`, `.agents` (a Codex marketplace), `.cursor-plugin` plus `hooks/hooks-cursor.json`, `.antigravity-plugin`, `.devin-plugin`, `.hermes-plugin`, `.kimi-plugin`, `.muse-plugin`, `.opencode`, `.pi` and `gemini-extension.json`. The README gives install steps for Claude Code, Antigravity (`agy plugin install https://github.com/obra/superpowers`), Factory Droid, Gemini CLI, Copilot CLI (`copilot plugin install superpowers@superpowers-marketplace`), Grok Build CLI and others — [obra/superpowers README](https://github.com/obra/superpowers)
- **Install on Claude Code:** `/plugin install superpowers@claude-plugins-official`, or `/plugin marketplace add obra/superpowers-marketplace` followed by `/plugin install superpowers@superpowers-marketplace` — [README](https://github.com/obra/superpowers)
- Anthropic's official marketplace pins superpowers to `{"source":"url","url":"https://github.com/obra/superpowers.git","sha":"bb92a77741419a4ab5f06e711a283343f1ada0c3"}`, which is exactly v7.0.0 — [claude-plugins-official marketplace.json](https://github.com/anthropics/claude-plugins-official/blob/main/.claude-plugin/marketplace.json)

**Skills (15) and hook**
- The 15 skills: brainstorming, diagnosing-superpowers, dispatching-parallel-agents, executing-plans, finishing-a-development-branch, receiving-code-review, requesting-code-review, subagent-driven-development, systematic-debugging, test-driven-development, using-git-worktrees, using-superpowers, verification-before-completion, writing-plans, writing-skills. There is no `commands/` or `agents/` directory at HEAD — [skills/](https://github.com/obra/superpowers/tree/main/skills)
- `hooks/hooks.json` registers a SessionStart hook with matcher `startup|clear|compact`, `shell: "bash"`. It injects the `using-superpowers` bootstrap (487 words) — [hooks](https://github.com/obra/superpowers/tree/main/hooks)
- The descriptions are deliberately forceful. brainstorming: "You MUST use this before any creative work - creating features, building components, adding functionality, modifying behavior, or planning anything new…". test-driven-development: "Use when implementing any feature or bugfix, before writing implementation code". systematic-debugging: "Use when encountering any bug, test failure, or unexpected behavior, before proposing fixes" — [skills/](https://github.com/obra/superpowers/tree/main/skills)
- **Size of each SKILL.md, measured from the clone in words (not tokens):** subagent-driven-development 4,779 (7,730 including references); writing-skills 3,765 (13,107 including references); executing-plans 3,194; brainstorming 1,724; writing-plans 1,630; test-driven-development 1,464; systematic-debugging 1,444; finishing-a-development-branch 1,243; using-git-worktrees 1,064; diagnosing-superpowers 1,058; receiving-code-review 894; dispatching-parallel-agents 860; verification-before-completion 556; using-superpowers 487; requesting-code-review 423 — [obra/superpowers](https://github.com/obra/superpowers)
- An independent measurement of v6.3.0: 14 skills, 20,748 instruction words, 25 reference files, one SessionStart hook injecting about 777 tokens (~0.4% of a 200k window) on startup, clear and compact. The heaviest skills when loaded were SDD (~8,084 tokens), writing-skills (~6,590) and brainstorming (~3,864) — [WotAI, Alex Kim, 2026-08-28](https://wotai.co/blog/compound-engineering-vs-superpowers)

**Recent changes (RELEASE-NOTES.md)**
- **v7.0.0 (2026-10-09):**
  - Brainstorming was rebuilt. It draws out intent and plays back understanding, then sizes the work: a quick task is done right away, a small change is agreed in chat, a project gets a design doc.
  - A "builder check" subagent replaces the spec-document reviewer.
  - It asks which platform, language and library choices the user wants to own, after "a session designed an iOS app, never asked about platform, and built a web app".
  - Adds a native Antigravity plugin manifest and fixes Windows hooks (`run-hook.cmd` no longer runs a planted `bash.cmd`/`where.bat` from the repo).
  - Source: [RELEASE-NOTES.md](https://github.com/obra/superpowers/blob/main/RELEASE-NOTES.md)
- **v6.4.2 (2026-09-25):** `writing-plans` now records decisions (signatures, test assertions, spec values) instead of code. Reason given: "Some frontier models, including Opus 5.5, could get overzealous during plan writing… would sometimes try to implement the entire project while designing the plan". The result: plans took "a quarter of the time and about a third of the tokens" — [RELEASE-NOTES.md](https://github.com/obra/superpowers/blob/main/RELEASE-NOTES.md)
- **v6.4.1 (2026-09-18):**
  - New `diagnosing-superpowers` skill, which audits a session transcript with `path:line` evidence.
  - `executing-plans` was rebuilt as "Native (inline) execution", described as a cheaper alternative to SDD that "no longer stops every few tasks to check in".
  - TDD now runs the whole project suite. Before the fix, sessions ran only the named file "in 11 of 12 probe runs".
  - Adds OpenCode 2.0, Muse and Qwen Code.
  - Source: [RELEASE-NOTES.md](https://github.com/obra/superpowers/blob/main/RELEASE-NOTES.md)
- **v6.3.0 (2026-08-12):** brainstorming ceremony now scales (spike/bounded/architectural). Adds Devin CLI and Hermes. Worktree removal no longer destroys untracked files — [RELEASE-NOTES.md](https://github.com/obra/superpowers/blob/main/RELEASE-NOTES.md)
- **v6.0.0 (2026-06-16):**
  - SDD review was rewritten: one reviewer per task, diffs passed as files, and every dispatch must state its model. The notes say: "in our evals, Claude Code and Codex produce similar high-quality results roughly twice as fast and while spending almost 50% fewer tokens".
  - Worktrees moved to the project's `.worktrees/`.
  - Source: [RELEASE-NOTES.md](https://github.com/obra/superpowers/blob/main/RELEASE-NOTES.md)
- **Gemini CLI support conflict:**
  - v6.1.0 (2026-06-30) removed Gemini CLI support, saying "Google EOLed the Gemini CLI on 2026-06-18". It also slimmed the `using-superpowers` bootstrap to cut per-session token cost.
  - v6.2.0 (2026-07-23) restored Gemini CLI support, calling the removal "premature".
  - Source: [RELEASE-NOTES.md](https://github.com/obra/superpowers/blob/main/RELEASE-NOTES.md)
- Release cadence: v4.0.0 was 2025-12-17, v5.0.0 2026-03-09, v6.0.0 2026-06-16 and v7.0.0 2026-10-09, with point releases roughly every 1–3 weeks — [RELEASE-NOTES.md](https://github.com/obra/superpowers/blob/main/RELEASE-NOTES.md)

**Adoption**
- shields.io shows 302k stars, latest release v7.0.0, license MIT — [shields stars](https://img.shields.io/github/stars/obra/superpowers)
- The author says it is "about to cross 300,000 stars on GitHub", "the 12th most popular project of all time by stars", and "the #1 third-party plugin for Claude Code" with ">1.1M installs" (citing primeradiant.com stats). Superpowers 1.0 shipped 2025-10-09 — [Jesse Vincent, "What a year", 2026-10-09](https://blog.fsck.com/2026/10/09/what-a-year/)

**Sibling repos**
- **obra/superpowers-marketplace:** HEAD `2cf27fa76667afa0ba724ad8141a6938a3834e32` (2026-10-10), latest tag v1.0.12, 1.3k stars. Its plugins are listed by git URL with **no sha/ref pin**:
  - superpowers 7.0.0
  - superpowers-chrome 3.0.5 (stale entry; that repo's plugin.json now says 3.3.0)
  - elements-of-style 1.0.0
  - episodic-memory 1.6.0
  - superpowers-lab 0.5.0
  - superpowers-developing-for-claude-code 0.3.1
  - superpowers-dev (the `dev` branch)
  - claude-session-driver 4.0.1
  - private-journal-mcp 2.0.1
  - double-shot-latte 1.2.0
  - Source: [marketplace.json](https://github.com/obra/superpowers-marketplace/blob/main/.claude-plugin/marketplace.json)
- **obra/superpowers-lab:** v0.5.0 (tag → `51111f74f24058117752d9aa917cb19859f8ec86` = HEAD), last commit **2026-06-01 (STALE)**, 433 stars, plugin.json only. Skills: finding-duplicate-functions (semantic duplicate detection; Haiku categorises, Opus clusters), mcp-cli, using-tmux-for-interactive-commands, windows-vm — [obra/superpowers-lab](https://github.com/obra/superpowers-lab)
- **obra/superpowers-developing-for-claude-code:** last commit **2025-12-03 (STALE, 10+ months)** — [repo](https://github.com/obra/superpowers-developing-for-claude-code)
- **obra/superpowers-chrome:** HEAD `eabb66fabd244cd6eaddc13a652191179fda3a99` (2026-10-10), v3.3.0, self-described "BETA: VERY LIGHTLY TESTED". Chrome DevTools Protocol "browsing" skill plus MCP mode — [repo](https://github.com/obra/superpowers-chrome)

### Inferences
- **Gaps in superpowers.** These are inferred from the skill list and what other collections cover:
  - Language and framework idioms (TS/Python/Go/Rust/PHP/React/Next/Laravel).
  - Frontend/UI design quality.
  - Security review and hardening (it has only general code review).
  - Performance, observability, CI/CD and release.
  - API/interface design.
  - Docs, ADRs and a domain glossary.
  - Issue-tracker triage and PR creation/babysitting. `finishing-a-development-branch` only offers merge/PR at the end.
  - LSP code intelligence.
  - Vendor SDK knowledge (Stripe, Supabase, Cloudflare and others).
  - Browser/E2E verification (only the beta superpowers-chrome).
  - Supply-chain and dependency review.
- Superpowers' strength is ambient process discipline: the SessionStart hook plus forceful descriptions. A second "process" plugin will fight it for the same triggers (brainstorm, plan, TDD, debug, review, worktrees).
- Pinning superpowers by SHA is already modelled by Anthropic's official marketplace, which pins `bb92a777…`. The obra marketplace does not pin, so installs from it float to HEAD.

### Gaps
- I did not measure the token count of the injected SessionStart payload for v7.0.0 (the 777-token figure is for v6.3.0).
- I did not verify the primeradiant.com install stats independently.
- The Gemini CLI EOL claim in v6.1.0 conflicts with v6.2.0's restoration. I did not verify Google's actual status.

## 2. The most-used and best-regarded skill/plugin collections, profiled against superpowers

### Takeaway
Three groups:
- **Complementary and worth adding:** Anthropic's official marketplace plugins (LSP plugins, frontend-design, code-review/pr-review-toolkit, security-guidance), focused vendor skills for your stack, selected Trail of Bits security/testing skills, and cherry-picked skills from mattpocock/skills and addyosmani/agent-skills.
- **Competing process frameworks that clash with superpowers:** Compound Engineering, GSD (now open-gsd/gsd-core), BMAD, Spec Kit and OpenSpec. Pick one "spine" per repo.
- **Discovery only, not installation sources:** mega-collections and awesome lists.

### Cited Findings
**Anthropic official marketplace — `anthropics/claude-plugins-official`**
- HEAD `a0b04d9ddccaabe1976645f68b0eda50f74e7022` (2026-10-19), Apache-2.0, 43k stars. Marketplace name `claude-plugins-official`, **315 plugins, 262 of them pinned with an explicit `sha`** — [marketplace.json](https://github.com/anthropics/claude-plugins-official/blob/main/.claude-plugin/marketplace.json)
- **In-repo plugins:** agent-sdk-dev, claude-code-setup, claude-md-management, claude-security, code-modernization, code-review, code-simplifier, commit-commands, feature-dev, frontend-design, hookify, mcp-server-dev, plugin-dev, pr-review-toolkit, ralph-loop, security-guidance (v2.0.14), session-report, skill-creator, and others.
- **LSP plugins:** typescript-lsp, pyright-lsp, gopls-lsp, rust-analyzer-lsp, php-lsp, jdtls-lsp, kotlin-lsp, csharp-lsp, clangd-lsp, ruby-lsp, swift-lsp, lua-lsp.
- **Wrapped integrations:** context7, github, gitlab, linear, playwright, terraform, laravel-boost, firebase, serena.
- Source: [claude-plugins-official](https://github.com/anthropics/claude-plugins-official)
- **`code-review`:** "launches 4 parallel agents", two for CLAUDE.md compliance, one for bugs and one for git blame/history. It "scores each issue 0-100", filters below 80 confidence, and posts a PR comment — [plugins/code-review README](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/code-review)
- **`pr-review-toolkit`** agents: code-reviewer, code-simplifier, comment-analyzer, pr-test-analyzer, silent-failure-hunter, type-design-analyzer. **`feature-dev`** agents: code-architect, code-explorer, code-reviewer. **`security-guidance`** 2.0.14: "Pattern-based warnings on edits, LLM-powered diff review on Stop, and an agentic commit reviewer… injection, XSS, SSRF, hardcoded secrets, and 25+ other vulnerability classes" — [marketplace.json](https://github.com/anthropics/claude-plugins-official/blob/main/.claude-plugin/marketplace.json)
- **frontend-design** SKILL.md description: "Guidance for distinctive, intentional visual design when building new UI or reshaping an existing one. Helps with aesthetic direction, typography, and making choices that don't read as templated defaults" — [plugins/frontend-design](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/frontend-design)
- It is #12 all-time on skills.sh with 1.0M installs as `anthropics/skills` frontend-design — [skills.sh](https://skills.sh)
- Anthropic has a post on it — [Improving frontend design through Skills](https://claude.com/blog/improving-frontend-design-through-skills). Its body was not retrieved.
- **External plugins pinned by SHA in the official marketplace:**

  | Plugin | Pinned source and SHA |
  |---|---|
  | superpowers | `bb92a777…` |
  | mattpocock-skills | `49dd158d1076134a641b33efb035946536778336` |
  | coderabbit | coderabbitai/skills `3e8763d24d543b48615b82535d02288de3ddae40` |
  | cloudflare | cloudflare/skills `b052c32bab7dd493513260228a36c88294f343f1` |
  | stripe | git-subdir stripe/ai `providers/claude/plugin`, `97b2164821c378f246c3903852057b36a8bd0296` |
  | sentry | getsentry/plugin-claude `73e53541d7af21672e27428c7067f4264b8a3d65` |
  | vercel | vercel/vercel-plugin `882e66c2698689324c341b7bb8fd8beb92c27bf6` |
  | supabase | supabase-community/supabase-plugin `2c6d02d4565babe784103ee4d446a93ae9b24151` |

  Also present: expo, neon, prisma, posthog, datadog, semgrep, sonarqube, mongodb, redis-development and netlify-skills — [marketplace.json](https://github.com/anthropics/claude-plugins-official/blob/main/.claude-plugin/marketplace.json)
- **Not in the official marketplace:** compound-engineering, trailofbits, wshobson/agents, addyosmani/agent-skills, GSD, BMAD, spec-kit and OpenSpec (grep of the names and URLs in marketplace.json) — [marketplace.json](https://github.com/anthropics/claude-plugins-official/blob/main/.claude-plugin/marketplace.json)
- **`anthropics/claude-code` `plugins/` directory:** marketplace `claude-code-plugins` with 13 plugins (agent-sdk-dev, claude-opus-4-5-migration, code-review, commit-commands, explanatory-output-style, feature-dev, frontend-design, hookify, learning-output-style, plugin-dev, pr-review-toolkit, ralph-wiggum, security-guidance). HEAD `a6e289a2e772a17b3614a9ef43303003de5cd887`, latest release v2.1.304, 153k stars. It still references "claude-opus-4-5-migration" and "ralph-wiggum", while the official marketplace has "ralph-loop", so this looks like an older demo copy — [anthropics/claude-code](https://github.com/anthropics/claude-code)

**`anthropics/skills`**
- HEAD `dbd4588f9e1033efb41dad4bef2f7947c8993d44` (2026-10-09), 182k stars, no releases; shields reports no license.
- Marketplace `anthropic-agent-skills`:
  - document-skills (xlsx, docx, pptx, pdf)
  - example-skills (algorithmic-art, brand-guidelines, canvas-design, doc-coauthoring, frontend-design, internal-comms, mcp-builder, skill-creator, slack-gif-creator, theme-factory, web-artifacts-builder, webapp-testing)
  - claude-api
  - academy-guide
  - discernment-nudge
- Also contains `spec/` and `template/`.
- Source: [anthropics/skills](https://github.com/anthropics/skills)

**`mattpocock/skills` (Matt Pocock)**
- HEAD `5beb35b040e3de97e54fa9e386d7e42d15c295c2` (2026-10-19). Tag v1.3.1: annotated object `0b6cee10…` peels to commit `24fe0ef7737efae15c87225755e9f6f5965e4888`. MIT. GitHub page shows "297.5k stars", 25.0k forks, 546 commits — [GitHub](https://github.com/mattpocock/skills)
- Marketplace `mattpocock` → plugin `mattpocock-skills` 1.3.1. Install: `claude plugin install mattpocock-skills@claude-plugins-official`; Codex/Copilot via `… marketplace add mattpocock/skills`; any other agent via `npx skills@latest add mattpocock/skills -a <agent>`.
- The README warns: "Pick one per agent, because installing both gives you every skill twice." Run `/setup-matt-pocock-skills` once per repo; it asks for the issue tracker, triage labels and docs location.
- Source: [README](https://github.com/mattpocock/skills)
- **Skills:**
  - engineering: ask-matt, code-review, codebase-design, diagnosing-bugs, domain-modeling, grill-with-docs, implement, implement-spec, improve-codebase-architecture, pr, prototype, research, retro, setup-matt-pocock-skills, tdd, to-spec, to-tickets, triage, wayfinder, wizard
  - productivity: grill-me, grilling, handoff, teach, to-questionnaire, wait-what, writing-for-agents
  - misc: git-guardrails-claude-code, migrate-to-shoehorn, scaffold-exercises, setup-pre-commit
  - Source: [skills/](https://github.com/mattpocock/skills/tree/main/skills)
- Positioning, from the README: "Approaches like GSD, BMAD, and Spec-Kit try to help by owning the process. But while doing so, they take away your control…" Its skills are "small, easy to adapt, and composable". `/grill-with-docs` builds a shared-language glossary and ADRs; the README calls it "the single coolest technique in this repo" — [README](https://github.com/mattpocock/skills)
- skills.sh all-time installs: grill-me 1.4M (#2), grill-with-docs 1.2M, improve-codebase-architecture 1.1M, tdd 1.1M, setup-matt-pocock-skills 1.0M, handoff 1.0M, triage 967K, prototype 964K — [skills.sh](https://skills.sh)

**`addyosmani/agent-skills` (Addy Osmani)**
- HEAD = tag `0.6.13` → `aeac41d4d005999432bb7312f7ff06383a91d59d` (2026-10-13), MIT, 109k stars.
- Marketplace `addy-agent-skills` → plugin `agent-skills` 0.6.13. Install with `/plugin marketplace add addyosmani/agent-skills` then `/plugin install agent-skills@addy-agent-skills`, or `npx skills add addyosmani/agent-skills [--skill X]`.
- Source: [README](https://github.com/addyosmani/agent-skills)
- **25 skills:** api-and-interface-design, browser-testing-with-devtools, ci-cd-and-automation, code-review-and-quality, code-simplification, constraint-driven-development, context-engineering, debugging-and-error-recovery, deprecation-and-migration, documentation-and-adrs, doubt-driven-development, frontend-ui-engineering, git-workflow-and-versioning, idea-refine, incremental-implementation, interview-me, observability-and-instrumentation, performance-optimization, planning-and-task-breakdown, security-and-hardening, shipping-and-launch, source-driven-development, spec-driven-development, test-driven-development, using-agent-skills.
- **Agents:** code-reviewer, security-auditor, test-engineer, web-performance-auditor.
- **9 commands:** /spec /plan /build /test /constraints /review /webperf /code-simplify /ship. The README notes `/review` collides with the built-in, so use `/agent-skills:review`.
- Source: [repo](https://github.com/addyosmani/agent-skills)
- **Evals:** three tiers.
  - Tier 1: structural CI checks.
  - Tier 2: trigger/routing checks using a TF-IDF approximation, with a rank-1 floor of 95% enforced in CI.
  - Tier 3: behavioural runs through headless `claude`.
  - Also uses `claude plugin eval` (Claude Code ≥ 2.1.269), which scores each case with and without the plugin. It credits superpowers' `claude -p` testing pattern.
  - Source: [evals/README.md](https://github.com/addyosmani/agent-skills/tree/main/evals)

**`EveryInc/compound-engineering-plugin` (Every; `EveryInc/every-marketplace` resolves to the same SHA)**
- HEAD `2e41b4490a37f53db0beb6d4904618da9af2f559` (2026-10-17). Release `compound-engineering-v3.31.0` is a lightweight tag at `94bda01bd5f7eb6e102c34f3797483aea5fa9b98`. MIT, 26k stars.
- Marketplace `compound-engineering-plugin` → plugin `compound-engineering` 3.31.0. Install with `/plugin marketplace add EveryInc/compound-engineering-plugin` then `/plugin install compound-engineering`. The README says to refresh the marketplace before `/plugin update`.
- It claims to run "on 14 agent hosts" (Claude Code, Cursor, Codex app/CLI, Copilot, OpenCode, Pi, Kimi, Cline, Droid, Qwen, Devin, Grok Build, Antigravity…).
- Source: [README](https://github.com/EveryInc/compound-engineering-plugin)
- **36 skills:** ce-babysit-pr, ce-bakeoff, ce-brainstorm, ce-code-review, ce-commit, ce-commit-push-pr, ce-compound, ce-compound-refresh, ce-debug, ce-doc-review, ce-dogfood, ce-explain, ce-handoff, ce-ideate, ce-noslop, ce-optimize, ce-plan, ce-polish, ce-pov, ce-product-pulse, ce-promote, ce-proof, ce-prototype, ce-resolve-pr-feedback, ce-retune, ce-riffrec-feedback-analysis, ce-setup, ce-simplify-code, ce-strategy, ce-sweep, ce-test-browser, ce-test-xcode, ce-work, ce-worktree, lfg, wtf. The loop is brainstorm → plan → work → review → compound (learnings go to `docs/solutions/`) — [skills/](https://github.com/EveryInc/compound-engineering-plugin/tree/main/skills)
- **Comparison with superpowers (WotAI, CE 3.23.4 vs superpowers 6.3.0):**
  - Six jobs overlap: brainstorming, planning, executing plans, debugging, code review, git worktrees.
  - "Superpowers' hook fires first, so its skills usually win collisions". The suggested fix is to name one plugin the "spine" in `AGENTS.md`.
  - Superpowers' failure mode is ceremony; CE's is drift ("nothing runs unless invoked").
  - The author's preferred solo setup is CE as the spine with superpowers underneath.
  - Source: [WotAI](https://wotai.co/blog/compound-engineering-vs-superpowers)

**GSD ("get-shit-done")**
- `gsd-build/get-shit-done` (`glittercowboy/get-shit-done` resolves to the same SHA `bdcaab2c752d9a33a1a1ca9acf3a3c81fb991815`) had its last commit on 2026-05-31. Its README says: "GSD Has Moved… continues as **GSD Core**… https://github.com/open-gsd/gsd-core". The old repo shows 64k stars and release v1.42.3 — [gsd-build/get-shit-done](https://github.com/gsd-build/get-shit-done)
- `open-gsd/gsd-core`:
  - HEAD `184255fbc02267ed8e5642f0a1f45968f1d98a0a` (2026-10-19). Release v1.18.0 is a lightweight tag at `35f5a452239b897b8d6352c973e1e4efd683370f`. MIT, 11k stars.
  - Has `.claude-plugin/marketplace.json` and `plugin.json`.
  - Install: `npx @opengsd/gsd-core@latest`. The installer targets Claude Code, OpenCode, Antigravity, Kimi, Kilo, Codex, Copilot, Cursor and Windsurf.
  - Loop: Discuss → Plan → Execute ("parallel waves; each executor starts with a clean 200k-token context") → Verify → Ship. Commands: `/gsd-new-project`, `/gsd-onboard`.
  - Source: [open-gsd/gsd-core](https://github.com/open-gsd/gsd-core)

**BMAD-METHOD**
- HEAD `61e01f82644c4bb533750cfa0d6d61ab61d2cc9b` (2026-10-18). Release v6.12.4 (annotated tag; commit `bab9082c3e884e0d72c759bcd1a6d90bcc01be84`). 54k stars. GitHub cannot identify the license (repo has LICENSE plus TRADEMARK.md).
- Stable v6.12 installs with `npx bmad-method install`. V7 is a preview alpha installed with `npx skills add bmad-code-org/BMAD-METHOD --skill '*'`.
- Source: [README](https://github.com/bmad-code-org/BMAD-METHOD)

**github/spec-kit**
- HEAD `f68ffcab37a253d42a226bc9bcf4fef451efa38c` (2026-10-19). Release v1.2.2 (annotated; commit `74be0a63e93c7087c5b06556b7561810d8f78a45`). MIT, 142k stars.
- Install: `uv tool install specify-cli`, then `specify init my-project --integration copilot`. Needs Python 3.11+. Supports extensions, presets, workflow overlays, bundles and air-gapped catalogs.
- Source: [README](https://github.com/github/spec-kit)

**Fission-AI/OpenSpec**
- HEAD = tag v1.14.3 = `c794978f4f8845ce59693373c9dd882ee776588c` (2026-10-17). MIT, 72k stars.
- Install: `npm install -g @fission-ai/openspec@latest` or `brew install openspec` (Node ≥ 20.19).
- Philosophy: "fluid not rigid", "iterative not waterfall".
- Source: [README](https://github.com/Fission-AI/OpenSpec)

**Practitioner comparisons (blogs; no controlled benchmarks)**
- Superpowers is strongest on discipline but adds overhead on tiny edits. GSD keeps persistent project state files. CE is a knowledge-capture layer that can sit on top of either. One tester "couldn't reliably tell which tool produced which output" — [The AI Engineer substack](https://theaiengineer.substack.com/p/superpowers-vs-gsd-vs-compound-engineering); [Daniel Vaughan, Codex frameworks comparison](https://codex.danielvaughan.com/2026/04/24/community-workflow-frameworks-codex-cli-superpowers-gsd-gstack-comparison/). These points come from search-result summaries; the full posts were not read.

**Trail of Bits — `trailofbits/skills`**
- HEAD `5c99c03fb8a9ea568432ecbcba5d86e9f4ac2bf0` (2026-10-15), no releases, **CC-BY-SA-4.0**, 7.6k stars.
- Marketplace `trailofbits` with 44 plugins. Install with `/plugin marketplace add trailofbits/skills`, then `/plugin menu`. Codex: `codex plugin marketplace add trailofbits/skills`.
- Dev-relevant plugins: differential-review, insecure-defaults, sharp-edges, static-analysis, property-based-testing, mutation-testing, modern-python, supply-chain-risk-auditor, second-opinion, gh-cli, rust-review, c-review, modern-cpp, devcontainer-setup, git-cleanup, review-walkthrough.
- Many others are audit-niche: building-secure-contracts, yara-authoring, dwarf-expert, culture-index, let-fate-decide, and more.
- Source: [trailofbits/skills](https://github.com/trailofbits/skills)

**wshobson/agents**
- HEAD `0874a27b17a22e2b7c2e2bcd725768e0803cad06` (2026-10-17), no releases, MIT, 41k stars.
- Marketplace `claude-code-workflows` with **94 plugins**, each holding agents, commands and skills. Example: `python-development` 1.2.3 has 14 skills (async-python-patterns, python-testing-patterns, python-packaging…).
- Install selectively: `/plugin marketplace add wshobson/agents` then `/plugin install python-development@claude-code-workflows`.
- Includes many non-dev plugins: seo-*, content-marketing, quantitative-trading, hr-legal-compliance…
- Source: [README](https://github.com/wshobson/agents)

**Vendor and framework skills**
- **Vercel**
  - `vercel-labs/agent-skills`: 9 skills (react-best-practices, composition-patterns, react-view-transitions, react-native-skills, web-design-guidelines, deploy-to-vercel, vercel-optimize, vercel-cli-with-tokens, writing-guidelines). HEAD `063bee94c3f4df8453406c830b0a7df0f2860278` (2026-08-28), 33k stars. No `.claude-plugin`; install with `npx skills add vercel-labs/agent-skills` — [repo](https://github.com/vercel-labs/agent-skills)
  - Official marketplace `vercel` plugin: vercel/vercel-plugin (HEAD now `0db44088cc0454455f85f46150162716d58acd8c`) — [vercel-plugin](https://github.com/vercel/vercel-plugin)
- **Supabase**
  - `supabase/agent-skills`: marketplace `supabase-agent-skills` with plugins `supabase` and `postgres-best-practices`. HEAD `c9be0e931b7930f7d02126d04774d904c381e7d7` (2026-10-02). Tag v0.1.9 is lightweight at `544bfc56c89afe2b87b20017a59b2c6e9502a1fb`. MIT, 2.9k stars — [repo](https://github.com/supabase/agent-skills)
  - The official `supabase` plugin is a different repo (supabase-community/supabase-plugin, MCP).
- **Cloudflare:** `cloudflare/skills` has 19 skills (workers-best-practices, wrangler, durable-objects, agents-sdk, web-perf, nextjs-on-cloudflare…). Marketplace `cloudflare` → plugin `cloudflare` 1.0.2. HEAD `86505e44f87d801aa1864a3c4109e9a8ae5c409f` (2026-10-15), Apache-2.0, 3.1k stars — [repo](https://github.com/cloudflare/skills)
- **Stripe:** `stripe/ai` marketplace `stripe` → plugin `stripe` 0.11.23 (stripe-best-practices, stripe-docs, upgrade-stripe, connect-*…). HEAD `a8813a705651eaa68fab38943527a786ea5b411a` (2026-10-19), MIT, 2k stars — [repo](https://github.com/stripe/ai)
- **Sentry:**
  - `getsentry/skills`: marketplace `sentry-skills` → plugin `sentry-skills`, 29 skills (code-review, find-bugs, security-review, gha-security-review, commit, create-branch, pr-writer, iterate-pr, code-simplifier, claude-settings-audit, skill-scanner, agents-md, django-perf-review…). HEAD `f57ada2d0b640406ea7e25b11d636c530e77c58b` (2026-10-15), Apache-2.0, 1.1k stars — [repo](https://github.com/getsentry/skills)
  - The official `sentry` plugin is getsentry/plugin-claude (MCP).
- **CodeRabbit:** `coderabbitai/skills` has plugin.json only, with skills code-review and autofix (needs the CodeRabbit CLI/account). v1.1.1 (commit `fbfdb368fc2fa7fd3759f5ee346aea9123cea15b`), HEAD `a8777050c0d9034d5de6beff3dfac9b43acb9854`, MIT, 193 stars — [repo](https://github.com/coderabbitai/skills)
- **React Native / Expo:**
  - `expo/skills`: 26 skills, marketplace `expo-plugins` (expo, expo-experiments, expo-app-design, upgrading-expo, expo-deployment). HEAD `7ddc1f5796996e5c7efe2fc3fa9168eb24e8dac1`, MIT, 2.9k stars — [repo](https://github.com/expo/skills)
  - `callstackincubator/agent-skills`: marketplace `callstack-agent-skills` (building-/testing-/migrating-to-react-native). HEAD `59e9d17446a248b21d86f078fcd0bd2d36db1ca4`, MIT, 1.7k stars — [repo](https://github.com/callstackincubator/agent-skills)
- **Laravel:** `laravel/boost` v2.10.3 (lightweight tag `75c269a8a53e931c7252e7cd562e1a209356a7c6`), HEAD `30e24b7c242049e31bd267cd64b57301fc66b2f4`, MIT, 3.7k stars. It is an MCP + guidelines/skills installer (laravel-best-practices, livewire-development, pennant-development, tailwindcss-development). The official marketplace has an internal `laravel-boost` plugin — [repo](https://github.com/laravel/boost)
- **Language/role mega-plugin:** `jeffallan/claude-skills` → plugin `fullstack-dev-skills` 0.4.20 (tag commit = HEAD `36f3fe8052da7c57083783268c6ea3265d075265`), MIT, 12k stars. **67 skills in one plugin**: typescript-pro, python-pro, golang-pro, rust-engineer, php-pro, laravel-specialist, react-expert, nextjs-developer, django-expert, fastapi-expert, postgres-pro… — [repo](https://github.com/jeffallan/claude-skills)

**Registries and lists**
- **skills.sh / `npx skills` (vercel-labs/skills):**
  - Repo: HEAD = v1.7.4 = `a80e4c9d12d607631249d4d7d059f835d4b2f13a`, MIT, 36k stars. "Supports OpenCode, Claude Code, Codex, Cursor, and 75 more". Node ≥ 22.20. Commands: add/find/list/use/check/update/remove/init. It copies editable files rather than installing auto-updating plugins — [repo](https://github.com/vercel-labs/skills)
  - Leaderboard #1 is find-skills at 3.9M installs — [skills.sh](https://skills.sh)
- **Awesome lists:** hesreallyhim/awesome-claude-code (56k stars, active 2026-10-19); ComposioHQ/awesome-claude-skills (77k); VoltAgent/awesome-agent-skills (36k, active); travisvn/awesome-claude-skills (15k, **last commit 2026-04-28, STALE**) — [shields](https://img.shields.io/github/stars/hesreallyhim/awesome-claude-code)
- **Other large collections:**
  - alirezarezvani/claude-skills: v2.12.0, MIT, 28k stars, marketplace `claude-code-skills` with **99 plugins**, mostly non-dev (marketing, c-level…).
  - SuperClaude_Framework: v4.3.0, 24k stars.
  - davila7/claude-code-templates: v1.29.7, 33k stars.
  - K-Dense-AI/claude-scientific-skills: v2.72.0, 53k stars (science-niche).
  - openai/skills: 28k stars, **last commit 2026-06-23, STALE**, no Claude manifest.
  - Source: [alirezarezvani/claude-skills](https://github.com/alirezarezvani/claude-skills)
- `anthropics/claude-code-security-review` (GitHub Action): **last commit 2026-02-11, STALE** — [repo](https://github.com/anthropics/claude-code-security-review)

### Inferences
- **Complementary to superpowers (low trigger overlap):**
  - Official LSP plugins.
  - frontend-design.
  - security-guidance. It is hook-based, so it adds work on every edit and on Stop.
  - Trail of Bits security/testing skills.
  - Vendor skills: Stripe, Cloudflare, Supabase Postgres best practices, Sentry, Expo, Laravel Boost, Vercel React best practices.
  - PR-level review (official `code-review` and `pr-review-toolkit`). These work at a different layer from superpowers' per-task reviewer, at PR time with confidence filtering.
- **High overlap; cherry-pick only:**
  - **mattpocock/skills:**
    - Overlaps: grill-me ≈ brainstorming, tdd ≈ TDD, diagnosing-bugs ≈ systematic-debugging, to-spec/implement ≈ writing-/executing-plans, code-review.
    - Unique and valuable: grill-with-docs (glossary + ADR), improve-codebase-architecture, triage/to-tickets, git-guardrails-claude-code, setup-pre-commit.
  - **addyosmani/agent-skills:**
    - Overlaps: TDD, debugging, spec, plan, review.
    - Unique: performance-optimization, security-and-hardening, observability-and-instrumentation, ci-cd-and-automation, api-and-interface-design, deprecation-and-migration, documentation-and-adrs, frontend-ui-engineering, shipping-and-launch.
  - For both, a full plugin install doubles the process triggers next to superpowers. Copy individual skills (`npx skills add … --skill X`) into a team marketplace plugin instead.
- **Process frameworks:** Compound Engineering, GSD Core, BMAD, Spec Kit and OpenSpec are *alternatives* to superpowers' workflow spine, not add-ons. Exception: CE's `ce-compound`, `ce-babysit-pr` and `ce-resolve-pr-feedback` fill real gaps (knowledge capture and PR babysitting), and WotAI reports running CE and superpowers together with an explicit spine.
- **Avoid as team defaults:**
  - Mega-collections (alirezarezvani 99 plugins; jeffallan's 67 skills in one plugin; full wshobson). They inflate the skill listing; see section 4. Most of their content duplicates what modern models already know.
  - Whole-marketplace installs of trailofbits.
  - The old `anthropics/claude-code/plugins` copy. Use the official marketplace instead.
- The `/review` built-in collision (addy) and the duplicate-install warning (mattpocock) show that namespace and trigger collisions are a practical problem when stacking collections.
- **Built-in skills (not web-verified):** this research session's own Claude Code environment lists bundled `code-review`, `security-review` and `simplify` skills. Check whether the built-ins already cover what the official review plugins add before installing both.

### Gaps
- No reliable install counts for most Claude marketplace plugins. Superpowers' 1.1M figure is self-reported via a third-party site. skills.sh counts only `npx skills` installs.
- I did not inspect the internals of vercel/vercel-plugin, supabase-community/supabase-plugin, getsentry/plugin-claude or the open-gsd `.claude-plugin` manifests.
- Licenses for anthropics/skills and vercel-labs/agent-skills were "not specified" per shields. Individual skills in anthropics/skills carry their own LICENSE.txt (e.g. frontend-design says "Complete terms in LICENSE.txt"); check per skill.
- No first-hand Reddit or HN threads were read. HN sentiment is second-hand from search summaries: complaints about verbosity, rigid TDD and whole-plan regeneration; Evan Schwartz's positive "rave review" of 2026-04-02 drew about 50 HN points — [mention on blog.fsck.com](https://blog.fsck.com/mentions/mentions/2026-04-02-emschwartz-rave-review/); [mcp.directory](https://mcp.directory/blog/superpowers-skill-worth-it-2026). Treat as unverified.

## 3. Pinning data for recommended or plausible plugins (40-char SHAs, manifests, plugin names)

### Takeaway
Every repo below was resolved with `git ls-remote` on 2026-10-19. For a team marketplace, pin with a `url`/`github`/`git-subdir` source plus a `sha` field. Claude Code supports `ref` and `sha` pinning, and Anthropic's own marketplace does this for 262 of its 315 entries. Where a release tag exists, the peeled commit is the pin.

### Cited Findings
- **How pinning works:**
  - marketplace.json needs `name`, `owner` and `plugins[]`.
  - Each entry needs `name` and `source`. Sources can be a relative path, `github` `{repo}`, `git-subdir` `{url, path}`, `url`, `archive`, `npm` or `command`.
  - "pinning a git-based source to a `ref` or `sha`" is supported.
  - The entry name must equal the `name` in plugin.json.
  - Check with `claude plugin validate`.
  - The official marketplace names are reserved for Anthropic.
  - An org can require a marketplace on every machine.
  - Source: [Claude Code docs: Create a marketplace](https://code.claude.com/docs/en/plugin-marketplaces)
- Pin table (verified via ls-remote and the cloned manifests) — [sources: each repo on github.com/<owner>/<repo>]

| Repo | Pin commit (40-char) | What it is | `.claude-plugin` manifest(s) → plugin names | Last commit | Notes |
|---|---|---|---|---|---|
| obra/superpowers | `bb92a77741419a4ab5f06e711a283343f1ada0c3` | tag v7.0.0 (= HEAD) | marketplace.json `superpowers-dev` + plugin.json → `superpowers` | 2026-10-09 | same SHA pinned by claude-plugins-official |
| anthropics/claude-plugins-official | `a0b04d9ddccaabe1976645f68b0eda50f74e7022` | HEAD (no tags) | marketplace.json `claude-plugins-official` (315) → e.g. `frontend-design`, `code-review`, `pr-review-toolkit`, `feature-dev`, `security-guidance`, `commit-commands`, `code-simplifier`, `skill-creator`, `plugin-dev`, `hookify`, `typescript-lsp`, `pyright-lsp`, `gopls-lsp`, `rust-analyzer-lsp`, `php-lsp` (all `./plugins/<name>`) | 2026-10-19 | pin via git-subdir path `plugins/<name>` + sha |
| anthropics/skills | `dbd4588f9e1033efb41dad4bef2f7947c8993d44` | HEAD (no tags) | marketplace.json `anthropic-agent-skills` → `document-skills`, `example-skills`, `claude-api`, `academy-guide`, `discernment-nudge` | 2026-10-09 | |
| trailofbits/skills | `5c99c03fb8a9ea568432ecbcba5d86e9f4ac2bf0` | HEAD (no tags) | marketplace.json `trailofbits` (44 plugins; e.g. `differential-review`, `insecure-defaults`, `sharp-edges`, `static-analysis`, `property-based-testing`, `mutation-testing`, `modern-python`, `supply-chain-risk-auditor`, `second-opinion`) | 2026-10-15 | CC-BY-SA-4.0 |
| mattpocock/skills | `24fe0ef7737efae15c87225755e9f6f5965e4888` (tag v1.3.1); HEAD `5beb35b040e3de97e54fa9e386d7e42d15c295c2` | release/HEAD | marketplace.json `mattpocock` + plugin.json → `mattpocock-skills` | 2026-10-19 | official marketplace pins older `49dd158d1076134a641b33efb035946536778336` |
| addyosmani/agent-skills | `aeac41d4d005999432bb7312f7ff06383a91d59d` | tag 0.6.13 (= HEAD) | marketplace.json `addy-agent-skills` + plugin.json → `agent-skills` | 2026-10-13 | tag has no "v" prefix |
| EveryInc/compound-engineering-plugin | `94bda01bd5f7eb6e102c34f3797483aea5fa9b98` (tag compound-engineering-v3.31.0); HEAD `2e41b4490a37f53db0beb6d4904618da9af2f559` | release/HEAD | marketplace.json `compound-engineering-plugin` + plugin.json → `compound-engineering` | 2026-10-17 | competing workflow |
| wshobson/agents | `0874a27b17a22e2b7c2e2bcd725768e0803cad06` | HEAD (no tags) | marketplace.json `claude-code-workflows` (94; e.g. `python-development`, `javascript-typescript`, `systems-programming`, `jvm-languages`, `kubernetes-operations`, `database-migrations`) | 2026-10-17 | no root plugin.json |
| getsentry/skills | `f57ada2d0b640406ea7e25b11d636c530e77c58b` | HEAD (no tags) | marketplace.json `sentry-skills` + plugin.json → `sentry-skills` | 2026-10-15 | |
| cloudflare/skills | `86505e44f87d801aa1864a3c4109e9a8ae5c409f` | HEAD (no tags) | marketplace.json `cloudflare` + plugin.json → `cloudflare` (1.0.2) | 2026-10-15 | official pins `b052c32bab7dd493513260228a36c88294f343f1` |
| stripe/ai | `a8813a705651eaa68fab38943527a786ea5b411a` | HEAD (no tags) | marketplace.json `stripe` → `stripe` (0.11.23, path providers/claude/plugin) | 2026-10-19 | official pins `97b2164821c378f246c3903852057b36a8bd0296` |
| supabase/agent-skills | `544bfc56c89afe2b87b20017a59b2c6e9502a1fb` (tag v0.1.9); HEAD `c9be0e931b7930f7d02126d04774d904c381e7d7` | release/HEAD | marketplace.json `supabase-agent-skills` → `supabase`, `postgres-best-practices` | 2026-10-02 | |
| expo/skills | `7ddc1f5796996e5c7efe2fc3fa9168eb24e8dac1` | HEAD | marketplace.json `expo-plugins` → `expo`, `expo-experiments`, `expo-app-design`, `upgrading-expo`, `expo-deployment` | 2026-10-17 | |
| callstackincubator/agent-skills | `59e9d17446a248b21d86f078fcd0bd2d36db1ca4` | HEAD | marketplace.json `callstack-agent-skills` → `building-react-native-apps`, `testing-react-native-apps`, `migrating-to-react-native` | 2026-10-08 | |
| coderabbitai/skills | `fbfdb368fc2fa7fd3759f5ee346aea9123cea15b` (tag v1.1.1); HEAD `a8777050c0d9034d5de6beff3dfac9b43acb9854` | release/HEAD | plugin.json only (no marketplace.json) | 2026-10-19 | needs CodeRabbit CLI |
| vercel-labs/agent-skills | `063bee94c3f4df8453406c830b0a7df0f2860278` | HEAD | **none** (install via `npx skills`) | 2026-08-28 | would need wrapping in your own plugin |
| jeffallan/claude-skills | `36f3fe8052da7c57083783268c6ea3265d075265` | tag v0.4.20 (= HEAD) | marketplace.json `fullstack-dev-skills` + plugin.json → `fullstack-dev-skills` | 2026-10-16 | 67 skills in one plugin |
| obra/superpowers-chrome | `eabb66fabd244cd6eaddc13a652191179fda3a99` | HEAD | marketplace.json + plugin.json → `superpowers-chrome` (3.3.0) | 2026-10-10 | self-labelled BETA |
| obra/superpowers-lab | `51111f74f24058117752d9aa917cb19859f8ec86` | tag v0.5.0 (= HEAD) | plugin.json only → `superpowers-lab` | 2026-06-01 | STALE |
| open-gsd/gsd-core | `35f5a452239b897b8d6352c973e1e4efd683370f` (tag v1.18.0); HEAD `184255fbc02267ed8e5642f0a1f45968f1d98a0a` | release/HEAD | `.claude-plugin/marketplace.json` + `plugin.json` (contents not inspected) | 2026-10-19 | competing workflow; normally installed via npx |
| vercel-labs/skills (CLI) | `a80e4c9d12d607631249d4d7d059f835d4b2f13a` | tag v1.7.4 (= HEAD) | none (npm CLI) | 2026-10-19 | tool, not a plugin |

### Inferences
- **Lightweight vs annotated tags.** Lightweight tags show one `refs/tags/X` line in ls-remote, and that SHA is the commit (compound-engineering v3.31.0, open-gsd v1.18.0, supabase v0.1.9, laravel/boost v2.10.3, OpenSpec v1.14.3). Annotated tags also show a `^{}` peeled commit (superpowers v7.0.0, mattpocock v1.3.1, coderabbit v1.1.1, spec-kit v1.2.2, BMAD v6.12.4, addy 0.6.13, jeffallan v0.4.20, vercel-labs/skills v1.7.4, superpowers-lab v0.5.0). Pin the peeled commit, not the tag object.
- **Plugins inside the official marketplace** (`./plugins/<name>`): mirror them in a team marketplace with `{"source":"git-subdir","url":"anthropics/claude-plugins-official","path":"plugins/<name>","sha":"a0b04d9ddccaabe1976645f68b0eda50f74e7022"}`. Alternatively, keep `claude-plugins-official` enabled and pin only third-party sources in your own marketplace.
- **obra/superpowers-marketplace does not pin** (bare git URLs). A team that wants reproducibility should not point at it directly.

### Gaps
- I did not confirm the exact JSON field shape for `sha` on `github`-type sources in the marketplace reference page; only the overview page was fetched. The official marketplace uses `sha` on `url` and `git-subdir` sources, which confirms those two shapes in practice.

## 4. State of the Agent Skills open standard, progressive disclosure, triggering, and known problems

### Takeaway
SKILL.md is now a cross-vendor open standard (agentskills.io, Apache-2.0, 46 listed clients including Claude Code, Codex, Gemini CLI, Cursor, Copilot and OpenCode). Progressive disclosure keeps idle cost to name + description. The real failure modes are under-triggering from weak or truncated descriptions, listing-budget overflow when many skills are installed, rules being forgotten after compaction, and collisions between overlapping collections. Claude Code now ships tools (`/skill-doctor`, `/doctor`, `claude plugin eval`, `claude plugin validate`) to measure this.

### Cited Findings
- **Spec requirements:**
  - `name` (≤ 64 chars, lowercase/digits/hyphens, must match the directory name) and `description` (≤ 1024 chars, "what the skill does and when to use it").
  - Optional: `license`, `compatibility` (≤ 500 chars), `metadata` (string map), `allowed-tools` (experimental).
  - Optional directories: `scripts/`, `references/`, `assets/`.
  - Source: [Agent Skills specification](https://agentskills.io/specification); [agentskills/agentskills](https://github.com/agentskills/agentskills)
- **Progressive disclosure:** "Metadata (~100 tokens): … loaded at startup for all skills"; "Instructions (< 5000 tokens recommended)… loaded when the skill is activated"; "Keep your main SKILL.md under 500 lines" — [specification](https://agentskills.io/specification)
- The spec repo's last commit was 2026-08-09 (about 2.3 months before this research; not yet stale). Apache-2.0, 26k stars — [agentskills/agentskills](https://github.com/agentskills/agentskills)
- **Client showcase (46 entries):** Junie, Gemini CLI, OpenCode, OpenHands, Cursor, Amp, Letta, Goose, GitHub Copilot, VS Code, Claude Code, Claude, ChatGPT & Codex, Factory, pi, Databricks, TRAE, Spring AI, Roo Code, Mistral Vibe, Qodo, Laravel Boost, Snowflake Cortex Code, Kiro, Tabnine, Hermes Agent, OpenClaw… — [agentskills docs clients](https://agentskills.io/clients)
- **Triggering guidance:** "the description carries the entire burden of triggering". Agents "typically only consult skills for tasks that require knowledge or capabilities beyond what they can handle alone. A simple, one-step request… may not trigger" a skill. Recommendations: imperative "Use this skill when…", focus on user intent, "Err on the side of being pushy", stay concise, and test with about 20 eval queries (8–10 should-trigger, 8–10 near-miss should-not) — [Optimizing skill descriptions](https://agentskills.io/skill-creation/optimizing-descriptions)
- **Claude Code specifics: listing cost and budget**
  - "Every skill in the skill listing adds to your context on every turn, whether or not Claude ever uses it."
  - `description` + `when_to_use` are capped at **1,536 chars** (`skillListingMaxDescChars`).
  - The listing budget "scales at 1% of the model's context window". On overflow, Claude Code "drops descriptions starting with the skills you invoke least" (names stay).
  - Tunable with `skillListingBudgetFraction` (e.g. 0.02), `SLASH_COMMAND_TOOL_CHAR_BUDGET`, and `skillOverrides` → `"name-only"`.
  - Source: [Claude Code skills docs](https://code.claude.com/docs/en/skills)
- **Claude Code specifics: diagnostics and compaction**
  - `/doctor` estimates listing cost. `/skill-doctor` (v2.1.252+) reports per-skill context cost and usage and flags never-invoked skills. The `/context` Skills row shows the post-budget size (since v2.1.196).
  - After compaction, Claude Code re-attaches each invoked skill's most recent invocation, "keeping the first 5,000 tokens of each… combined budget of 25,000 tokens", so put the most important instructions at the top.
  - Rules that must always hold belong in hooks (the skill's `hooks` frontmatter), because Claude Code "doesn't re-read the file" on later turns.
  - Source: [Claude Code skills docs](https://code.claude.com/docs/en/skills)
- **Claude Code specifics: frontmatter and debugging**
  - Extra frontmatter fields: `when_to_use`, `argument-hint`, `arguments`, `disable-model-invocation`, `user-invocable`, `allowed-tools`, `disallowed-tools`, `model`, `effort`, `context: fork`, `agent`, `background`, `hooks`, `paths` (glob-scoped auto-activation), `shell`.
  - Outside Claude Code (claude.ai uploads, Skills API) only the six spec fields are allowed; others cause a hard error.
  - Malformed YAML loads the skill body with empty metadata, so it can never auto-trigger. Use `claude plugin validate .claude/skills` (v2.1.233+) and `claude plugin eval` with a `tool_used: Skill` grader to measure trigger rate.
  - Source: [Claude Code skills docs](https://code.claude.com/docs/en/skills)
- **Collision handling in practice:**
  - With superpowers and Compound Engineering both installed, superpowers' SessionStart hook "fires first, so its skills usually win collisions". The fix is declaring the "spine" in AGENTS.md — [WotAI](https://wotai.co/blog/compound-engineering-vs-superpowers)
  - Addy's plugin `/review` collides with a built-in command — [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills)
  - Installing mattpocock's skills both as a plugin and via skills.sh "gives you every skill twice" — [mattpocock/skills](https://github.com/mattpocock/skills)
- **Unverified claim:** an AI-news alert says all installed skills load full text at session start, costing about 23K tokens per session. This contradicts Anthropic's docs and is based on one developer's log audit — [aiweekly alert](https://aiweekly.co/alerts/claude-code-skills-waste-23k-tokens-per-session)
- **Security of third-party skills:**
  - Snyk ToxicSkills (2026-02-05) scanned 3,984 skills from ClawHub and skills.sh: 534 (13.4%) had ≥ 1 critical issue, 1,467 (36.82%) had any issue, and 76 confirmed malicious payloads were found. Snyk suggests `uvx mcp-scan@latest --skills` — [Snyk](https://snyk.io/blog/toxicskills-malicious-ai-agent-skills-clawhub)
  - skills.sh lists a third-party re-host "101-skills/superpowers" with 3.2M installs across 4 skills (not obra's repo; HEAD `becc25649700d5457772a00e5143e28ccf9e5afa`) — [skills.sh](https://skills.sh)

### Inferences
- Stacking a full superpowers install with big collections (67- to 99-skill plugins) is the quickest way to blow the 1%-of-context listing budget. Overflow silently strips descriptions from the skills used least, so those skills stop triggering. Check this with `/skill-doctor` after any addition.
- Superpowers already handles the triggering problem for its own skills (SessionStart bootstrap plus "You MUST" descriptions). Added skills with ordinary descriptions will lose priority to superpowers' process skills. Write added skills with specific, intent-focused descriptions, use `paths:` for stack-specific skills, and set `disable-model-invocation: true` for rare manual workflows.
- Install vendor and stack skills at project scope (per repo), not user scope, so a Stripe or Expo skill only lists in repos that use it.
- The supply-chain risk is real: prefer vendor-owned repos and SHA pins, and avoid re-hosts.

### Gaps
- No primary Anthropic number on the absolute token size of a typical listing.
- I did not verify which other harnesses (Codex, Gemini CLI, Cursor) apply similar truncation.
- No data on how often superpowers' own skills fail to trigger beyond the internal probe numbers in its release notes.

## 5. Evidence that skills measurably improve outcomes, versus hype

### Takeaway
Independent benchmarks are sobering. Most public skills give zero or negative pass-rate change while raising token cost substantially. Gains come from a minority of focused, domain-specific skills. Superpowers' own evidence is internal evals (A/B probes, token and time savings), and community evidence is anecdotal. Treat every skill as a hypothesis to be measured per project and model, using `claude plugin eval`.

### Cited Findings
- **SWE-Skills-Bench** (Han et al., arXiv 2603.15401, 16 Mar 2026):
  - 49 public SWE skills, about 565 tasks in real repos pinned at fixed commits, paired with/without the skill.
  - "39 of 49 skills yield zero pass-rate improvement"; the average gain is **+1.2%**.
  - Seven specialised skills gave up to +30%. Three degraded results by up to −10%, attributed to "version-mismatched guidance conflicting with project context".
  - Token overhead ranged up to +451% with unchanged pass rates.
  - Source: [arXiv 2603.15401](https://arxiv.org/abs/2603.15401)
- **WebDev-Skills-Bench, "Signal or Noise?"** (Yang & Ding, arXiv 2608.23067, 24 Aug 2026):
  - 31 public WebDev skills, 50 projects / 1,000 tasks, 4 models.
  - Skill injection **reduced** mean Pass@2 by 1.3–4.2%, raised token cost by 72–394%, and helped in only 17–36% of skill-project pairs.
  - A length-matched irrelevant skill reproduced most of the loss for "length-distracted" models.
  - "anti-pattern rules outperformed example-heavy content"; skill rankings transfer weakly across models.
  - Source: [arXiv 2608.23067](https://arxiv.org/abs/2608.23067)
- **SkillsBench** (self-reported leaderboard, from a search summary only): focused skills with 2–3 modules beat comprehensive docs, and ">4 skills can hurt" — [benchmarklist SkillsBench](https://benchmarklist.com/benchmarks/skillsbench/). Unverified.
- **Superpowers' internal evals** (vendor-run, not independent):
  - v6.0.0 SDD redesign: "roughly twice as fast and while spending almost 50% fewer tokens".
  - v6.2.0: deleting TDD rebuttals cut test-first behaviour from 8/10 to 5/10, so the rebuttals were kept as rationalization rows.
  - v6.4.2: leaner plans took "a quarter of the time and about a third of the tokens", and "Every plan … executed 9/9 against planted-defect probes on Sonnet 5".
  - v6.4.1: TDD fix after 11/12 probe runs tested only the named file.
  - Source: [RELEASE-NOTES.md](https://github.com/obra/superpowers/blob/main/RELEASE-NOTES.md)
- **Jesse Vincent's own claim:** "good process management and guidance still produce better results than letting a model work without supervision"; the post contains no benchmark numbers — [What a year](https://blog.fsck.com/2026/10/09/what-a-year/)
- **Community anecdote** (search summary, not verified): a 12-session comparison (6 with, 6 without) reported superpowers "cut tokens by 14% and boosted code quality — but not for every task" — [developersdigest guide](https://www.developersdigest.tech/blog/claude-code-superpowers-plugin-guide); [mcp.directory](https://mcp.directory/blog/superpowers-skill-worth-it-2026)
- **Tooling to measure per team:** `claude plugin eval` (Claude Code ≥ 2.1.269) runs eval cases with and without the plugin. addyosmani/agent-skills enforces a ≥ 95% rank-1 trigger floor in CI and keeps a ledger of rejected skill changes — [addyosmani/agent-skills evals](https://github.com/addyosmani/agent-skills/tree/main/evals); [Claude Code skills docs](https://code.claude.com/docs/en/skills)

### Inferences
- **Two kinds of skill.** The benchmarks test *knowledge* skills (generic best-practice dumps), which modern models largely already know, and those show little or negative value. Superpowers is a *process/behaviour* skill set (forcing test-first, verification, review). The benchmarks don't measure that dimension directly, so neither proves nor disproves superpowers' value.
- **Version-mismatch risk.** Version-mismatched guidance was the cause of degradation in SWE-Skills-Bench. That argues for vendor-maintained skills (Stripe, Cloudflare, Expo, Supabase) over community ones and for pinning plus regular bumps. It argues against generic "react-expert" or "python-pro" mega-skills.
- **Team policy (recommendation):** add a skill only when (a) it encodes project-, vendor- or team-specific knowledge the model lacks, or (b) a `claude plugin eval` A/B shows improvement on your own repos. Remove skills that `/skill-doctor` shows were never invoked.

### Gaps
- No independent controlled benchmark of superpowers, Compound Engineering, GSD or mattpocock skills against a baseline was found.
- Neither arXiv study names the skills tested in its abstract, so whether superpowers-style process skills were included is unknown.
- The SkillsBench and RigorBench claims are self-reported and unverified. RigorBench reports +41% process quality and +17% correctness from structured process discipline, per a search summary.

## 6. Verdicts for a team already on superpowers: add, replace, or ignore

### Takeaway
Keep superpowers v7.0.0 (pin `bb92a777…`) as the single workflow spine. Add narrow, stack- or security-specific plugins at project scope and selected skills from mattpocock and addyosmani. Do not add a second process framework unless one is explicitly designated the spine. Ignore mega-collections, awesome lists as install sources, re-hosts, and stale repos.

### Cited Findings
- Superpowers is in Anthropic's official marketplace, pinned to v7.0.0, and its release cadence is active (v7.0.0 on 2026-10-09) — [claude-plugins-official](https://github.com/anthropics/claude-plugins-official/blob/main/.claude-plugin/marketplace.json); [RELEASE-NOTES.md](https://github.com/obra/superpowers/blob/main/RELEASE-NOTES.md)
- Overlapping process plugins collide, and superpowers' hook wins by default — [WotAI](https://wotai.co/blog/compound-engineering-vs-superpowers)
- The listing budget is 1% of context, and descriptions of the least-used skills are dropped first — [Claude Code skills docs](https://code.claude.com/docs/en/skills)
- Most generic public skills show no pass-rate gain, and some degrade results — [arXiv 2603.15401](https://arxiv.org/abs/2603.15401); [arXiv 2608.23067](https://arxiv.org/abs/2608.23067)

### Inferences
**ADD (complements superpowers; low trigger overlap)**
- **LSP plugins** for each language you use (`typescript-lsp`, `pyright-lsp`, `gopls-lsp`, `rust-analyzer-lsp`, `php-lsp`; from claude-plugins-official at `a0b04d9d…`). They provide code intelligence, which superpowers lacks entirely, and need the language-server binaries installed.
- **`frontend-design`** (official) for UI work. It fills the design-quality gap and is #12 on skills.sh.
- **PR-level review:** official `code-review` (confidence ≥ 80 filtering, 4 parallel agents) or `pr-review-toolkit` (silent-failure-hunter, type-design-analyzer, pr-test-analyzer). These work at PR time, complementing superpowers' per-task review in SDD. Pick one, and check overlap with the Claude Code built-in `/code-review` first.
- **Security:**
  - Either official `security-guidance` (hooks on edit/Stop, so it has a cost) or Trail of Bits cherry-picks: `differential-review`, `insecure-defaults`, `sharp-edges`, `static-analysis`, `supply-chain-risk-auditor`.
  - For testing depth: `property-based-testing` and `mutation-testing`.
  - For Python: `modern-python`.
  - Note the CC-BY-SA-4.0 license on Trail of Bits skills.
- **Vendor skills, per project only:** Stripe (`stripe@stripe`), Cloudflare (`cloudflare`), Supabase (`postgres-best-practices`), Sentry (`sentry-skills`, which also has strong commit/PR/find-bugs skills), Expo/Callstack for React Native, Laravel Boost for Laravel, Vercel `react-best-practices` (via `npx skills` or wrapped into a team plugin).
- **From mattpocock/skills, cherry-picked:** `grill-with-docs` (domain glossary + ADRs), `improve-codebase-architecture`, `triage`/`to-tickets` (issue-tracker workflow), `git-guardrails-claude-code`, `setup-pre-commit`. Fork or copy these into the team marketplace rather than installing the whole `mattpocock-skills` plugin, whose `tdd`, `diagnosing-bugs`, `grill-me` and `implement` would compete with superpowers.
- **From addyosmani/agent-skills, cherry-picked:** `performance-optimization`, `security-and-hardening`, `observability-and-instrumentation`, `ci-cd-and-automation`, `api-and-interface-design`, `deprecation-and-migration`, `documentation-and-adrs`, `shipping-and-launch`. Skip its TDD, debugging, spec and plan skills and its commands.
- **Optionally, from Compound Engineering, the knowledge-capture and PR-babysitting ideas** (`ce-compound`, `ce-babysit-pr`, `ce-resolve-pr-feedback`). The plugin is monolithic, so this needs either full CE with an explicit spine declared in AGENTS.md or reimplementing as team skills.

**REPLACE (only if the team rejects superpowers' ceremony)**
- **Compound Engineering:** suits PR-centric teams that want learnings persisted.
- **mattpocock/skills:** suits teams that want lighter, user-invoked, composable skills; its README positions it explicitly against process-owning frameworks.
- **GSD Core:** suits multi-phase greenfield delivery with persistent state files.
- **Spec Kit / OpenSpec:** suit spec-first or brownfield change-proposal workflows; OpenSpec is lighter.
- Never run two of these alongside superpowers without declaring a spine.

**IGNORE**
- **Mega-collections as team defaults:** alirezarezvani/claude-skills (99 plugins, mostly non-dev), jeffallan `fullstack-dev-skills` (67 skills in one plugin), whole wshobson/agents, SuperClaude, K-Dense scientific skills. They risk listing-budget overflow and duplicate model knowledge. Exception: individual wshobson language plugins, at project scope, after an eval.
- **Awesome lists** (hesreallyhim, ComposioHQ, VoltAgent, travisvn): use for discovery only, never as install sources.
- **Re-hosts of superpowers on skills.sh** (e.g. 101-skills/superpowers): a supply-chain risk.
- **Stale repos:**
  - obra/superpowers-developing-for-claude-code (last commit 2025-12)
  - obra/superpowers-lab (2026-06; experimental)
  - gsd-build/get-shit-done (moved)
  - openai/skills (2026-06)
  - travisvn/awesome-claude-skills (2026-04)
  - anthropics/claude-code-security-review (2026-02)
  - the `plugins/` copy inside anthropics/claude-code
- **superpowers-chrome:** BETA. Evaluate it only if browser verification is a priority.

### Gaps
- The verdicts are inferences from repository contents, Anthropic docs and two independent benchmarks. None of these combinations was A/B-tested on the team's own repositories. That should be done with `claude plugin eval` and `/skill-doctor` before rolling out to the team.
