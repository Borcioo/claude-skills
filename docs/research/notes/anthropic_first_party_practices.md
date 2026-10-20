# First-party Anthropic / Claude Code team practices for getting the most out of Claude Code (as of Oct 19, 2026)

Notes on sourcing:
- X/Twitter posts were not read directly. Boris Cherny's threads were read through the third-party mirror twitter-thread.com, which reproduces the thread text, and are marked "via mirror". Treat the wording as close paraphrase, not verified verbatim.
- Podcast content comes from a published transcript (Every) or from secondary summaries (WorkOS, rogerwong.me), and is marked as such.
- The docs at code.claude.com describe the Oct 2026 product. They mention Claude Code v2.1.2xx, Opus/Sonnet/Haiku 5.5 and the "Fable" models. Older posts refer to models and features that have since changed, and these are flagged as SUPERSEDED or REFINED.

## 1. Anthropic engineering blog and official posts: concrete recommendations

### Takeaway
Anthropic's official writing repeats one theme: context is the scarce resource, so keep it small and high-signal. It also says to give the agent a deterministic way to check its work and to separate generation from evaluation. Past that, use the simplest harness that works and remove scaffolding as models improve. The April 2025 "best practices" post has been folded into the docs and redirects there. 2026 posts add harness patterns (planner, generator and evaluator), large-scale parallelism (16 agents), auto mode, and a postmortem showing that effort defaults materially change quality.

### Cited Findings

