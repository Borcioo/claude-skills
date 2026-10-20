# Tools, settings and techniques that cut token use/cost and speed up AI coding agents (mainly Claude Code), as of October 2026

Scope note: research done 2026-10-19. Repo activity data (stars, last commit, latest release) comes from img.shields.io badges fetched that day, because the GitHub API was blocked. Version numbers like "v2.1.283" are Claude Code CLI versions cited in the official docs fetched that day. "Claim" means the vendor's or author's own number. "Measured (independent)" means a third party ran a controlled comparison. Memory systems and autonomous loops/orchestration are left out on purpose.

Current Anthropic list prices per MTok, for reference in every section below (input / 5-min cache write / 1-h cache write / cache read / output). Source: [Anthropic pricing](https://platform.claude.com/docs/en/about-claude/pricing).

| Model | Input | 5m write | 1h write | Cache read | Output |
|---|---|---|---|---|---|
| Fable 5.1 | $10 | $12.50 | $20 | $0.25 | $50 |
| Opus 5.5 | $4 | $5 | $8 | $0.20 | $20 |
| Opus 5 / 4.8 | $5 | $6.25 | $10 | $0.50 | $25 |
| Sonnet 5.5 | $2 | $2.50 | $4 | $0.10 | $10 |
| Sonnet 5 | $2 | $2.50 | $4 | $0.20 | $10 |
| Sonnet 4.6 | $3 | $3.75 | $6 | $0.30 | $15 |
| Haiku 5.5, prompt ≤100K | $0.10 | $0.125 | $0.20 | $0.01 | $0.50 |
| Haiku 5.5, prompt >100K | $0.50 | $0.625 | $1 | $0.05 | $2.50 |

## 1. Usage and cost observability: which tools are maintained and useful?

### Takeaway
Claude Code's built-in tools now cover most of what third-party trackers used to be needed for. `/usage` shows a session cost estimate, a prompt-cache hit line and, on plans, how usage splits across skills, subagents and MCP servers. The status line receives cost, context %, 5h/7d limit and cache data as JSON, `/insights` writes a usage report, and teams can export OpenTelemetry. Among third-party tools, ccusage (history reports across agents) and ccstatusline / claude-powerline (status lines) are actively maintained in October 2026. Claude-Code-Usage-Monitor is slowing, and the 2025 OTel starter repos are stale. The "tokens saved" counters that compressor tools show are not billing data.

### Cited Findings
**Native Claude Code**
- Anthropic's enterprise baseline: about **$13 per developer per active day** and **$150–250 per developer per month**, with 90% of users under $30 per active day. — [Claude Code docs: Manage costs](https://code.claude.com/docs/en/costs)
- The `/usage` Session block computes dollar cost locally from token counts at list price. It is an estimate; the Claude Console is the authoritative bill. The totals reset on `/clear` since v2.1.211. The managed setting `modelPricing` (v2.1.242+) makes the figures use contracted rates. — [Manage costs](https://code.claude.com/docs/en/costs)
- The `Prompt cache (main)` line (v2.1.251+) shows request count, the share of input tokens served from cache, misses (with "likely cause", e.g. `tool definitions changed`, v2.1.260+), expected rebuilds after compaction or tool-result clearing, and warm/cold state with the TTL. It covers the main conversation only, not subagents. — [Manage costs](https://code.claude.com/docs/en/costs)
- On Pro/Max/Team/Enterprise, `/usage` attributes usage to skills, subagents, plugins and individual MCP servers. It flags behaviors such as long context or cache misses when they cause ≥10% of usage, and lists the heaviest `/loop` and scheduled tasks (v2.1.242+). It has a 24h/7d toggle and uses local data only. — [Manage costs](https://code.claude.com/docs/en/costs)
- The token count beside the spinner shows only the current turn's *output*, including thinking and foreground subagents. It does not include the context sent. — [Manage costs](https://code.claude.com/docs/en/costs)
- `/insights` writes an HTML report over up to 200 new sessions, covering friction points and an estimate of how many permission prompts auto mode could have handled. Running it costs tokens. — [Manage costs](https://code.claude.com/docs/en/costs)
- Background token use (resume summaries, status checks) is "typically under $0.04 per session". — [Manage costs](https://code.claude.com/docs/en/costs)
- Status line scripts receive JSON with these fields:
  - `cost.total_cost_usd` (list-price estimate, resets on `/clear`), `cost.total_duration_ms` and `total_api_duration_ms`.
  - `context_window.used_percentage`, counting input only: input + cache_creation + cache_read.
  - `context_window_size`, `current_usage` and `exceeds_200k_tokens`.
  - `rate_limits.five_hour` / `seven_day` `.used_percentage` and `resets_at` (Pro/Max only).
  - `rate_limits.spend_limit` (behind a Claude apps gateway).
  - A `prompt_cache` object (v2.1.251+).
  
  Updates are debounced at 300 ms. An optional `refreshInterval` (minimum 1 s) adds timer-based refreshes. — [Claude Code docs: Status line](https://code.claude.com/docs/en/statusline)
- OpenTelemetry setup:
  - Enable it with `CLAUDE_CODE_ENABLE_TELEMETRY=1` plus `OTEL_METRICS_EXPORTER` / `OTEL_LOGS_EXPORTER`. Metrics export every 60 s by default, logs every 5 s.
  - Metrics include `claude_code.cost.usage` (USD), `claude_code.token.usage` (type = input/output/cacheRead/cacheCreation), sessions, LOC, PRs, commits, edit decisions and active time.
  - Cost and token metrics carry `model`, `speed`, `effort`, `agent.name`, `skill.name` and `mcp_server.name`.
  - Events include `api_request` (cost, duration, cache tokens) and `tool_result` (duration_ms, tool_result_size_bytes).
  - Prompts and tool details are redacted by default. Traces are beta (`CLAUDE_CODE_ENHANCED_TELEMETRY_BETA=1`). Repo-level `.claude/settings.json` ignores OTLP variables.
  
  — [Claude Code docs: Monitoring usage](https://code.claude.com/docs/en/monitoring-usage)
- The docs call OTel "the only option that streams per-user token and cost metrics into your own observability stack in near real time". Anthropic's analytics dashboards don't cover Bedrock, Google Cloud or Foundry usage, so per-user attribution there needs OTel, the Claude apps gateway, or an LLM gateway such as LiteLLM. — [Manage costs](https://code.claude.com/docs/en/costs)
- Per-user reporting by plan:
  - Console API users: the Claude Code Analytics API.
  - Enterprise: the Enterprise Analytics API.
  - Teams: a spend report CSV.
  
  — [Manage costs](https://code.claude.com/docs/en/costs)
- `claude -p --output-format json` returns `total_cost_usd` plus a per-model cost breakdown. It is a client-side estimate. — [Claude Code docs: Headless](https://code.claude.com/docs/en/headless)

**Third-party (status as of 2026-10-19)**
- **ccusage** (ryoppippi/ccusage): 19k stars, v20.0.37, last commit on 2026-10-19.
  - Reads local logs of 18 agent CLIs (Claude Code, Codex, OpenCode, Amp, Droid, Gemini CLI, Copilot CLI, and others).
  - Reports: daily, weekly, monthly, session, and `blocks` (Claude's 5-hour windows), plus a statusline mode (beta).
  - Tracks cache-creation and cache-read tokens separately. Supports `--breakdown` per model, `--json`, `--offline` pricing, and custom pricing overrides.
  - Its sponsor Lineman.io advertises "40% lower token usage". That is an unverified vendor claim.
  
  — [ccusage README](https://raw.githubusercontent.com/ryoppippi/ccusage/HEAD/apps/ccusage/README.md); [shields](https://img.shields.io/github/stars/ryoppippi/ccusage.json)
- **ccstatusline** (sirmalloc): 13k stars, v2.2.32, commits in the week of research.
  - Cost/usage widgets: a `Cache Timer` (HOT state plus TTL countdown, 5 min or 1 h), Session Cost Rate ($/h), an Extra Usage Daily Budget, block and weekly reset timers, and weekly Opus/Sonnet/Fable usage.
  - Context % resets from `compact_boundary.postTokens` after `/compact`.
  - Other widgets: Claude service status, sandbox status and CI status.
  - 64 PRs have been merged since 2026-09-03.
  
  — [ccstatusline README](https://github.com/sirmalloc/ccstatusline)
- **claude-powerline** (Owloops): 1.2k stars, v1.32.4, last commit the day before research. It has session, today and month segments with budgets (defaults $50/day and $500/month) and a context segment with `autocompactBuffer` (default 33000). Cost comes either "calculated" (ccusage-style) or "official" (hook data). It installs as a Claude Code plugin. — [claude-powerline README](https://github.com/Owloops/claude-powerline)
- **Claude-Code-Usage-Monitor** (Maciek-roboblog): 8.7k stars, v4.0.0, last commit June 2026, so it is slowing. — [shields](https://img.shields.io/github/last-commit/Maciek-roboblog/Claude-Code-Usage-Monitor.json)
- **Stale:** ColeMurray/claude-code-otel (512 stars, last commit June 2025) and anthropics/claude-code-monitoring-guide (377 stars, last commit July 2025). The official docs page now supersedes both. — [shields](https://img.shields.io/github/last-commit/ColeMurray/claude-code-otel.json); [shields](https://img.shields.io/github/last-commit/anthropics/claude-code-monitoring-guide.json)
- **Compressor savings counters are not billing data.**
  - RTK's `rtk gain` estimates tokens as bytes/4 without a tokenizer. — [RTK savings explained](https://raw.githubusercontent.com/rtk-ai/rtk/HEAD/docs/guide/resources/savings-explained.md)
  - In Quesma's benchmark, `rtk gain` reported "349.2 million tokens saved" (an "89% reduction") on DeepSeek runs while the actual bill rose about 5%. — [Quesma](https://quesma.com/blog/does-rtk-make-ai-coding-cheaper/)

### Inferences
- A solo subscriber needs no extra install: the native statusline (rate_limits, context %, prompt_cache) plus `/usage` attribution answer "where do my tokens go". ccusage adds multi-week history and coverage across several agents. ccstatusline and claude-powerline add better at-a-glance widgets such as the cache timer and budgets.
- The most actionable number to watch is the prompt-cache hit ratio and its misses. Anthropic's own team alerts on it (see Q3), and on 5.5 models a cache read costs 0.05x of input.
- Treat "tokens saved" counters from RTK or caveman as advertising unless they are compared against billed tokens.

### Gaps
- No 2026 independent audit of how closely ccusage, `/usage` or OTel cost estimates match actual invoices. All of them compute at list price unless configured otherwise.
- I did not measure the CPU/latency overhead of third-party statusline tools.

## 2. Token-reduction tools: which exist, and claimed vs independently measured savings

### Takeaway
The two most-starred compressors, RTK (84k stars) and caveman (114k stars), exist, are maintained and are honest about their limits in their own docs. Independent controlled benchmarks, however, show savings far below the headlines:
- caveman's terse output: about **8.5% fewer output tokens** (JetBrains, 86 tasks) instead of the advertised ~65–75%.
- RTK: **−5% to +17% cost** depending on model (Quesma, 1,740 attempts), and **+7.6% / ±0%** in JetBrains' test.

The reason: in agent loops most billed input is cached re-reads of context, and modern models already truncate command output with `head`/`tail`.

Code intelligence (LSP) gives modest, real gains on large codebases, mostly through precision. Semantic indexing (claude-context) and Serena have only vendor-run evidence. Packers (repomix/code2prompt) target chat-style context dumps, not agent loops.

### Cited Findings
**RTK (rtk-ai/rtk)**: 84k stars, v1.0.1, last commit on 2026-10-19.
- What it is: one Rust binary that "filters and compresses command outputs before they reach your LLM context". It covers 100+ commands with "<10ms overhead" and claims output is "up to 90% smaller".
- Installs as a Claude Code PreToolUse hook (`rtk init -g`). It only fires on Bash tool calls: built-in Read/Grep/Glob bypass it.
- Licensing: the CLI is Apache-2.0, the engine is BUSL-1.1, and an optional BUSL `rtk-proxy` compresses API traffic and can route calls to cheaper models.
- Telemetry is off by default. Another, unrelated "rtk" crate exists on crates.io.

— [RTK README](https://github.com/rtk-ai/rtk)
- RTK's own docs: "A command showing 90% fewer output bytes does not make your session 90% cheaper". Token counts are bytes/4 estimates. — [RTK: How savings work](https://raw.githubusercontent.com/rtk-ai/rtk/HEAD/docs/guide/resources/savings-explained.md)
- Measured (independent): **Quesma** (Kotrys & Migdal, 11 Sep 2026). — [Quesma](https://quesma.com/blog/does-rtk-make-ai-coding-cheaper/)
  - Setup: Terminal-Bench 2.1, Claude Code + Fable 5.0 and OpenCode + DeepSeek V4 Pro, 5 runs with and 5 without RTK per task, 1,740 attempts in total, over $1,500 spent.
  - Fable: total bill $731 → $698 (−5%), pass rate 84% → 83%. Nearly all the saving came from one task, and the per-task average cost moved +1% (not significant).
  - DeepSeek: total $51 → $54 (+5%), per-task cost +17%, 18% more turns, pass rate 71% → 69%.
  - Where input went: terminal output was ~11% (Fable) and ~40% (DeepSeek) of input tokens. Cache reads were 94% / 98% of input tokens but only 30% / 26% of the bill.
  - An RTK rewrite bug caused 339 consecutive errors on one attempt (~9x its baseline cost); it was fixed in 0.46.0.
  - Verdict: "a niche optimization"; frontier models already limit output themselves.
- Measured (independent, secondary report): **JetBrains Part 2** (Claude Code 2.1.201) found RTK **+7.6% more expensive at low effort and ±0% at high effort**, with quality unchanged. The primary post returned HTTP 403, so these figures come from search summaries of [JetBrains: rtk Claude Code token savings](https://blog.jetbrains.com/ai/2026/07/rtk-claude-code-token-savings/) and from [Quesma](https://quesma.com/blog/does-rtk-make-ai-coding-cheaper/).

**caveman (JuliusBrussee/caveman)**: 114k stars, v4.0.1, last commit the Saturday before research. Version 4.0 bundles six parts: terse "voice", input compression, an "Auto" model/effort router, "Blocks" (reusable scripts), cache warming, and page compression. — [caveman README](https://github.com/JuliusBrussee/caveman)
- Author's own numbers (claims), on ten dev questions with claude-opus-5-5:

  | Setting | Output tokens |
  |---|---|
  | No instruction | 6,983 |
  | `Answer concisely.` | 4,334 |
  | `/caveman` | 4,119 |
  | `/ultracave` | 2,693 |

  The README itself says "Be concise" is the real baseline, that `/caveman` adds only 3% at the median, and that the rules cost ~1,160 input tokens. With per-request pricing (GitHub Copilot) shorter answers save nothing. — [caveman README](https://github.com/JuliusBrussee/caveman)
- Other author claims:
  - "Read less": 33.2% fewer input tokens per session (885,793 → 591,673). The test files are synthetic (each hides one record in 61–72 KB of noise), the run used an older engine, and HTML came out 9.9% *worse*.
  - "Auto" router: 54% cheaper than Opus 5.5 at xhigh effort (43.7% vs 44.3% solved, $3.59 vs $7.83 per try). The run is half done, the score margin is ±7 points, and most of the saving comes from lowering effort.
  - `/caveman-compress` on CLAUDE.md files: 6,198 → 4,138 tokens.
  
  — [caveman README](https://github.com/JuliusBrussee/caveman)
- caveman privacy: the CLI sends usage telemetry **by default** (turn off with `DO_NOT_TRACK=1`). "Auto" sends your latest ask plus attached CLAUDE.md/memory/files to Caveman Cloud, which may keep it on the free plan. — [caveman README](https://github.com/JuliusBrussee/caveman)
- Measured (independent): **JetBrains Part 1** (Denis Shiryaev, July 2026). — [TechTimes](https://www.techtimes.com/articles/320756/20260716/jetbrains-tests-caveman-token-skill-86-real-tasks-savings-hit-9-not-65.htm); [InfoWorld](https://www.infoworld.com/article/4193775/talk-like-a-caveman-prompts-save-tokens-but-far-less-than-promised.html); primary post (HTTP 403 when fetched) at [JetBrains blog](https://blog.jetbrains.com/ai/2026/07/speak-to-ai-agents-like-cavemen-tosave-tokens/)
  - Setup: SkillsBench, 86 paired tasks, Harbor 0.17, Claude Sonnet 5 at low effort, skill forced on.
  - Result: **8.5% fewer output tokens** (best case). An early 10-task sample had suggested ~30%.
  - Quality: no difference (p = 0.82).
  - The caveman arm had a *higher* cumulative cost over the full benchmark because one task crossed a long-context pricing tier.
  - Verdict: "Safe, honest about style, oversold on savings."
- Measured (independent research): **Adobe Research "CAVEWOMAN"** (arXiv 2606.24083, 23 Jun 2026; 8 models, 5 datasets). — [arXiv](https://arxiv.org/abs/2606.24083)
  - Compressing the model's *output* cut realized cost 1.4–2.4x per model, up to 3x.
  - Compressing the user's *input prompt* raised net cost about 1.15x on average, up to 2.7x under stronger compression, because models answered at greater length while accuracy collapsed ("strict lose-lose").
- Hacker News discussion (#1, 904 points): the author said the early "~75%" figure "is from preliminary testing, not a rigorous benchmark". Skeptics pointed out that input tokens dominate agent costs and that thinking tokens are unaffected. — [HN thread](https://news.ycombinator.com/item?id=47647455)
- **claude-token-efficient** (drona23): 6.1k stars, last commit June 2026. It claims 63% fewer words from a terse CLAUDE.md, based on **5 prompts with no repeat runs**. Its own disclaimer says short or casual use gives a *net token increase*, because the file loads on every message, and an independent replication found 7–12-line configs beat longer rule sets. — [BENCHMARK.md](https://github.com/drona23/claude-token-efficient/blob/main/BENCHMARK.md)

**LSP / code intelligence**
- Official docs: code intelligence plugins mean "a single 'go to definition' call replaces what might otherwise be a grep followed by reading multiple candidate files". Language servers also report type errors automatically after edits. — [Manage costs](https://code.claude.com/docs/en/costs)
- Measured (semi-independent): **CircleCI** (24 Jun 2026; vuejs/core, ~149K LOC TypeScript; 3 tasks with 11, 20 and 260 call sites; run count not disclosed). — [CircleCI](https://circleci.com/blog/claude-code-lsp/)

  | Model | Cost, grep → LSP | Tool-output tokens | Time |
  |---|---|---|---|
  | Opus 4.8 | $1.26 → $1.22 (−3%) | −31% | +2% |
  | Sonnet 4.6 | $0.77 → $0.66 (−14%) | −33% | −34% |

  - Sonnet with grep alone missed references (9 of 11, 249 of 260).
  - It only worked with a CLAUDE.md line telling Claude to trust LSP results; otherwise Claude re-reads files.
  - Small tasks pay a tool-search overhead to load the LSP tool.
- Vendor-ish claims: "LSP saves 5–34x tokens vs grep" (written by the agent-lsp tool's author) — [DEV](https://dev.to/daynablackwell/we-measured-it-lsp-saves-ai-agents-5-34x-tokens-vs-grep-427). The lsp-enforcement-kit hooks claim "~80%" from hand-estimated per-operation counts — [GitHub](https://github.com/nesaminua/claude-code-lsp-enforcement-kit).
- **Serena** (oraios/serena): 30k stars, v2.1.0, active. It offers LSP-backed symbolic tools for 40+ languages, or a JetBrains backend. Its README "evaluation" consists of agents' own testimonials (e.g. Opus 4.6: "8–12 careful, error-prone steps collapse into one atomic call"); there is no token measurement. — [Serena README](https://github.com/oraios/serena)
- **claude-context** (zilliztech): 13k stars, last commit July 2026, no releases. Vendor evaluation on 30 SWE-bench Verified instances with GPT-4o-mini and a LangGraph ReAct agent, 3 runs each: tokens 73,373 → 44,449 (**−39.4%**), tool calls 8.3 → 5.3, F1 0.40 in both arms. It needs an embedding API plus Milvus/Zilliz, and it was not tested in Claude Code. — [claude-context evaluation](https://github.com/zilliztech/claude-context/tree/master/evaluation)
- **ast-grep**: 16k stars, v0.51.0, active. The official plugin/skill ast-grep/agent-skill (= ast-grep/claude-skill, 893 stars, last commit Sept 2026) teaches Claude to write AST rules and requires the ast-grep CLI. There are no token measurements, and Claude often must be told explicitly to use it. — [agent-skill README](https://github.com/ast-grep/agent-skill); [search summary](https://skillselion.com/marketplace/ast-grep/agent-skill)

**Packers**
- **repomix** (29k stars, v1.18.1): `--compress` (Tree-sitter extraction of signatures), `--token-count-tree`, an `--mcp` server mode, and `--skill-generate`, which writes a Claude Agent Skill into `.claude/skills/<name>/`. The README gives no percentage claim. — [repomix README](https://github.com/yamadashy/repomix)
- **code2prompt** (7.7k stars, v4.2.0, last commit Sept 2026): CLI/TUI, Python SDK, MCP server, plus an agent skill. — [code2prompt README](https://github.com/mufeedvh/code2prompt)

**Tool search (now built in)**: Anthropic's example shows tool definitions shrinking from ~77K to ~8.7K tokens upfront (85%). Internal MCP evals improved accuracy from 49% → 74% (Opus 4) and 79.5% → 88.1% (Opus 4.5). — [Anthropic: Advanced tool use](https://www.anthropic.com/engineering/advanced-tool-use)

**DIY hooks (native, see Q3)**: a PreToolUse `updatedInput` can rewrite a command, e.g. to pipe test output through `grep FAIL | head -100`. A PostToolUse `updatedToolOutput` can replace any tool's output, provided the value matches the tool's output shape. — [Manage costs](https://code.claude.com/docs/en/costs); [Hooks](https://code.claude.com/docs/en/hooks)

### Inferences
- **Evidence ranking (most to least proven) for cutting cost in agentic Claude Code work:**
  1. Native levers: model and effort choice, cache hygiene, `/clear`, subagents (Q3).
  2. LSP on large typed codebases: small but positive, mainly better precision.
  3. Targeted hooks that filter known-noisy commands (test runners, logs): the mechanism is sound, but I found no independent benchmark.
  4. Semantic indexing and Serena: vendor-only evidence.
  5. Generic CLI-output compressors (RTK): ±5% net, can backfire through extra turns.
  6. Terse-output skills: ~8.5% of *output* tokens, which is a small share of the bill. "Answer concisely" captures most of it.
  7. Compressing your own prompts: counterproductive (Adobe).
- Why compressors underdeliver: cache reads are 94–98% of input *tokens* but only 26–30% of the *bill* (Quesma). Cutting tool output barely moves the expensive parts, which are fresh input, cache writes, output and thinking. Lossy output can also trigger extra turns that wipe out the gain.
- Star counts no longer signal measured value: the two most-starred tools in this space showed the weakest independent results.

### Gaps
- Both JetBrains primary posts (Parts 1–2) returned HTTP 403, so their figures come from secondary coverage. Part 3 was reported as in progress.
- No independent benchmark of Serena, claude-context, ast-grep skills, caveman "Read less", "Auto" or "Blocks" inside Claude Code was found.
- No independent RTK test on Opus 5.5 / Sonnet 5.5 was found.

## 3. Native Claude Code features that affect cost and speed

### Takeaway
The biggest proven savings are built in:
- **Pick the right model.** Sonnet 5.5 costs half of Opus 5.5, and Haiku 5.5 ≤100K costs 1/20 of Sonnet 5.5.
- **Use effort deliberately.** It defaults to medium on 5.5 models.
- **Keep the prompt cache warm and stable.** Don't change model, effort or MCP setup mid-task. Cache reads cost 0.05x of input on Opus/Sonnet 5.5.
- **Manage context.** `/clear` between tasks, `/compact` at natural breaks, `/rewind` instead of compacting a dead end.
- **Push verbose work into subagents running a cheaper model.** Note that built-in Explore runs on *Opus* for subscribers.
- **Keep base context small.** CLAUDE.md under 200 lines, specialised instructions in skills, MCP tools deferred via tool search, CLI tools preferred over MCP.
- **Use LSP plugins and output-filtering hooks.**

Fast mode costs 2x the Opus price for "up to 2.5x" speed.

### Cited Findings
**Model selection**
- Aliases: `default`, `best`, `fable`, `sonnet`, `opus`, `haiku`, `sonnet[1m]`, `opus[1m]`, `opusplan`. On the Anthropic API, `opus` = Opus 5.5, `sonnet` = Sonnet 5.5 and `haiku` = Haiku 5.5. `opusplan` "uses `opus` during plan mode, then switches to `sonnet` for execution". — [Model config](https://code.claude.com/docs/en/model-config)
- Docs advice: "Sonnet handles most coding tasks well and costs less than Opus. Reserve Opus for complex architectural decisions". Use `model: haiku` for simple subagent tasks. "Unexpectedly high spend … usually traces back to long sessions that were never cleared or to Opus left as the default model." — [Manage costs](https://code.claude.com/docs/en/costs)
- Each `opusplan` plan-mode toggle is a model switch and starts a fresh cache, as does a skill whose frontmatter names a different model. — [Prompt caching](https://code.claude.com/docs/en/prompt-caching)
- Anthropic's Thariq Shihipar: switching from Opus to Haiku 100K tokens into a conversation "costs more than letting Opus answer". For a cheaper model, hand off to a subagent instead. — [Lessons from building Claude Code: Prompt caching is everything (30 Apr 2026)](https://claude.dev/blog/lessons-from-building-claude-code-prompt-caching-is-everything/)
- Subagent model resolution order: per-invocation parameter > frontmatter `model` > `CLAUDE_CODE_SUBAGENT_MODEL` > main model (this order applies since v2.1.251). `CLAUDE_CODE_SUBAGENT_MODEL_FORCE=1` (v2.1.257+) forces one model on all subagents. — [Sub-agents](https://code.claude.com/docs/en/sub-agents)
- **Built-in Explore does not default to Haiku.** With a subscription, Console account or `ANTHROPIC_BASE_URL` gateway, it runs on the `opus` alias model. To use Haiku, define your own subagent named `Explore` with `model: haiku`. — [Sub-agents](https://code.claude.com/docs/en/sub-agents)
- Haiku 5.5 reprices the whole request (cache reads included) at the higher tier once the prompt exceeds 100K tokens. 4.6+ models other than Haiku 5.5 get the full 1M context at standard pricing. — [Pricing](https://platform.claude.com/docs/en/about-claude/pricing)

**Effort and thinking**
- Effort levels are low / medium / high / xhigh / max. The default is `medium` on Opus/Sonnet/Haiku 5.5, `xhigh` on Opus 4.7 and `high` elsewhere. Set it with `/effort`, `--effort`, `CLAUDE_CODE_EFFORT_LEVEL`, the `effortLevel` setting, or `effort` in skill/subagent frontmatter. — [Model config](https://code.claude.com/docs/en/model-config)
- Thinking tokens are billed as output, and the "default budget can be tens of thousands of tokens per request". Thinking cannot be turned off on Opus/Sonnet/Haiku 5.5 or Fable. `MAX_THINKING_TOKENS` only applies to fixed-budget models. — [Manage costs](https://code.claude.com/docs/en/costs)
- On Opus/Sonnet/Haiku 5.5 and Fable 5.1, with an API key or subscription, changing effort mid-session **keeps** the cache. On other models and providers it invalidates it. — [Prompt caching](https://code.claude.com/docs/en/prompt-caching)

**Fast mode**
- Opus is "up to 2.5x faster at a higher cost per token": $8/$40 per MTok on Opus 5.5 (2x standard), $10/$50 on Opus 5 and 4.8. It is a research preview, billed on subscriptions only via usage credits, and has a separate rate-limit pool that falls back to standard speed. — [Fast mode](https://code.claude.com/docs/en/fast-mode)
- The first fast-mode turn re-bills the whole context uncached at fast rates, so enable it at session start. It can be combined with lower effort for "maximum speed on straightforward tasks". — [Fast mode](https://code.claude.com/docs/en/fast-mode); [Prompt caching](https://code.claude.com/docs/en/prompt-caching)

**Prompt caching**
- The cache is a prefix match ordered system prompt and tools → CLAUDE.md/memory → conversation.
  - **Invalidates it:** switching model, changing effort (except the 5.5/Fable 5.1 case above), first fast-mode turn, connecting or removing an MCP server without tool search, enabling plugins that bring MCP servers, a bare tool deny without tool search, compaction, image pruning, upgrading Claude Code.
  - **Keeps it:** editing files, editing CLAUDE.md (which does not apply until `/clear` or `/compact`), permission-mode changes, output-style changes (v2.1.251+), skills, `/recap`, `/rewind`, spawning subagents.
  
  — [Prompt caching](https://code.claude.com/docs/en/prompt-caching)
- TTL by billing type:
  - Subscription within plan: 1 h for the main conversation.
  - Usage credits, API key or cloud provider: 5 min.
  - Subagents: 5 min, even on subscriptions.
  
  Override with `promptCacheTtl` / `CLAUDE_CODE_PROMPT_CACHE_TTL` and `subagentPromptCacheTtl` / `CLAUDE_CODE_SUBAGENT_PROMPT_CACHE_TTL` (v2.1.242+), or with `ENABLE_PROMPT_CACHING_1H` / `FORCE_PROMPT_CACHING_5M`. A 1 h cache write costs 2x input and a 5 min write 1.25x. — [Prompt caching](https://code.claude.com/docs/en/prompt-caching); [Pricing](https://platform.claude.com/docs/en/about-claude/pricing)
- Cache read multipliers: 0.1x input by default, **0.05x on Opus 5.5 and Sonnet 5.5**, 0.025x on Fable 5.1. — [Pricing](https://platform.claude.com/docs/en/about-claude/pricing)
- `/compact` while the cache is warm costs "a fraction of what the context size suggests". After a break longer than the TTL it reprocesses the full history uncached. `/clear` costs nothing. `/rewind` returns to an already-cached prefix. Idle compaction can be disabled with `idleCompaction: false` (v2.1.290+). — [Prompt caching](https://code.claude.com/docs/en/prompt-caching); [Manage costs](https://code.claude.com/docs/en/costs)
- Anthropic alerts on cache hit rate and "declare[s] SEVs" when it drops: "A few percentage points of cache miss rate can dramatically affect cost and latency". A cached compaction call costs about 1/10 of uncached input, and a summary is about 20K tokens. Plan mode and deferred tools were designed as tools specifically so the tool set never changes mid-session. — [Thariq Shihipar, 30 Apr 2026](https://claude.dev/blog/lessons-from-building-claude-code-prompt-caching-is-everything/)

**Context management and compaction**
- Auto-compaction:
  - Without a set window, Claude Code compacts at the model's context limit, about **967K tokens** on 1M-native models.
  - Configure it with `/autocompact`, the `autoCompactWindow` setting, `--autocompact` or `CLAUDE_CODE_AUTO_COMPACT_WINDOW` (range 100K–1M).
  - `CLAUDE_CODE_DISABLE_1M_CONTEXT=1` keeps sessions at 200K.
  
  — [Model config](https://code.claude.com/docs/en/model-config)
- Startup context in the docs' illustrative simulation:

  | Item | Tokens |
  |---|---|
  | System prompt | ~4,200 |
  | Auto memory | ~680 |
  | Environment info | ~280 |
  | Deferred MCP tool names | ~120 |
  | Skill descriptions | ~450 |
  | User CLAUDE.md | ~320 |
  | Project CLAUDE.md | ~1,800 |

  Typical file reads were 1–2.4K tokens each. A subagent's reads cost 0 in the main context and only its ~420-token summary returns. After compaction, Claude Code re-reads up to 5 recently modified files (files >5K tokens come back as a path only) and re-injects invoked skills (capped at 5K tokens per skill, 25K total). — [Context window](https://code.claude.com/docs/en/context-window)
- Context tools: `/btw` side questions never enter history. Rewind offers "Summarize from here" / "Summarize up to here". `/compact <focus>` and "Compact instructions" in CLAUDE.md steer what is kept. — [Best practices](https://code.claude.com/docs/en/best-practices); [Manage costs](https://code.claude.com/docs/en/costs)

**MCP and tools**
- MCP tool definitions are deferred by default: only names enter context until used. `ENABLE_TOOL_SEARCH=auto` loads schemas upfront if they fit in 10% of context; `=false` loads everything. — [Context window](https://code.claude.com/docs/en/context-window); [Manage costs](https://code.claude.com/docs/en/costs)
- CLI tools (`gh`, `aws`, `gcloud`, `sentry-cli`) "are still more context-efficient than MCP servers". Disable unused servers with `/mcp`. — [Manage costs](https://code.claude.com/docs/en/costs)
- MCP output limits: a warning above 10,000 tokens, a default cap of 25,000 (`MAX_MCP_OUTPUT_TOKENS`), and results over 50,000 characters are saved to a file and referenced by path. — [MCP](https://code.claude.com/docs/en/mcp)

**CLAUDE.md, skills, hooks, permissions**
- Keep CLAUDE.md "under 200 lines" and move workflow-specific instructions into skills, which load on demand. "Bloated CLAUDE.md files cause Claude to ignore your actual instructions". `/doctor` proposes cuts for content derivable from the code. — [Manage costs](https://code.claude.com/docs/en/costs); [Best practices](https://code.claude.com/docs/en/best-practices)
- Hooks:
  - Docs example: a log-filtering hook reduces context "from tens of thousands of tokens to hundreds", and a PreToolUse test filter returns only failures (`grep -A 5 -E '(FAIL|ERROR|error:)' | head -100`).
  - PostToolUse `updatedToolOutput` replaces any tool's output (the Bash shape is `{stdout, stderr, interrupted, isImage}`); telemetry still records the original.
  - Hook text output is capped at 10,000 characters; longer output is saved to a file with a 2,000-character preview.
  
  — [Manage costs](https://code.claude.com/docs/en/costs); [Hooks](https://code.claude.com/docs/en/hooks)
- `.claudeignore` "has no effect". Use `Read(./path/**)` deny rules to keep files out of context. — [Permissions](https://code.claude.com/docs/en/permissions)

**Multi-agent costs**
- Agent teams "use approximately 7x more tokens than standard sessions when teammates run in plan mode". Recommendations: Sonnet teammates, small teams, short spawn prompts. Teams are off by default (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`). — [Manage costs](https://code.claude.com/docs/en/costs)
- Hidden usage drivers: long context re-read every turn, cache misses after breaks, scheduled tasks and `/loop`, cross-session messages, goal check-ins (capped at 3), subagents and workflows, teammates, and compaction itself. — [Manage costs](https://code.claude.com/docs/en/costs)

### Inferences
- Concrete settings implied by the docs (not benchmarked):
  1. Make Sonnet 5.5 the default; switch to Opus or opusplan at the start of hard tasks, not mid-task.
  2. Override Explore with `model: haiku`, or set `CLAUDE_CODE_SUBAGENT_MODEL=haiku`, for read-only search on subscriptions. Haiku 5.5 is ~40x cheaper per input token than Opus 5.5 below 100K, but it reprices above 100K.
  3. Keep effort at medium and raise it per task.
  4. On API keys with bursty work, consider `promptCacheTtl: 1h` (a 1 h write costs 2x vs 1.25x for 5 min, but survives breaks).
  5. Lower `autoCompactWindow` to keep sessions from growing to ~967K, where every turn re-reads all history at the cache rate.
- opusplan only pays off when the plan and execution phases are each long: every toggle rebuilds the cache.
- Because Opus/Sonnet 5.5 cache reads are 0.05x of input, a warm, stable prefix matters more than ever. Avoid mid-session MCP or plugin changes and model switches.

### Gaps
- No official or independent measurement of the saving from opusplan, or of token use per effort level on 5.5 models, was found. Third-party pages conflict.
- Claude Code's automatic "clearing old tool results" is mentioned in the cost and cache docs but not specified here (thresholds, settings).
- I could not verify a built-in "concise" output style. Output styles are documented as cache-safe, but their effect on tokens is not quantified.

## 4. Responsiveness: fewer permission prompts, headless runs, background work, faster feedback

### Takeaway
The biggest responsiveness wins:
- **Auto mode**, the default starting mode in interactive sessions since v2.1.283 (Aug 2026 rollout).
- **OS sandboxing**, which cut Anthropic's internal prompts by 84%, plus allowlists.
- **Background subagents and commands**, `--bare` for scripts, and parallel sessions or worktrees.
- **Fast mode** when latency matters more than cost.

### Cited Findings
- Auto mode is the "built-in starting permission mode" for interactive terminal and VS Code sessions from v2.1.283; on earlier versions only on Pro/Max/Team. A classifier blocks "scope escalation, unknown infrastructure, or hostile-content-driven actions". — [Best practices](https://code.claude.com/docs/en/best-practices)
- Coverage of Anthropic's August 2026 announcement (secondary sources): — [devops.com](https://devops.com/anthropic-makes-claude-codes-auto-mode-the-default-betting-automation-beats-manual-review/); [The Register](https://www.theregister.com/a/5285326); [Implicator](https://www.implicator.ai/anthropic-claude-code-auto-mode-default/); [The New Stack](https://thenewstack.io/claude-code-auto-mode/)
  - Users approve ~97% of permission prompts.
  - In a 1,053-tester study, humans caught a disguised dangerous command ~13.6% of the time versus ~89% for auto mode.
  - Auto mode falls back to manual after 3 consecutive or 20 total blocks.
  - Implicator reports the pipeline missed 17% of 52 real overreach cases.
- Sandboxing "reduced permission prompts by 84%" in Anthropic's internal usage. — [Anthropic engineering: Claude Code sandboxing](https://www.anthropic.com/engineering/claude-code-sandboxing)
- With sandboxing on and `autoAllowBashIfSandboxed` at its default `true`, sandboxed Bash runs without prompting. Allow rules use prefix syntax such as `Bash(git diff *)` (the space before `*` matters). — [Permissions](https://code.claude.com/docs/en/permissions); [Headless](https://code.claude.com/docs/en/headless)
- Headless and CI:
  - `--bare` skips discovery of hooks, skills, plugins, MCP, memory and CLAUDE.md to "reduce startup time". It is "recommended … for scripted and SDK calls, and will become the default for `-p`". It needs `ANTHROPIC_API_KEY`.
  - `--permission-mode dontAsk|auto|acceptEdits`, `--permission-prompts none` (v2.1.259+) and `--max-budget-usd`.
  - Since v2.1.302, `-p` runs start in Manual mode when nothing sets a mode.
  
  — [Headless](https://code.claude.com/docs/en/headless)
- Background work: subagents spawned from the main conversation start in the background by default. Ctrl+B moves a running command or subagent to the background. Up to 20 subagents run concurrently by default (`CLAUDE_CODE_MAX_CONCURRENT_SUBAGENTS`). Forks inherit context and read the parent's cache. — [Sub-agents](https://code.claude.com/docs/en/sub-agents)
- Parallelism: worktrees, cross-session messaging, the desktop app, cloud sessions, `claude agents` (agent view), `/batch` (5–30 subagents in worktrees), and fan-out loops over `claude -p` with `--allowedTools`. — [Best practices](https://code.claude.com/docs/en/best-practices)
- Faster feedback loops, from the docs:
  - "Prefer running single tests, and not the whole test suite, for performance".
  - Give Claude a pass/fail check (tests, build, screenshot), or gate the stop with `/goal` or a Stop hook.
  - LSP plugins report type errors after edits "without running a compiler".
  
  — [Best practices](https://code.claude.com/docs/en/best-practices); [Manage costs](https://code.claude.com/docs/en/costs)
- Latency effects of caching: the first turn after the cache expires, and the turn after a model switch, are "noticeably slower". Fast mode and lower effort can be combined. — [Prompt caching](https://code.claude.com/docs/en/prompt-caching); [Fast mode](https://code.claude.com/docs/en/fast-mode)
- Hooks can run `async: true` in the background. Matching hooks run in parallel. The default command-hook timeout is 600 s. — [Hooks](https://code.claude.com/docs/en/hooks)

### Inferences
- For daily work: auto mode plus `/sandbox` plus a small project allowlist removes most interruptions. Use `dontAsk` with explicit `--allowedTools` and `--bare` for CI. Keep slow hooks async so they don't add latency to every tool call.
- Background subagents improve responsiveness but add token spend, and their 5-minute cache TTL means idle subagents lose their cache quickly.

### Gaps
- I did not fetch Anthropic's primary auto-mode engineering post. The approval-rate, tester-study and miss-rate figures come from press coverage.
- No independent measurement of auto mode's classifier latency or extra token overhead was found.
- Fast mode's "up to 2.5x" is a vendor claim, not independently measured.

## 5. Routing through proxies (claude-code-router, LiteLLM): when is it worth it, and what are the risks and terms-of-service issues?

### Takeaway
Routing Claude Code through a proxy can cut cost a lot by sending work to cheap non-Anthropic models. It is worth it mainly for API-key users doing bulk or background work, or for enterprises that need per-user spend tracking on cloud providers. It carries real penalties:
- **Terms of service:** using Claude Free/Pro/Max subscription credentials through third-party tools has been prohibited since February 2026 and enforced since April 2026.
- **Lost features:** a custom `ANTHROPIC_BASE_URL` disables MCP tool search, and a gateway that strips `cache_control` bills the whole history uncached on every turn.
- **Lower quality:** cheaper models pass fewer tasks.
- **Supply-chain risk:** shown by the LiteLLM compromise in March 2026.

### Cited Findings
- **claude-code-router (CCR)**: 38k stars, v3.1.3, commits in Oct 2026, MIT licence. It has become a "local model gateway and control plane" for Claude Code, Codex, Grok CLI, Kimi CLI, OpenCode and others. Features: retries, credential pools, key rotation, ordered fallback models, request logs with latency, tokens and cost. It supports the OpenAI, Gemini, OpenRouter, DeepSeek, Moonshot, Mistral, Z.AI and Bailian APIs. The README carries partner/affiliate links to third-party API resellers. — [CCR README](https://github.com/musistudio/claude-code-router)
- **LiteLLM**: 62k stars, v1.106.0, active. The Claude Code docs say "Several large enterprises reported using LiteLLM … to track spend by key" but that it "is unaffiliated with Anthropic and has not been audited for security". — [shields](https://img.shields.io/github/stars/BerriAI/litellm.json); [Manage costs](https://code.claude.com/docs/en/costs)
- **LiteLLM supply-chain attack:** on 24 Mar 2026 TeamPCP published malicious PyPI versions 1.82.7 and 1.82.8 containing a `.pth` credential stealer, live for about 2–5 hours. — [NetSPI](https://www.netspi.com/blog/executive-blog/ai-ml-pentesting/litellm-supply-chain-compromise/); [Comet](https://www.comet.com/site/blog/litellm-supply-chain-attack/)
- **Terms of service** (secondary sources; I did not fetch the primary terms):
  - In Feb 2026 Anthropic clarified that subscription OAuth tokens are only for Claude Code and Claude.ai. Third parties may not "use Free, Pro, or Max plan credentials to route requests on your behalf".
  - Technical checks started 9 Jan 2026, enforcement against third-party harnesses on 4 Apr 2026, and legal demands to OpenCode on 19 Mar 2026.
  - API-key authentication is the sanctioned path.
  
  — [Gigazine](https://gigazine.net/gsc_news/en/20260220-anthropic-third-party-block); [LetsDataScience](https://letsdatascience.com/news/anthropic-revises-terms-to-bar-third-party-harnesses-b7377cc7); [falcao.org](https://falcao.org/posts/anthropic-claude-access-crackdown-ecosystem-fallout/)
- **Technical costs of a custom base URL:**
  - Tool search is unavailable, so all MCP tool schemas load upfront and MCP changes invalidate the cache.
  - If a gateway "removes the markers while returning success: your entire conversation history bills as uncached input on every turn".
  - The 1-hour TTL needs the `anthropic-beta` header forwarded.
  - The fast-mode availability check goes directly to api.anthropic.com.
  
  — [Prompt caching](https://code.claude.com/docs/en/prompt-caching); [MCP](https://code.claude.com/docs/en/mcp); [Fast mode](https://code.claude.com/docs/en/fast-mode)
- **No router needed for some providers:** DeepSeek exposes an Anthropic-compatible endpoint (`ANTHROPIC_BASE_URL=https://api.deepseek.com/anthropic`).
  - Model mapping: `claude-opus*` → deepseek-v4-pro; `claude-sonnet*` / `claude-haiku*` → deepseek-flash.
  - Ignored or unsupported: `cache_control` and the thinking `budget_tokens` are ignored, `mcp_servers` is ignored, documents are unsupported.
  
  — [DeepSeek Anthropic API](https://api-docs.deepseek.com/guides/anthropic_api)
- **Measured cost/quality trade-off of a cheaper model** (different harnesses, so only indicative): on Terminal-Bench 2.1, Claude Code + Fable 5.0 passed 84% of tasks for $731 in total, versus OpenCode + DeepSeek V4 Pro at 71% for $51. — [Quesma](https://quesma.com/blog/does-rtk-make-ai-coding-cheaper/)
- Secondary price listing: DeepSeek V4-Flash at $0.14/$0.28 per MTok and V4-Pro at a promotional $0.435/$0.87. Sources conflict, so check official pages. — [search aggregate, fungies.io](https://fungies.io/llm-api-pricing-comparison-2026/)
- First-party alternatives for enterprise spend control: the self-hosted Claude apps gateway (per-user attribution and spend limits on Bedrock, Google Cloud and Foundry), workspace spend limits in the Console, and the `modelPricing` setting for reporting. — [Manage costs](https://code.claude.com/docs/en/costs)

### Inferences
- A router is worth considering when you (a) pay per API token, (b) can accept roughly 10–15 points lower pass rates on hard tasks, and (c) send bulk or background work (lint fixes, summaries, simple subagents) to cheap models.
- For subscription users it is not an option without violating the terms. For quality-critical work, native model and effort choices (Sonnet 5.5 or Haiku 5.5 subagents) keep caching and tool search, so they are the safer cost lever.
- If you do run a gateway, verify that it forwards `cache_control` and `anthropic-beta` (watch the `Prompt cache (main)` line in `/usage`). Pin versions with hash checks, given the LiteLLM incident.

### Gaps
- I did not fetch Anthropic's current Consumer Terms text, and I could not confirm whether the policy has changed since April 2026.
- No independent benchmark of CCR's own latency overhead, or of Claude Code quality when routed to GLM/Kimi/DeepSeek, was found.
- Z.AI/Moonshot Anthropic-compatible endpoint details were not verified.

## 6. What Anthropic officially recommends

### Takeaway
Anthropic's guidance rests on one idea: "the context window is the most important resource to manage". It recommends, in order:
1. Clear between tasks.
2. Pick the right model (Sonnet by default, Haiku for simple subagents).
3. Lower effort for simple work.
4. Keep CLAUDE.md under 200 lines and move the rest into skills.
5. Rely on deferred MCP tools and CLI tools.
6. Install LSP plugins.
7. Preprocess noisy output with hooks.
8. Delegate verbose work to subagents.
9. Write specific prompts, use plan mode for complex work, course-correct early.
10. Monitor with `/usage`, the statusline and OTel.

Internally, Anthropic treats the prompt-cache hit rate as a production metric.

### Cited Findings
- "Most best practices are based on one constraint: Claude's context window fills up fast, and performance degrades as it fills." — [Best practices](https://code.claude.com/docs/en/best-practices)
- The "Reduce token usage" list: `/clear` between tasks (with `/rename` first); custom `/compact` instructions; choose the model (Sonnet default, Opus for architecture, `model: haiku` for simple subagents); reduce MCP overhead (deferred by default, prefer CLIs, disable unused servers); code intelligence plugins; preprocess with hooks; move instructions from CLAUDE.md to skills ("Aim to keep CLAUDE.md under 200 lines"); adjust thinking and effort; delegate verbose operations to subagents; keep agent teams small; write specific prompts; plan mode; course-correct early (Esc, `/rewind`); give verification targets; test incrementally. — [Manage costs](https://code.claude.com/docs/en/costs)
- Session hygiene: "If you've corrected Claude more than twice on the same issue in one session … run `/clear` and start fresh". Named anti-patterns: the "kitchen sink session", "infinite exploration", and "over-specified CLAUDE.md". — [Best practices](https://code.claude.com/docs/en/best-practices)
- Cache tip: "Pick your model and effort level at the top of a session, then save `/compact` for natural breaks between tasks." — [Prompt caching](https://code.claude.com/docs/en/prompt-caching)
- Per-user TPM/RPM recommendations by team size (Console):

  | Team size | TPM per user | RPM per user |
  |---|---|---|
  | 1–5 users | 200k–300k | 5–7 |
  | 100–500 users | 15k–20k | 0.37–0.47 |
  | 500+ users | 10k–15k | 0.25–0.35 |

  — [Manage costs](https://code.claude.com/docs/en/costs)
- Design principles from Anthropic's Claude Code team: put static content first, deliver changing state as messages (`<system-reminder>`) rather than system-prompt edits, never add or remove tools mid-session, switch models through subagent hand-off, and fork compaction in a cache-safe way. — [Thariq Shihipar, 30 Apr 2026](https://claude.dev/blog/lessons-from-building-claude-code-prompt-caching-is-everything/)
- Permission guidance: use `/permissions` allowlists and `/sandbox`. Auto mode is the default from v2.1.283. Use `--permission-mode dontAsk` with `--allowedTools` for unattended fan-out. — [Best practices](https://code.claude.com/docs/en/best-practices)

### Inferences
- Anthropic's own list matches what the independent evidence supports: context and cache management, model and effort choice, subagents, LSP and targeted hooks. It does not endorse third-party compressors or terse-output skills. Teams should start with these native levers and measure via `/usage` and OTel before adding third-party tools.

### Gaps
- Anthropic publishes no quantified savings for most individual recommendations, apart from tool search (85% in one example), sandboxing (84% fewer prompts) and the agent-teams multiplier (~7x).