**Index and dates.** The anthropic.com/engineering index lists these posts (newest first): "How we contain Claude across products" (May 25, 2026), "An update on recent Claude Code quality reports" (Apr 23, 2026), "Scaling Managed Agents" (Apr 8, 2026), "How we built Claude Code auto mode" (Mar 25, 2026), "Harness design for long-running application development" (Mar 24, 2026), "Building a C compiler with a team of parallel Claudes" (Feb 5, 2026), "Demystifying evals for AI agents" (Jan 9, 2026), "Effective harnesses for long-running agents" (Nov 26, 2025), "Introducing advanced tool use" (Nov 24, 2025), "Code execution with MCP" (Nov 4, 2025), "Beyond permission prompts" (sandboxing, Oct 20, 2025), "Equipping agents for the real world with Agent Skills" (Oct 16, 2025), "Effective context engineering for AI agents" (Sep 29, 2025), "Writing effective tools for agents — with agents" (Sep 11, 2025), "How we built our multi-agent research system" (Jun 13, 2025) and "Claude Code: Best practices for agentic coding" (Apr 18, 2025). An undated "Redesigning source control at Anthropic" is featured at the top. — [Anthropic Engineering index](https://www.anthropic.com/engineering)
- SUPERSEDED: the original "Claude Code: Best practices for agentic coding" URL now returns a 308 permanent redirect to the living docs page code.claude.com/docs/en/best-practices. Use the docs page (section 3) as the current version. — [anthropic.com/engineering/claude-code-best-practices → redirect](https://www.anthropic.com/engineering/claude-code-best-practices)

**Building effective agents (Erik Schluntz and Barry Zhang, Dec 19, 2024)**
- "Find the simplest solution possible, and only increasing complexity when needed". Workflows run on predefined code paths and agents direct themselves. The patterns, from simplest up, are: augmented LLM, prompt chaining, routing, parallelization (sectioning and voting), orchestrator-workers, evaluator-optimizer, and autonomous agents. — [Building effective agents](https://www.anthropic.com/engineering/building-effective-agents)
- Treat the agent-computer interface (ACI) like HCI. Write tool docs as if for a junior developer and apply poka-yoke ("Change the arguments so that it is harder to make mistakes"). For SWE-bench they "spent more time optimizing our tools than the overall prompt". Requiring absolute file paths removed a class of errors. Be wary of frameworks that hide prompts. The page now notes that much of the tooling described has changed. — [Building effective agents](https://www.anthropic.com/engineering/building-effective-agents)

**Writing effective tools for agents — with agents (Ken Aizawa et al., Sep 11, 2025)**
- Don't wrap every API endpoint. Build a few consolidated, high-impact tools, for example `search_contacts` instead of `list_contacts`, `schedule_event`, or `get_customer_context`. "Too many tools or overlapping tools can also distract agents." — [Writing tools for agents](https://www.anthropic.com/engineering/writing-tools-for-agents)
- Namespace tools by service and resource (`asana_search`, `asana_projects_search`). Return high-signal fields such as names instead of UUIDs. Offer a `response_format` enum (DETAILED or CONCISE; their example was 206 tokens versus 72). Paginate, filter and truncate. Write actionable error messages. "For Claude Code, we restrict tool responses to 25,000 tokens by default." — [Writing tools for agents](https://www.anthropic.com/engineering/writing-tools-for-agents)
- Workflow: prototype, write realistic evals that need dozens of tool calls with lenient verifiers, then paste the concatenated transcripts into Claude Code to refactor the tools. "Claude is an expert at analyzing transcripts and refactoring lots of tools all at once." Use held-out test sets. — [Writing tools for agents](https://www.anthropic.com/engineering/writing-tools-for-agents)

**Effective context engineering for AI agents (Applied AI team: Prithvi Rajasekaran, Ethan Dixon, Carly Ryan, Jeremy Hadfield; Sep 29, 2025)**
- Goal: "the smallest possible set of high-signal tokens that maximize the likelihood of some desired outcome." Pitch system prompts at the "right altitude", neither brittle if-else rules nor vague guidance. Start minimal on the best model and add instructions only for failures you observe. Prefer a few diverse canonical examples over lists of edge cases. — [Effective context engineering](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)
- Retrieve just in time: keep identifiers such as paths and queries, and load data through tools. Claude Code is the hybrid model: CLAUDE.md is loaded up front and glob/grep run on demand. Context rot, where recall falls as tokens grow, affects all models. — [Effective context engineering](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)
- Long-horizon techniques: compaction (Claude Code keeps the summary plus the 5 most recently accessed files; tune for recall first, then precision), clearing old tool results ("one of the safest lightest touch forms of compaction"), structured note-taking (NOTES.md or a todo list), and subagents. Each subagent may use tens of thousands of tokens but returns about 1,000–2,000 tokens to the lead. Overall advice: "do the simplest thing that works." — [Effective context engineering](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)

**Equipping agents with Agent Skills (Barry Zhang, Keith Lazuka, Mahesh Murag; Oct 16, 2025; updated Dec 18, 2025 when Skills became an open standard)**
- Progressive disclosure works in three levels: (1) the name and description are preloaded, (2) the SKILL.md body loads when relevant, (3) linked files load only when needed. The description decides triggering, so give it "special attention". Split SKILL.md when it becomes unwieldy, and keep rarely combined contexts in separate files. — [Agent Skills post](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills)
- Bundle deterministic scripts and make clear whether Claude should run them or read them. Develop skills against evals: run agents on real tasks, find the gaps, then build skills. Ask Claude to capture successes and mistakes into the skill. Install skills "only from trusted sources" and audit scripts and network calls. — [Agent Skills post](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills)

**Beyond permission prompts: sandboxing (David Dworken and Oliver Weller-Davies; Oct 20, 2025)**
- OS-level sandbox (bubblewrap on Linux, seatbelt on macOS) with filesystem isolation (read and write to the CWD only) and network isolation (a proxy with a domain allowlist). Both are needed. Internally it "safely reduces permission prompts by 84%." Enable with `/sandbox`. The runtime is open source (anthropic-experimental/sandbox-runtime). Keep git credentials and signing keys outside the sandbox. — [Sandboxing post](https://www.anthropic.com/engineering/claude-code-sandboxing)

**Code execution with MCP (Nov 4, 2025)**
- Present MCP tools as code files the agent explores on a filesystem and calls from code, rather than loading every definition. The example dropped from 150,000 to 2,000 tokens, a 98.7% saving. — [Code execution with MCP](https://www.anthropic.com/engineering/code-execution-with-mcp) (figure confirmed via search snippet of the page). An independent benchmark found a smaller 77.4% reduction — [AIMultiple](https://aimultiple.com/tr/code-execution-with-mcp)

**Introducing advanced tool use (Bin Wu et al., Nov 24, 2025)**
- A typical 5-server MCP setup costs about 55K tokens (58 tools). GitHub alone is about 26K for 35 tools, Slack about 21K, and Jira about 17K. Anthropic has seen 134K tokens of tool definitions before optimization. With the Tool Search Tool this drops to about 8.7K (−85%). MCP-eval accuracy rose from 49% to 74% on Opus 4 and from 79.5% to 88.1% on Opus 4.5. Use it when definitions exceed about 10K tokens or there are 10+ tools. — [Advanced tool use](https://www.anthropic.com/engineering/advanced-tool-use)
- Programmatic tool calling cut tokens 37% (43,588 to 27,297). Tool-use examples (1–5 per tool) raised complex-parameter accuracy from 72% to 90%. — [Advanced tool use](https://www.anthropic.com/engineering/advanced-tool-use)

**Effective harnesses for long-running agents (Justin Young; Nov 26, 2025; Opus 4.5)**
- Use two prompts on the same system prompt and tools. An initializer agent creates `init.sh`, `claude-progress.txt`, an initial git commit, and a JSON feature list (200+ features in the claude.ai-clone example, all `"passes": false`). JSON is used because the model is less likely to overwrite it than Markdown. Each later coding session does one feature, commits, and updates progress. "It is unacceptable to remove or edit tests". — [Effective harnesses](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)
- Session start routine: `pwd`, read the git log and progress file, pick the highest-priority failing feature, run `init.sh` plus a basic end-to-end test. Test "as a human user would" with browser automation (Puppeteer MCP). The fixes target premature "done", features marked passing too early, and wasted startup time. — [Effective harnesses](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)

**Building a C compiler with a team of parallel Claudes (Nicholas Carlini; Feb 5, 2026)**
- 16 parallel Opus 4.6 agents ran about 2,000 Claude Code sessions over 2 weeks and produced a ~100K-line Rust C compiler that builds Linux 6.9. Cost was about 2B input and 140M output tokens, just under $20,000. — [C compiler post](https://www.anthropic.com/engineering/building-c-compiler)
- Harness: a bash `while true` loop in Docker ("Run this in a container, not your actual machine"), a bare git upstream, and task locks taken by writing files to `current_tasks/`. There was no orchestrator agent. — [C compiler post](https://www.anthropic.com/engineering/building-c-compiler)
- Test and context hygiene: "the task verifier is nearly perfect, otherwise Claude will solve the wrong problem". Print only a few lines and log to files. Put `ERROR` and the reason on the same line so it's greppable. Precompute summary statistics. Offer a `--fast` 1%/10% deterministic-per-agent random test sample to work around time blindness. Keep READMEs and progress files updated. Add CI once regressions appear. — [C compiler post](https://www.anthropic.com/engineering/building-c-compiler)
- Parallelism fails when there is one monolithic task ("16 agents… each was stuck solving the same task"). The fix was a known-good oracle (GCC) plus random partitioning and delta debugging. Specialized roles were used for dedup, performance, code quality, Rust-idiom critique, and docs. Caution: "it is easy to see tests pass and assume the job is done, when this is rarely the case." — [C compiler post](https://www.anthropic.com/engineering/building-c-compiler)

**Harness design for long-running application development (Prithvi Rajasekaran, Anthropic Labs; Mar 24, 2026)**
- A planner turns a 1–4 sentence prompt into a high-level spec, a generator builds, and an evaluator uses Playwright MCP to click through the running app against weighted criteria. Separating evaluator from generator matters because self-evaluation is lenient ("agents praised mediocre work"). Tune the evaluator toward skepticism with few-shot score calibration. — [Harness design](https://www.anthropic.com/engineering/harness-design-long-running-apps)
- Cost and time: a retro game maker took 20 min and $9 solo versus 6 h and $200 with the full harness (Opus 4.5). A DAW took 3 h 50 min and $124.70 with the V2 harness (Opus 4.6). — [Harness design](https://www.anthropic.com/engineering/harness-design-long-running-apps)
- Model-specific changes: Sonnet 4.5 showed "context anxiety", so context resets with structured handoffs were needed. Opus 4.5 largely removed this and SDK auto-compaction was enough. Opus 4.6 removed the need for sprints, and the evaluator became a single final pass. Recommendation: re-examine the harness with each model and remove non-load-bearing components one at a time. Treat the evaluator as a conditional cost. — [Harness design](https://www.anthropic.com/engineering/harness-design-long-running-apps)

**How we built Claude Code auto mode (John Hughes; Mar 25, 2026)**
- Users approve 93% of permission prompts, which is approval fatigue. Auto mode uses a server-side prompt-injection probe on tool outputs and a two-stage transcript classifier (Sonnet 4.6) that cannot see the agent's reasoning. Read-only tools and in-project edits skip it. — [Auto mode post](https://www.anthropic.com/engineering/claude-code-auto-mode)
- Measured: full pipeline false-positive rate 0.4%, false-negative rate 17% on real overeager actions and 5.7% on synthetic exfiltration. It escalates to a human after 3 consecutive or 20 total denials. Anthropic calls `--dangerously-skip-permissions` unsafe in most situations. Use auto mode for long autonomous tasks, a sandbox for strong isolation, and careful human review for high-stakes infrastructure. Start from `claude auto-mode defaults`. — [Auto mode post](https://www.anthropic.com/engineering/claude-code-auto-mode)

**An update on recent Claude Code quality reports (postmortem; Apr 23, 2026)**
- Three product-layer changes degraded quality. (1) The default effort was lowered from high to medium (Mar 4–Apr 7) to reduce latency and was reverted. (2) A caching bug dropped reasoning history on every turn (Mar 26–Apr 10, fixed in v2.1.101). (3) A verbosity-limiting system-prompt line cost 3% on an eval (Apr 16–20). After the fix, the default effort was xhigh for Opus 4.7 and high for other models. Usage limits were reset, and future system-prompt changes get per-model evals, ablations and gradual rollouts. Users can pick effort per task with `/effort` and report problems with `/feedback`. — [April 23 postmortem](https://www.anthropic.com/engineering/april-23-postmortem)

**Lessons from building Claude Code: Prompt caching is everything (Thariq Shihipar; Apr 30, 2026; claude.com blog, now served from claude.dev)**
- Claude Code alerts on cache hit rate and declares SEVs when it drops. Prompt order is static system prompt and tools, then CLAUDE.md, then session context, then messages. "Any change anywhere in the prefix invalidates everything after it." — [Prompt caching post](https://claude.dev/blog/lessons-from-building-claude-code-prompt-caching-is-everything/)
- Rules: pass updates through messages (`<system-reminder>`), not system-prompt edits. Don't switch models mid-session; at 100K tokens, switching Opus to Haiku for an easy question costs more than staying, so use a subagent hand-off instead. Don't add or remove tools mid-session. Plan mode is implemented as `EnterPlanMode`/`ExitPlanMode` tools for this reason, and MCP tools are sent as `defer_loading` stubs. Compaction uses cache-safe forking, which costs about one-tenth and produces a summary of about 20K tokens. — [Prompt caching post](https://claude.dev/blog/lessons-from-building-claude-code-prompt-caching-is-everything/)

**How Anthropic secures its AI-native SDLC (Jason Clinton, Deputy CISO; Jul 21, 2026)**
- Internal metrics: engineers ship about 8x as much code per quarter as in 2021–2025. Claude authors about 80% of merged code. "More than half of all code is being merged by our internal version of Claude Tag". PRs with substantive review comments rose from 16% to 54%. — [Anthropic SDLC post](https://claude.com/blog/how-anthropic-secures-its-ai-native-software-development-lifecycle)
- Practices:
  - Secure-coding guidance lives in CLAUDE.md and org-wide skills ("Once an agent discovers a bug class, the relevant file is updated").
  - Claude runs `/security-review` before opening a PR, and a security-guidance plugin reviews code during generation.
  - Developers work on remote VMs with egress allowlists.
  - Multiple narrow review agents (with RAG over past incidents) must prove their findings.
  - Codebases are risk-tiered with strict human approval.
  - The hard gate sits at CI, not in a PreToolUse hook.
  - Each agent gets a single-purpose identity with minimum permissions. For example, the monitoring agent can only write docs, post in channels and read prod logs, and cannot deploy.
  - New AI reviewers run in shadow mode first.

  — [Anthropic SDLC post](https://claude.com/blog/how-anthropic-secures-its-ai-native-software-development-lifecycle)

**"How Anthropic teams use Claude Code" (blog Jul 24, 2025; PDF report created Jun 2025)**
- The blog summary covers 3x faster production debugging in Security, 80% less research time in Inference (1 h → 10–20 min), and a two-subagent Google Ads workflow in Growth Marketing generating hundreds of ads in minutes. Cross-team tips: keep context in CLAUDE.md, connect tools through MCP, and feed in stack traces and screenshots. — [claude.com blog](https://claude.com/blog/how-anthropic-teams-use-claude-code)
- Claude Code product team (from the PDF): auto-accept mode (Shift+Tab) with autonomous loops (write code, run tests, iterate). "Start from a clean git state and committing checkpoints regularly". Vim mode was built with "roughly 70%" of the final code from Claude's autonomous work. Core business logic is done synchronously with detailed prompts, and "abstract tasks on the product's edges" go to auto-accept. Tip: "Create self-sufficient loops… especially effective when you ask Claude to generate tests before writing code." — [PDF report](https://www-cdn.anthropic.com/58284b19e702b49db9302d5b6f135ad8871e7658.pdf)
- Data Science and ML team: "Treat it like a slot machine. Save your state before letting Claude work, let it run for 30 minutes, then either accept the result or start fresh… Starting over often has a higher success rate than trying to fix Claude's mistakes." Also: interrupt and ask "why are you doing this? Try something simpler." (the model tends toward complex solutions). They reported 2–4x time savings on refactors. — [PDF report](https://www-cdn.anthropic.com/58284b19e702b49db9302d5b6f135ad8871e7658.pdf)
- RL Engineering: "Try one-shot first, then collaborate… If it works (about one-third of the time), you've saved significant time." Use a checkpoint-heavy commit workflow. Add CLAUDE.md lines for repeated tool mistakes ("run pytest not run and don't cd unnecessarily - just use the right path"). — [PDF report](https://www-cdn.anthropic.com/58284b19e702b49db9302d5b6f135ad8871e7658.pdf)
- Security Engineering accounts for 50% of all custom slash-command implementations in the monorepo. Their tip is "Let Claude talk first": tell it to "commit your work as you go" and check in periodically. They do TDD via pseudocode. Data Infrastructure: write detailed CLAUDE.md files, and "Use MCP servers instead of CLI for sensitive data" (better access control and logging than the bq CLI). They also run end-of-session prompts that update CLAUDE.md. — [PDF report](https://www-cdn.anthropic.com/58284b19e702b49db9302d5b6f135ad8871e7658.pdf)

### Inferences
- The "verify, then separate generator from evaluator" idea recurs across posts written 15 months apart: Building effective agents' evaluator-optimizer, the effective-harnesses feature list, Carlini's "nearly perfect verifier", the planner/generator/evaluator harness, and the SDLC post's agents that must prove their findings. It is the most robust first-party principle.
- Anthropic explicitly prunes harnesses as models improve: Boris "deletes a bunch of code" each release, and the harness post removed resets and then sprints. Team practices built around a 2025 model (context resets, heavy scaffolding) should be re-tested on current models rather than copied.

### Gaps
- Not fetched or read: "Demystifying evals for AI agents" (Jan 9, 2026), "Scaling Managed Agents" (Apr 8, 2026), "How we contain Claude across products" (May 25, 2026), "Redesigning source control at Anthropic" (undated), "How we built our multi-agent research system" (Jun 2025), and the Claude Agent SDK launch post. Their recommendations are not covered here.
- The PDF "How Anthropic teams use Claude Code" was OCR text; quotes were extracted from the OCR layer and may contain minor OCR artifacts.

## 2. Claude Code team members' personal workflows (Boris Cherny, Cat Wu, Thariq Shihipar, Sid Bidasaria, others)

### Takeaway
The creators run many sessions in parallel: Boris runs 5 local plus 5–10 web sessions, and the team recommends 3–5 worktrees. They start non-trivial work in plan mode. They encode every repeated workflow as a checked-in slash command or skill and every mistake as a CLAUDE.md line, often added during PR review with @claude. They rely on hooks and subagents for formatting, simplification and verification. They pre-allow safe commands, now mostly through auto mode, instead of skipping permissions. Above all, they give Claude a way to verify its work, which Boris says yields "2-3x" quality. By mid-2026 Boris describes moving from prompting to running loops.

### Cited Findings

**Boris Cherny: "my setup" thread, Jan 2, 2026 (via mirror)**
- Runs 5 Claudes in numbered terminal tabs 1–5 with system notifications when one needs input, plus 5–10 on claude.ai/code. He hands off and "teleports" sessions between local and web, and starts sessions from the iOS app. — [Boris thread Jan 2, 2026 (twitter-thread.com mirror)](https://twitter-thread.com/t/2007179832300581177); press coverage: [VentureBeat](https://venturebeat.com/technology/the-creator-of-claude-code-just-revealed-his-workflow-and-developers-are), [Slashdot](https://developers.slashdot.org/story/26/01/06/2239243/creator-of-claude-code-reveals-his-workflow)
- Model: "Opus 4.5 with thinking for everything". It is slower than Sonnet but needs less steering and is better at tool use, so it is faster overall. — [mirror](https://twitter-thread.com/t/2007179832300581177)
- The team keeps one shared, git-checked CLAUDE.md per repo and adds a line whenever Claude errs. In PR review he tags @.claude on coworkers' PRs to add CLAUDE.md entries through the Claude Code GitHub Action, calling it "our version of Compounding Engineering" (after Dan Shipper). — [mirror](https://twitter-thread.com/t/2007179832300581177)
- Most sessions start in plan mode (Shift+Tab twice). He iterates on the plan, then switches to auto-accept edits, and Claude usually one-shots the implementation. — [mirror](https://twitter-thread.com/t/2007179832300581177)
- Slash commands live in `.claude/commands/` and are checked into git. `/commit-push-pr` runs "dozens of times a day" and uses inline bash to pre-compute git status. — [mirror](https://twitter-thread.com/t/2007179832300581177)
- Subagents: `code-simplifier` (cleans up after Claude finishes) and `verify-app` (end-to-end testing instructions). A PostToolUse hook formats code so CI doesn't fail on formatting. — [mirror](https://twitter-thread.com/t/2007179832300581177)
- Permissions: no `--dangerously-skip-permissions`. He uses `/permissions` to pre-allow safe bash commands, shared through `.claude/settings.json`. The Slack MCP config is shared through `.mcp.json`. Claude also uses the `bq` CLI and Sentry logs. — [mirror](https://twitter-thread.com/t/2007179832300581177)
- Long tasks use one of three approaches: a background verification agent, an agent Stop hook, or the ralph-wiggum plugin. Inside sandboxes he uses `--permission-mode=dontAsk` or skip-permissions. — [mirror](https://twitter-thread.com/t/2007179832300581177)
- "Most important" tip: give Claude a way to verify its work, which improves results "2-3x". Claude tests every claude.ai/code change in the browser through the Claude Chrome extension. — [mirror](https://twitter-thread.com/t/2007179832300581177)

**Boris Cherny: "tips sourced from the Claude Code team" thread, Jan 31, 2026 (via mirror)**
- The team's #1 productivity gain is running 3–5 git worktrees, each with its own Claude. Boris uses multiple git checkouts instead. People name worktrees and set shell aliases to hop between them. — [Boris team-tips thread (mirror)](https://twitter-thread.com/t/2017742741636321619)
- Planning: one Claude writes the plan and another reviews it. When things go sideways, return to plan mode rather than push on. Use plan mode for verification steps too. — [mirror](https://twitter-thread.com/t/2017742741636321619)
- After every correction: "update your CLAUDE.md so you don't make that mistake again". Keep iterating until the mistake rate drops. — [mirror](https://twitter-thread.com/t/2017742741636321619)
- Anything done more than once a day becomes a skill or command committed to git. Examples include an end-of-session tech-debt command, a command that gathers a week of updates from several tools into one context, and data-modeling and test agents. — [mirror](https://twitter-thread.com/t/2017742741636321619)
- Bugs: paste a Slack bug thread and say "fix", or "go fix the failing CI tests" without micromanaging. Use docker logs for distributed systems. — [mirror](https://twitter-thread.com/t/2017742741636321619)
- Prompting patterns (paraphrased by the mirror): have Claude review your changes and hold off on the PR until it is satisfied; ask it to prove a feature works by comparing behavior against main; after a mediocre fix, ask it to scrap that and implement a cleaner solution; write detailed specs to reduce ambiguity. — [mirror](https://twitter-thread.com/t/2017742741636321619)
- Terminal: Ghostty, `/statusline` showing context usage and git branch, colour-coded and named tabs (one per worktree), and voice dictation for richer prompts. — [mirror](https://twitter-thread.com/t/2017742741636321619)
- Add "use subagents" to throw more compute at a problem. Route permission requests through a hook to a model that screens for attacks and auto-approves safe ones (a precursor of auto mode). The team keeps a checked-in BigQuery skill. Learning features: the Explanatory/Learning output styles, HTML presentations, ASCII diagrams, and a spaced-repetition skill. — [mirror](https://twitter-thread.com/t/2017742741636321619)

**Boris Cherny: Opus 4.7 tips thread, Apr 16, 2026 (via mirror)**
- Auto mode means no permission prompts, so more Claudes can run in parallel (Shift+Tab, or the Desktop/VS Code dropdown). `/fewer-permission-prompts` scans history for safe commands to allowlist. Recaps summarize what an agent did and what's next. `/focus` hides intermediate work. — [Boris Opus 4.7 thread (mirror)](https://twitter-thread.com/t/2044847848035156457); [Threads copy of recaps tip](https://www.threads.com/@boris_cherny/post/DXM_AWWD1QZ/recaps-we-shipped-recaps-earlier-this-week-to-prep-for-opus-recaps-are-short)
- Effort: Opus 4.7 uses adaptive thinking, so tune it with `/effort`. Boris uses **xhigh for most tasks and max for the hardest**; max applies to the current session only. Verification is "more important than ever" with 4.7: backend means start the server and test end to end, frontend uses the Chrome extension, and desktop apps use computer use. His `/go` skill tests end to end, runs `/simplify`, and opens a PR. — [mirror](https://twitter-thread.com/t/2044847848035156457)

**Boris Cherny and Cat Wu: Every "AI & I" podcast, Oct 29, 2025 (transcript)**
- Boris: plan mode can "two, three X success rates pretty easily if you align on the plan first". He says the biggest new-user mistake is "not using plan mode enough". Throwaway prototypes: let Claude build a rough version, then rewind (double-Esc) and "do it again". — [Every transcript](https://every.to/podcast/transcript-how-to-use-claude-code-like-the-people-who-built-it)
- Cat: ask Claude to interview you ("Please ask me questions. If there's anything you're unsure about…"). Hooks "insert a bit of determinism at pretty much any step". She built a Playwright subagent for frontend testing. Top MCPs she named: Puppeteer/Playwright, Sentry, Asana. — [Every transcript](https://every.to/podcast/transcript-how-to-use-claude-code-like-the-people-who-built-it)
- Boris: "Claude does all of our code review internally at Anthropic" (a human still approves). "Close to 100 percent of our tests are just written by Claude". Lint rules are 100% Claude-written. Review subagents are fanned out (CLAUDE.md compliance, git history, bugs, then false-positive filter agents) because "uncorrelated context windows" give better results. — [Every transcript](https://every.to/podcast/transcript-how-to-use-claude-code-like-the-people-who-built-it)
- Sid Bidasaria built `/feature-dev` (spec, plan, todo, step-by-step implementation). `/commit` commands can pre-allow tools and run on Haiku. Teams should check in settings.json to pre-allow and deny commands. Boris personally uses skip-permissions but says "we don't recommend it". Some engineers have Claude write a diary after each task and synthesize patterns from the diaries. Cat says about 70–80% of technical Anthropic employees use Claude Code daily. — [Every transcript](https://every.to/podcast/transcript-how-to-use-claude-code-like-the-people-who-built-it)

**Thariq Shihipar (Claude Code team): "How we use skills", Mar 17, 2026 (X article, read via gist mirror)**
- Anthropic runs "hundreds" of internal skills in 9 categories: library/API reference, product verification, data fetching and analysis, business process automation, code scaffolding, code quality and review, CI/CD and deployment, runbooks, and infrastructure ops. — [gist mirror of Thariq's post](https://gist.github.com/Danm72/467f6d6cd193d19c0042371866d53b75); [original on X](https://x.com/trq212/status/2033949937936085378)
- Writing tips:
  - Don't state the obvious ("A skill that restates what Claude would do by default adds context without adding value").
  - Build a Gotchas section from real failures.
  - Use progressive disclosure through files.
  - Avoid railroading with rigid step scripts.
  - Store setup and config in config.json.
  - Write the description as a trigger condition for the model.
  - Persist data in `${CLAUDE_PLUGIN_DATA}`.
  - Ship helper scripts.
  - Use on-demand hooks that only activate with the skill, for example blocking destructive commands in a prod skill.
  - "It can be worth having an engineer spend a week just making your verification skills excellent."

  — [gist mirror](https://gist.github.com/Danm72/467f6d6cd193d19c0042371866d53b75); [DEV summary](https://dev.to/minatoplanb/how-anthropic-actually-uses-skills-in-claude-code-a-9-category-framework-1kel)
- Distribution: `.claude/skills` in the repo for small teams. An internal plugin marketplace at scale, where skills move from sandbox to marketplace PR once they gain traction. A PreToolUse hook logs skill usage to find popular and under-triggering skills. — [gist mirror](https://gist.github.com/Danm72/467f6d6cd193d19c0042371866d53b75)

**Team-level facts (Pragmatic Engineer, Sep 23, 2025)**
- About 90% of Claude Code is written by Claude Code (Boris's estimate). 60–100 internal releases and about 1 external release per day. About 5 PRs per engineer per day. Boris built about 20 prototypes of the todo-list feature in 2 days. The stack was chosen to be "on distribution" for Claude (TypeScript, React/Ink, Bun). The system prompt was cut by about half with the 4.0 models. "Every time there's a new model release, we delete a bunch of code." — [Pragmatic Engineer: How Claude Code is built](https://newsletter.pragmaticengineer.com/p/how-claude-code-is-built)

**Later interviews (secondary summaries)**
- Lenny's Podcast (Feb 2026), via a blog quoting the episode. Boris: "I think at this point it's safe to say that coding is largely solved"; "On the Claude Code team, everyone codes"; "Our designers largely code." — [rogerwong.me summary (secondary)](https://rogerwong.me/2026/02/what-happens-after-coding-is-solved-boris-cherny)
- Acquired Unplugged, per a WorkOS summary dated Jun 2, 2026 (paraphrase). Boris no longer prompts Claude directly and instead writes loops that prompt Claude and decide what to build next. He runs "several hundred" Claude instances that scan user feedback, GitHub issues and Slack for ideas. He uninstalled his IDE. Per-engineer merges per day at Anthropic rose 200%. — [WorkOS takeaways (secondary)](https://workos.com/blog/boris-cherny-claude-code-acquired-interview-takeaways)

### Inferences
- The creators' workflows are the docs' recommendations applied with high intensity: plan, then auto-accept or auto mode, then verify, with everything codified as commands, skills, hooks or CLAUDE.md lines. Boris's distinctive habits are checked-in shared config, CLAUDE.md updates made during PR review, a post-task simplifier subagent, and a Stop hook or background agent for verification. A team can copy these directly.
- Boris's personal model and effort choices (top model, xhigh) are more expensive than the docs' cost advice (see section 5). They reflect an Anthropic-internal cost profile.

### Gaps
- No primary transcripts found for Code with Claude talks, AI Engineer talks, or Latent Space episodes with the team. No concrete personal-workflow statements found from Adam Wolff, Alex Albert or Erik Schluntz beyond Erik co-authoring "Building effective agents". Cat Wu's "3 best tips" (Peter Yang podcast) are paywalled — [Behind the Craft](https://creatoreconomy.so/p/inside-claude-code-how-an-ai-native-actually-works-cat-wu).
- The Startup School talk "We Cut 80% of Claude Code's Prompt" was found only as a YouTube title ([YouTube](https://www.youtube.com/watch?v=qyPCVqFUyDo)); content not verified.
- The X threads could not be read on x.com. The wording comes from the twitter-thread.com mirror.

## 3. Anthropic docs (code.claude.com) best-practice content, current as of Oct 2026

### Takeaway
The docs frame everything around one constraint ("the context window is the most important resource to manage") and one high-leverage habit ("Give Claude a check it can run"). The current docs add newer mechanisms: `/goal`, Stop-hook gates, verification subagents, auto mode as the default permission mode (v2.1.283+), deferred MCP tools, CLAUDE.md under 200 lines with path-scoped rules and skills for the rest, `/batch` fan-out, and agent teams for 3–5 teammates.

### Cited Findings

**Best practices page**
- Verification ladder: (1) ask Claude to run the check and iterate in the prompt; (2) set a `/goal` condition that a separate evaluator re-checks after each turn; (3) a Stop hook that blocks the turn from ending until a script passes; (4) a verification subagent or dynamic workflow that tries to refute the result. "Have Claude show evidence rather than asserting success". Run `/verify` yourself after Claude's check passes. — [Best practices](https://code.claude.com/docs/en/best-practices)
- Explore, then plan, then implement, then commit. Use plan mode (Shift+Tab or `--permission-mode plan`) and Ctrl+G to edit the plan. Skip planning when "you could describe the diff in one sentence". For larger features: "Interview me in detail using the AskUserQuestion tool… then write a complete spec to SPEC.md", then start a fresh session to implement. Good specs name files and interfaces, list what is out of scope, and end with an end-to-end verification step. — [Best practices](https://code.claude.com/docs/en/best-practices)
- CLAUDE.md: for each line ask "Would removing this cause Claude to make mistakes?" Include commands, non-default style, test runners, repo etiquette, env quirks and gotchas. Exclude anything inferable from code, standard conventions, API docs, file-by-file descriptions and "write clean code". Use "IMPORTANT" on one line only ("If you emphasize many lines, none of them stands out"). `/doctor` proposes cuts. Domain knowledge needed only sometimes belongs in skills. — [Best practices](https://code.claude.com/docs/en/best-practices)
- Session hygiene: Esc to stop, Esc+Esc or `/rewind`, `/clear` between tasks. "If you've corrected Claude more than twice on the same issue… run /clear and start fresh". `/compact <instructions>`. "Summarize from here" on a checkpoint. `/btw` for side questions that never enter history. Name sessions with `/rename` and treat them like branches. — [Best practices](https://code.claude.com/docs/en/best-practices)
- Tooling: prefer CLIs (`gh`, `aws`, `gcloud`, `sentry-cli`) as "the most context-efficient way". Hooks for "actions that must happen every time with zero exceptions". Install code-intelligence (LSP) plugins for typed languages. — [Best practices](https://code.claude.com/docs/en/best-practices)
- Scale: worktrees, cross-session messaging, Desktop, cloud sessions, agent view (`claude agents`, research preview), and agent teams (experimental). Writer/Reviewer pattern across two sessions. `/batch <instruction>` splits work across 5–30 subagents, each in its own worktree. Script fan-out with `claude -p … --allowedTools "Edit,Bash(git commit *)" --permission-mode dontAsk`, testing on 2–3 files first. — [Best practices](https://code.claude.com/docs/en/best-practices)
- Adversarial review: use a subagent to check the diff against PLAN.md. Warning: "A reviewer prompted to find gaps will usually report some, even when the work is sound… Chasing every finding leads to over-engineering". Tell it to flag only correctness and requirement gaps. — [Best practices](https://code.claude.com/docs/en/best-practices)
- Named failure patterns: the kitchen-sink session, correcting over and over, the over-specified CLAUDE.md, the trust-then-verify gap, and infinite exploration. — [Best practices](https://code.claude.com/docs/en/best-practices)
- Permissions: from v2.1.283, auto mode is the built-in starting mode for interactive terminal and VS Code sessions. Use `/permissions` allowlists and `/sandbox` to reduce prompts further. — [Best practices](https://code.claude.com/docs/en/best-practices)

**Memory page (CLAUDE.md)**
- "Size: target under 200 lines per CLAUDE.md file. Longer files consume more context and reduce adherence." Imports (`@path`) "don't reduce its context cost". Use `.claude/rules/*.md` with `paths:` frontmatter for path-scoped rules that load only on matching files. CLAUDE.md is "context, not enforced configuration"; to block an action use a PreToolUse hook. — [Memory docs](https://code.claude.com/docs/en/memory)
- When to add a line: Claude makes the same mistake twice; code review catches something Claude should have known; you type the same correction as last session; a new teammate would need it. Write verifiable instructions ("Run `npm test` before committing", not "Test your changes"). Audit contradictions with `/doctor prompt-audit` (v2.1.283+). Auto memory loads the first 200 lines or 25KB. AGENTS.md is read if there's no CLAUDE.md. — [Memory docs](https://code.claude.com/docs/en/memory)

**Costs page**
- Enterprise average is about $13 per developer per active day and $150–250 per developer per month, with 90% of users under $30 per active day. Per-user TPM recommendations range from 200–300K for teams of 1–5 down to 10–15K for 500+ users. — [Costs docs](https://code.claude.com/docs/en/costs)
- Cost habits:
  - "Sonnet handles most coding tasks well… Reserve Opus for complex architectural decisions".
  - Use `model: haiku` for simple subagents.
  - MCP tool definitions are "deferred by default", but CLIs "are still more context-efficient".
  - Keep CLAUDE.md under 200 lines by moving workflows to skills.
  - Use a PreToolUse hook to filter test output to failures only.
  - Agent teams use "approximately 7x more tokens than standard sessions when teammates run in plan mode".
  - Cache TTL is 1 h on a subscription and 5 min on API by default.
  - `/clear` costs nothing, while `/compact` is itself a large request.
  - `/insights` produces an HTML report of friction points.

  — [Costs docs](https://code.claude.com/docs/en/costs)

**Model config page**
- Default model is Opus 5.5 on Pro, Max, Team, Enterprise and API. Effort defaults: `high` on most models, `medium` on Opus/Sonnet/Haiku 5.5, `xhigh` on Opus 4.7. Guidance: low for brainstorming and renames; medium for "day-to-day engineering work with a clear scope"; high when "verification matters or edge cases are likely"; max for hard unattended problems, though it "may show diminishing returns and is prone to overthinking". Skills and subagents can set `effort` in frontmatter. — [Model config docs](https://code.claude.com/docs/en/model-config)
- `ultrathink` adds an in-context instruction for one turn: "The effort level sent to the API is unchanged". "think", "think hard" and "think more" are not recognized keywords. `opusplan` uses Opus in plan mode and Sonnet for execution. Fable models are for "your hardest and longest-running tasks", with tips "Describe the outcome, not the steps" and "Skip the verification reminders" (Fable verifies its own work). — [Model config docs](https://code.claude.com/docs/en/model-config)

**Skills page**
- "Custom commands have been merged into skills". `.claude/commands/deploy.md` and `.claude/skills/deploy/SKILL.md` both create `/deploy`. Keep SKILL.md under 500 lines. Description plus `when_to_use` is truncated at 1,536 characters, so put the key use case first. Use `disable-model-invocation: true` for side-effecting workflows (/deploy, /commit). `context: fork` only for skills with explicit task instructions. Evaluate in fresh sessions with and without the skill. Bundled skills include `/code-review`, `/batch`, `/debug`, `/loop`, `/verify`, `/simplify`, `/run` and `/doctor`. — [Skills docs](https://code.claude.com/docs/en/skills)

**Agent teams page**
- Experimental (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`). "Start with 3-5 teammates for most workflows… Three focused teammates often outperform five scattered ones". Give each teammate 5–6 tasks. Have each teammate own different files. Start with research and review tasks. Use `TeammateIdle`/`TaskCompleted` hooks as quality gates. Example: 5 teammates debating competing bug hypotheses. — [Agent teams docs](https://code.claude.com/docs/en/agent-teams)

**GitHub Actions, Code Review**
- `/install-github-app` sets up `anthropics/claude-code-action@v1` (on `@beta`: change to `@v1`, `direct_prompt` becomes `prompt`, CLI options move to `claude_args`). Best practices: put standards in CLAUDE.md, keep it concise ("Claude reads it on every run"), set `--max-turns`, workflow timeouts and concurrency limits, and run skills or plugins (e.g. `/code-review:code-review --comment`) as the prompt. — [GitHub Actions docs](https://code.claude.com/docs/en/github-actions)
- Managed Code Review (Team/Enterprise, GitHub only): multiple agents find issues, a verification step filters false positives, results are ranked by severity and posted inline. It never approves or blocks. It is tuned with `REVIEW.md` and `CLAUDE.md`, offers Quick, Standard and Deep levels, and is triggered with `@claude review`. Local alternative: `/code-review` on any plan. — [Code Review docs](https://code.claude.com/docs/en/code-review). Launched Mar 9, 2026 as a research preview. Secondary reporting gives about $15–25 and about 20 min per review, unverified against docs — [noqta.tn (secondary)](https://www.noqta.tn/en/news/claude-code-review-multi-agent-pull-request-review-2026)

### Inferences
- A team can set up a strong baseline entirely from the docs:
  - a checked-in CLAUDE.md under 200 lines plus `.claude/rules/`
  - checked-in `.claude/settings.json` allowlists, auto mode, and `/sandbox`
  - a formatting PostToolUse hook and a verification Stop hook
  - skills for repeated workflows and verification, with `disable-model-invocation` on side-effecting ones
  - `/code-review` or managed Code Review on PRs
  - `@claude` in PRs to add CLAUDE.md lessons

### Gaps
- Not fetched: the hooks guide, subagents and common-workflows pages. Their content is covered only where the best-practices and costs pages summarize them.

## 4. Anthropic courses, cookbooks, quickstarts and repos (brief)

### Takeaway
Official learning material exists (free Anthropic Academy courses on Skilljar, including "Claude Code in Action", plus claude-code-action examples). For copyable assets, the most useful are the claude-code-action `examples/` workflows and the Anthropic-maintained plugins in anthropics/claude-plugins-official, which package the creators' own workflows: code-simplifier, /commit-push-pr, /revise-claude-md, /feature-dev, ralph-loop, the multi-agent /code-review, and security-guidance.

### Cited Findings
- Anthropic Academy (anthropic.skilljar.com) offers free certified courses, including "Claude Code in Action" (reported as 15 lectures, about 1 h of video, 1 quiz). Third-party counts of the catalogue conflict (13, 17 or 21 courses). — [pasqualepillitteri.it (secondary)](https://pasqualepillitteri.it/en/news/371/anthropic-academy-free-courses-claude); [Tutorials Dojo (secondary)](https://tutorialsdojo.com/?p=40340)
- `anthropics/claude-code-action` has a ready-to-use `examples/claude.yml` (@claude mentions), plus code-review and scheduled-report examples. The official `code-review` plugin is installed from the `https://github.com/anthropics/claude-code.git` marketplace as `code-review@claude-code-plugins`. — [GitHub Actions docs](https://code.claude.com/docs/en/github-actions)
- The sandbox runtime is open source at anthropic-experimental/sandbox-runtime. — [Sandboxing post](https://www.anthropic.com/engineering/claude-code-sandboxing)
- Compaction with cache-safe forking is built into the Claude API (platform.claude.com/docs/en/build-with-claude/compaction). — [Prompt caching post](https://claude.dev/blog/lessons-from-building-claude-code-prompt-caching-is-everything/)

**Official plugin marketplace: anthropics/claude-plugins-official.** Read via `git clone --depth 1`; last commit Oct 19, 2026. Install with `/plugin install {name}@claude-plugins-official`. `/plugins` holds Anthropic-maintained plugins and `/external_plugins` holds partner and community ones. The README warns: "Make sure you trust a plugin before installing… Anthropic does not control what MCP servers, files, or other software are included in plugins." — [claude-plugins-official](https://github.com/anthropics/claude-plugins-official)
- The Anthropic-maintained plugins (Oct 2026) codify the team practices described in section 2:
  - `code-simplifier`: Boris's post-task cleanup subagent. Frontmatter `model: opus`; "Focuses on recently modified code"; applies standards "from CLAUDE.md".
  - `commit-commands`: includes `/commit-push-pr`, which pre-computes context with inline bash (`!git status`, `!git diff HEAD`, `!git branch --show-current`), pre-allows only specific git/gh commands, and asks for all tool calls in a single message. This is the command Boris says he runs "dozens of times a day".
  - `claude-md-management`: `/revise-claude-md` "Update CLAUDE.md with learnings from this session" ("Keep it concise - one line per concept… Avoid… One-off fixes unlikely to recur"), plus a `claude-md-improver` skill.
  - `feature-dev`: Sid's `/feature-dev`, with code-explorer, code-architect and code-reviewer agents.
  - `ralph-loop`: a Stop-hook while-true loop, the "Ralph Wiggum technique".
  - `security-guidance` (v2.0.14, author David Dworken): pattern warnings on edits, LLM diff review on Stop, and an agentic commit reviewer.
  - `claude-security`: deep vulnerability scan where "every finding challenged before it is reported".
  - `pr-review-toolkit`: comment, test, silent-failure, type-design and simplifier agents.
  - `hookify`: creates hooks from conversation patterns.
  - `claude-code-setup`: recommends hooks, skills, MCP and subagents for a codebase.
  - `skill-creator`: includes evals and benchmarking.
  - `session-report`, `code-modernization`.
  - LSP plugins for about 13 languages (typescript, pyright, gopls, rust-analyzer, clangd, jdtls, and others).

  — [claude-plugins-official/plugins](https://github.com/anthropics/claude-plugins-official/tree/main/plugins)
- **Official `/code-review` plugin algorithm (copyable reference design):**
  1. Haiku agents check eligibility (closed, draft, trivial, already reviewed) and collect relevant CLAUDE.md paths.
  2. **5 parallel Sonnet reviewers**: CLAUDE.md compliance, a shallow bug scan of the diff only, git blame and history, comments on prior PRs touching the files, and in-code comment guidance.
  3. A Haiku agent per issue scores confidence 0–100 against a verbatim rubric.
  4. "Filter out any issues with a score less than 80".

  Listed false positives include pre-existing issues, general quality issues "unless explicitly required in CLAUDE.md", and lint-silenced issues. — [code-review.md](https://github.com/anthropics/claude-plugins-official/blob/main/plugins/code-review/commands/code-review.md)
- `anthropics/claude-code/plugins` (the marketplace used in the GitHub Actions docs) carries an older overlapping set: agent-sdk-dev, claude-opus-4-5-migration, code-review, commit-commands, explanatory- and learning-output-style, feature-dev, frontend-design, hookify, plugin-dev, pr-review-toolkit, ralph-wiggum and security-guidance. The `ralph-wiggum` name Boris cited in Jan 2026 appears as `ralph-loop` in claude-plugins-official. — [anthropics/claude-code plugins](https://github.com/anthropics/claude-code/tree/main/plugins)
- `anthropics/skills` (Agent Skills examples) contains academy-guide, algorithmic-art, brand-guidelines, canvas-design, claude-api, discernment-nudge, doc-coauthoring, docx, frontend-design, internal-comms, mcp-builder, pdf, pptx, skill-creator, slack-gif-creator, theme-factory, web-artifacts-builder, webapp-testing and xlsx. — [anthropics/skills](https://github.com/anthropics/skills)

### Inferences
- Teams should start from the official claude-code-action examples and official plugins (code-review, code-simplifier per Boris) before third-party collections. Third-party collections are covered by other researchers.
- The official plugins are effectively Boris's thread packaged as installable artifacts: `/commit-push-pr` with inline bash, the code-simplifier subagent, a ralph loop through a Stop hook, and CLAUDE.md revision after sessions. A team can install them rather than re-create them. The `/code-review` design (5 independent reviewers, confidence scoring, a cut-off at 80) is the concrete first-party answer to reviewer over-reporting.

### Gaps
- The `gh` CLI and api.github.com returned HTTP 403. The repos were read instead with a read-only shallow `git clone`, and no repo scripts were run. Star counts were not collected. The claude-cookbooks repo was not reviewed.

## 5. Where first-party guidance contradicts, refines or supersedes popular community advice

### Takeaway
Most popular community advice is out of date relative to the Oct 2026 product, or more absolute than Anthropic's own guidance. The main cases: thinking keywords now give way to `/effort`, MCP tool definitions are deferred by default, a CLAUDE.md target of under 200 lines (vs. community "<60"), skip-permissions has been replaced by auto mode, and parallelism has concrete first-party numbers (3–5). Anthropic's own sources also disagree with each other in places: CLI vs MCP, always-Opus vs Sonnet-first, and plan mode for everything vs skip planning for small diffs.

### Cited Findings
- **"think < think hard < think harder < ultrathink" budgets: SUPERSEDED.** Effort levels (`/effort`: low, medium, high, xhigh, max) now control reasoning, and models from Opus 4.7 onward use adaptive reasoning. Only `ultrathink` is recognized, and it adds an in-context instruction "without changing your session effort setting… The effort level sent to the API is unchanged". "think hard" is not a keyword. — [Model config docs](https://code.claude.com/docs/en/model-config). Community reports conflict on whether ultrathink was "deprecated" (it was reportedly removed and then re-added around v2.1.68) — [claudemarket.ai (secondary)](https://claudemarket.ai/blog/claude-code-ultrathink); [Medium (secondary)](https://medium.com/@joe.njenga/claude-code-ultrathink-is-back-in-new-update-i-just-tested-it-f54d938d382f). First-party practice is to use `/effort`. Boris uses xhigh for most work and max for the hardest — [Boris Apr 16, 2026 (mirror)](https://twitter-thread.com/t/2044847848035156457). Docs warn max "is prone to overthinking" — [Model config docs](https://code.claude.com/docs/en/model-config).
- **Default effort matters.** Lowering the default from high to medium in March 2026 measurably hurt perceived quality and was reverted — [Postmortem](https://www.anthropic.com/engineering/april-23-postmortem). As of Oct 2026 the 5.5-generation models again default to `medium` — [Model config docs](https://code.claude.com/docs/en/model-config). Teams doing bug fixes in existing code should consider `high` per the docs' own guidance.
- **"Keep MCP servers to a minimum because they eat context": REFINED.** MCP tool definitions are now "deferred by default" (only names enter context until used), so server count matters far less than in 2025. The docs still say CLIs "are still more context-efficient" and recommend disabling unused servers — [Costs docs](https://code.claude.com/docs/en/costs). Why deferral matters: a 58-tool setup was about 55K tokens, cut 85% by tool search — [Advanced tool use](https://www.anthropic.com/engineering/advanced-tool-use); stubs are sent with `defer_loading` — [Prompt caching post](https://claude.dev/blog/lessons-from-building-claude-code-prompt-caching-is-everything/). Internal contradiction: the Data Infrastructure team recommends "MCP servers instead of CLI for sensitive data" for access control and logging — [PDF report](https://www-cdn.anthropic.com/58284b19e702b49db9302d5b6f135ad8871e7658.pdf). Pick CLIs for efficiency and MCP where governance matters.
- **CLAUDE.md length.** Official: "target under 200 lines per CLAUDE.md file" — [Memory docs](https://code.claude.com/docs/en/memory); "Aim to keep CLAUDE.md under 200 lines" — [Costs docs](https://code.claude.com/docs/en/costs). Popular community guidance attributed to HumanLayer is stricter: under 60 lines ideal and 300 maximum — [secondary summary](https://www.skills.sh/bsene/skills/writing-a-good-claude-md). There is tension with Boris's "add a line every time Claude errs" — [mirror](https://twitter-thread.com/t/2007179832300581177). The docs reconcile the two: add a line when a mistake repeats, but prune regularly, convert must-always rules into hooks, and move procedures into skills or path-scoped rules — [Best practices](https://code.claude.com/docs/en/best-practices); [Memory docs](https://code.claude.com/docs/en/memory).
- **`.claude/commands/` vs skills: SUPERSEDED (still works).** Boris's Jan 2026 advice put slash commands in `.claude/commands/` — [mirror](https://twitter-thread.com/t/2007179832300581177). Commands "have been merged into skills". New work should go in `.claude/skills/<name>/SKILL.md` with `disable-model-invocation: true` for manual workflows — [Skills docs](https://code.claude.com/docs/en/skills).
- **"YOLO" / `--dangerously-skip-permissions`: CONTRADICTED.** Anthropic calls it "unsafe in most situations" and recommends auto mode, with a sandbox for isolation — [Auto mode post](https://www.anthropic.com/engineering/claude-code-auto-mode). Auto mode has been the default starting mode since v2.1.283 — [Best practices](https://code.claude.com/docs/en/best-practices). Boris avoided skip-permissions outside sandboxes even in Jan 2026 — [mirror](https://twitter-thread.com/t/2007179832300581177). Caveat: auto mode still misses 17% of real overeager actions — [Auto mode post](https://www.anthropic.com/engineering/claude-code-auto-mode).
- **Number of parallel agents (community "run 10–20 agents").** First-party numbers:
  - Team tip: 3–5 worktrees — [Jan 31 thread (mirror)](https://twitter-thread.com/t/2017742741636321619)
  - Boris: 5 local plus 5–10 web — [Jan 2 thread (mirror)](https://twitter-thread.com/t/2007179832300581177)
  - Agent teams: "Start with 3-5 teammates", 5–6 tasks each, about 7x tokens — [Agent teams docs](https://code.claude.com/docs/en/agent-teams); [Costs docs](https://code.claude.com/docs/en/costs)
  - `/batch`: 5–30 subagents — [Best practices](https://code.claude.com/docs/en/best-practices)
  - Carlini: 16 agents, and they only helped when the work was decomposable — [C compiler](https://www.anthropic.com/engineering/building-c-compiler)
  - Boris (mid-2026, secondary): "several hundred" instances in loops for idea generation — [WorkOS (secondary)](https://workos.com/blog/boris-cherny-claude-code-acquired-interview-takeaways)

  Refinement: parallelism pays only with independent tasks, separate worktrees or files, and good verifiers.
- **"Always use the biggest model" vs cost-first.** Boris used "Opus 4.5 with thinking for everything" — [mirror](https://twitter-thread.com/t/2007179832300581177). The docs say "Sonnet handles most coding tasks well… Reserve Opus" and use Haiku for simple subagents — [Costs docs](https://code.claude.com/docs/en/costs). The current default is Opus 5.5 at medium effort — [Model config docs](https://code.claude.com/docs/en/model-config). Also, don't switch models mid-session to save money, because it breaks the cache; use a subagent instead — [Prompt caching post](https://claude.dev/blog/lessons-from-building-claude-code-prompt-caching-is-everything/).
- **Plan mode always?** Boris starts "most sessions" in plan mode and says it gives 2–3x success — [mirror](https://twitter-thread.com/t/2007179832300581177); [Every transcript](https://every.to/podcast/transcript-how-to-use-claude-code-like-the-people-who-built-it). The docs refine this: plan mode "adds overhead", so skip it if the diff fits in one sentence — [Best practices](https://code.claude.com/docs/en/best-practices). RL Engineering: "Try one-shot first" (works about one-third of the time) — [PDF report](https://www-cdn.anthropic.com/58284b19e702b49db9302d5b6f135ad8871e7658.pdf).
- **"Fix it in place" vs restart.** First-party advice is to restart: "Starting over often has a higher success rate than trying to fix Claude's mistakes" — [PDF report](https://www-cdn.anthropic.com/58284b19e702b49db9302d5b6f135ad8871e7658.pdf); after two failed corrections, `/clear` — [Best practices](https://code.claude.com/docs/en/best-practices).
- **More review agents is better? REFINED.** Reviewers asked to find gaps will always find some, which leads to over-engineering. Restrict them to correctness and requirement gaps — [Best practices](https://code.claude.com/docs/en/best-practices). Anthropic's own pipelines add a verification step that drops false positives and require agents to prove findings — [Code Review docs](https://code.claude.com/docs/en/code-review); [SDLC post](https://claude.com/blog/how-anthropic-secures-its-ai-native-software-development-lifecycle).
- **Verification reminders in prompts.** These remain core for most models ("2-3x") — [Boris (mirror)](https://twitter-thread.com/t/2044847848035156457). For Fable models the docs say "Skip the verification reminders" because the model verifies itself, although you should still provide runnable checks — [Model config docs](https://code.claude.com/docs/en/model-config).
- **Context resets vs compaction: SUPERSEDED for newer models.** Resets were essential for Sonnet 4.5's "context anxiety". From Opus 4.5, automatic compaction in one continuous session sufficed — [Harness design](https://www.anthropic.com/engineering/harness-design-long-running-apps).

### Inferences
- The most portable first-party practices, the ones still valid across 2025–2026 model generations, are:
  - a runnable verification signal
  - plan or spec before large changes
  - aggressive context hygiene (`/clear`, subagents, short CLAUDE.md)
  - codifying repetition (skills, hooks, checked-in settings)
  - independent review in a fresh context
- Model-specific tactics (thinking keywords, context resets, sprint scaffolds, specific effort defaults) have the shortest shelf life, and Anthropic itself rewrites them each model release.

### Gaps
- Sources on community advice (HumanLayer CLAUDE.md line counts, "ultrathink deprecated") are secondary. The original HumanLayer post was not retrieved.
- There is no first-party statement giving a hard cap on MCP server count or skill count. The skills docs give the 1,536-character description truncation but no total skill limit in the portion read.
