# Multi-agent "swarm" setups for software development: Claude Code focus, cost efficiency (state as of 2026-10-19)

Scope note: this file covers agents that communicate and delegate among themselves. Single-agent loops (Ralph, /loop, headless/CI) and plain parallel worktree session managers (Conductor, claude-squad, Crystal) belong to another researcher and are cross-referenced only briefly. Star counts come from shields.io endpoints (`img.shields.io/github/stars/OWNER/REPO.json`), last-commit dates from shields.io and shallow `git clone --depth 1`, all fetched 2026-10-19. Claude Code docs pages cited were fetched 2026-10-19. They reference Claude Code versions up to about v2.1.302 and models Opus 5 / Opus 5.5, Sonnet 5.5, Haiku 5.5 and Fable.

## 1. Claude Code native multi-agent features (Oct 2026): subagents, agent teams, background agents, workflows, cross-session messaging, Agent SDK

### Takeaway
As of October 2026 Claude Code offers five official ways to run several agents:
- **Subagents (GA):** delegated workers that report back to the parent.
- **Agent view / background sessions:** research preview.
- **Agent teams:** still EXPERIMENTAL and off by default. A lead plus teammates share a JSON-file task list and JSON-file mailboxes (SendMessage).
- **Projects (cloud threads):** public beta on Pro/Max.
- **Dynamic workflows:** a JS script fans out dozens to hundreds of subagents.

Cross-session messaging (ListAgents/SendMessage over local sockets) is on by default for sessions you run yourself. Agent teams are the token-heaviest option: Anthropic gives "~7x" in plan mode and otherwise says usage is roughly proportional to team size. Subagents and workflows keep intermediate results out of the main context. None of the native options prevents two agents from editing the same file except worktree isolation, which agent teams do NOT use.

### Cited Findings
**Overview of the five approaches**
- The official page "Run agents in parallel" lists five approaches. Subagents are "Delegated workers inside one session that do a side task in their own context and return a summary". Agent view (`claude agents`) is a "Research preview". Agent teams are "Experimental and disabled by default". Projects are a "Public beta on Pro and Max". Dynamic workflows are "A script that runs many subagents and cross-checks their results" — [Claude Code docs: Run agents in parallel](https://code.claude.com/docs/en/agents)
- The same page names helper tools: worktrees; cross-session messaging; and `/batch`, "a skill that has Claude split one large change into 5 to 30 worktree-isolated subagents". It adds: "Agent teams don't isolate teammates in worktrees, so partition the work so each teammate owns a different set of files", and "Running several sessions or subagents at once multiplies token usage." — [Run agents in parallel](https://code.claude.com/docs/en/agents)

**Agent teams: status and architecture**
- Status: "Agent teams are experimental and disabled by default. Enable them by setting `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`". Teammates require an interactive session. "In non-interactive mode with the -p flag, including Agent SDK sessions, Claude doesn't spawn teammates" — [Claude Code docs: Agent teams](https://code.claude.com/docs/en/agent-teams)
- Architecture: a team lead (the main session), teammates (separate Claude Code instances), a shared task list and a mailbox. Each agent's mailbox is a JSON file at `~/.claude/teams/{team-name}/inboxes/{agent-name}.json`. The task list lives in `~/.claude/tasks/{team-name}/`. Team config is `~/.claude/teams/{team-name}/config.json`, with a `members` array that teammates can read to discover each other — [Agent teams](https://code.claude.com/docs/en/agent-teams)

**Agent teams: tasks and messaging**
- Tasks have three states: pending, in progress, completed. Tasks can have dependencies, and dependent tasks unblock automatically. The lead assigns, or teammates self-claim "the next unassigned, unblocked task". "Task claiming uses file locking to prevent race conditions when multiple teammates try to claim the same task simultaneously." — [Agent teams](https://code.claude.com/docs/en/agent-teams)
- Messages are delivered automatically, so there is no polling. Idle notifications carry the teammate's final answer to the lead. There is no broadcast: "To reach everyone, send one message per recipient." Teammates load CLAUDE.md, MCP servers and skills. "The lead's conversation history does not carry over." — [Agent teams](https://code.claude.com/docs/en/agent-teams)

**Agent teams: models, plans and hooks**
- Each teammate's model is chosen in this order: model named in the spawn prompt, then the subagent definition's `model`, then `CLAUDE_CODE_SUBAGENT_MODEL`, then the lead's model. `CLAUDE_CODE_SUBAGENT_MODEL_FORCE=1` (v2.1.257+) forces one model. Teammates inherit the lead's effort level. Reusable roles come from `.claude/agents/` subagent definitions — [Agent teams](https://code.claude.com/docs/en/agent-teams)
- Plan-first mode: a teammate spawned while the lead is in plan mode works read-only until its plan is approved. "Claude Code approves the plan in the lead's session as soon as the request arrives, without the lead reviewing it." Hooks `TeammateIdle`, `TaskCreated` and `TaskCompleted` can block or give feedback with exit code 2 — [Agent teams](https://code.claude.com/docs/en/agent-teams)
- With agent teams enabled, "a subagent that Claude names launches as a teammate, so teams can form even when you didn't ask for one" (a cost risk) — [Agent teams](https://code.claude.com/docs/en/agent-teams)

**Agent teams: limitations**
- Documented limitations:
  - no session resumption of in-process teammates;
  - "Task status can lag";
  - slow shutdown;
  - one team per session;
  - no nested teams;
  - no background subagents from in-process teammates;
  - the lead is fixed;
  - split panes need tmux or iTerm2.

  Source: [Agent teams](https://code.claude.com/docs/en/agent-teams)
- File conflicts: "Two teammates editing the same file leads to overwrites. Break the work so each teammate owns a different set of files." — [Agent teams](https://code.claude.com/docs/en/agent-teams)

**Subagents**
- Frontmatter fields: `name`, `description`, `tools`, `disallowedTools`, `model` (sonnet / opus / haiku / fable / full ID / inherit), `permissionMode`, `maxTurns`, `skills`, `mcpServers`, `hooks`, `memory` (user / project / local), `background`, `isolation: worktree`, `effort`, `omitClaudeMd`, `autoCompactWindow`. Built-ins are Explore, Plan, general-purpose, claude-code-guide (Haiku) and statusline-setup (Sonnet) — [Claude Code docs: Subagents](https://code.claude.com/docs/en/sub-agents)
- In the current docs, the built-in Explore uses the main conversation's model. To make it cheap, define your own `Explore` with `model: haiku`. (Per the WebFetch summary of the page; earlier versions ran Explore on Haiku.) — [Subagents](https://code.claude.com/docs/en/sub-agents)
- Nesting: subagents can spawn subagents up to 3 layers deep (`CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH`). The default concurrency limit is 20 (`CLAUDE_CODE_MAX_CONCURRENT_SUBAGENTS`). Subagents spawned from the main conversation run in the background by default. A named subagent can be resumed or messaged via `SendMessage`, keeping its full history. There is a 15,000-token limit on combined subagent descriptions — [Subagents](https://code.claude.com/docs/en/sub-agents)
- Subagents start fresh. Only the final summary returns to the main conversation. "each subagent spends tokens of its own while it runs" — [Subagents](https://code.claude.com/docs/en/sub-agents)
- A forked subagent (`/subtask`, or `subagent_type: "fork"` in the SDK from v2.1.302) inherits the full conversation instead of starting fresh — [Run agents in parallel](https://code.claude.com/docs/en/agents); [Agent SDK subagents](https://code.claude.com/docs/en/agent-sdk/subagents)

**Dynamic workflows**
- A workflow is a JS script using `agent()`, `pipeline()`, `parallel()`, `phase()` and `args`. "Intermediate results stay in script variables instead of landing in Claude's context", so "Claude's context holds only the final answer." — [Claude Code docs: Dynamic workflows](https://code.claude.com/docs/en/workflows)
- Comparison table on that page: subagents handle "A few delegated tasks per turn"; agent teams are "A handful of long-running peers"; workflows run "Dozens to hundreds of agents per run". Workflows are resumable — [Dynamic workflows](https://code.claude.com/docs/en/workflows)
- Workflows are triggered by the `ultracode` keyword, `/effort ultracode` (auto-plans workflows for every substantive task, "so each request uses more tokens"), or saved commands in `.claude/workflows/`. The bundled one is `/deep-research` — [Dynamic workflows](https://code.claude.com/docs/en/workflows)

**Cross-session messaging**
- Cross-session messaging: "requires Claude Code v2.1.224 or later … messaging is on with nothing to enable". Claude uses `ListAgents` and `SendMessage`. On the same machine, messages travel "Over a per-session socket … never through Anthropic servers". Other machines and the cloud go via Remote Control. Messages are "Plain text only", never the sender's history or files — [Claude Code docs: Cross-session messaging](https://code.claude.com/docs/en/cross-session-messaging)
- A message is read between tool calls; it does not interrupt a running tool. If the receiver is idle, the message starts a new turn. Delivered messages count toward usage. `notify_when_idle` subscriptions spend no tokens in the watched session. An inbound message can never approve a permission prompt. `crossSessionInbound` takes accept / hold / refuse. Loops are throttled: "queues at most 50 accepted messages … A message loop between two sessions therefore stops on its own." — [Cross-session messaging](https://code.claude.com/docs/en/cross-session-messaging)

**Agent SDK**
- Subagents are defined with the `agents` option (AgentDefinition, including `model`). The only thing passed from parent to subagent is the Agent tool's prompt string. Subagents run in background by default (`status: "async_launched"`). Caps: depth (default 3), concurrency (default 20), and spend via `maxBudgetUsd` / `max_budget_usd`. At the spend cap the SDK "refuses to spawn more subagents … stops background subagents … ends the query with the error_max_budget_usd result subtype". The `Workflow` tool is available in TS SDK v0.3.149+ — [Claude Code docs: Agent SDK subagents](https://code.claude.com/docs/en/agent-sdk/subagents)
- "Claude Opus 5 delegates to subagents more readily than earlier models". With the `claude_code` preset, Claude Code adds a line telling Claude not to call the Agent tool unless asked — [Agent SDK subagents](https://code.claude.com/docs/en/agent-sdk/subagents)

### Inferences
- Native messaging comes in three tiers:
  - subagent → parent: a summary return, cheapest;
  - agent-team mailbox: JSON files, automatic delivery, each message a model round trip;
  - cross-session sockets: for independent sessions you run yourself.

  The native shared "blackboard" is the task list, plus whatever files you tell agents to write.
- For cost-sensitive teams, the default should be subagents or workflows, which isolate context and return compact results. Agent teams fit only when workers truly need to talk to each other mid-task. The fact that Anthropic still labels agent teams experimental after their February 2026 launch with Opus 4.6 supports this.
- Enabling agent teams changes ordinary delegation: named subagents become full teammates. Teams should not leave `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` on globally.

### Gaps
- No official GA date or roadmap for agent teams was found. Anthropic gives no measured multiplier for teams outside plan mode beyond "roughly proportional to team size".
- I did not fetch the agent-view (background sessions) page in detail. Its research-preview status comes from the comparison page only.

## 2. Third-party swarm/orchestration frameworks for coding agents

### Takeaway
The ecosystem splits into four groups:
- **Heavyweight Claude Code harnesses:** Ruflo (ex claude-flow), oh-my-claudecode. Both are very popular and very active but marketing-heavy; their cost-saving claims are unverified.
- **Coordination primitives:** MCP Agent Mail for mailbox and file leases; Beads for an atomically-claimable dependency task graph. Both are robust and composable.
- **Opinionated "agent towns":** Gas Town, now superseded by Gas City; multi-agent-shogun; Agent Farm; ccswarm.
- **General LLM frameworks:** CrewAI, LangGraph, AutoGen (archived). These are not Claude Code-native.

Notable 2026 signals: Gas Town "burned down" with Opus 4.7 per its author, and the Shogun author disbanded his 10-agent army to a single agent (Aug 2026). In other words, the most aggressive swarm advocates retreated.

### Cited Findings
**Ruflo (formerly claude-flow, by ruvnet)**
- Activity: 77k stars; `ruvnet/claude-flow` redirects to the same repo. Last commit 2026-10-19, release v3.57.1/3.57.2. It describes itself as "An agent meta-harness for Claude Code and Codex", requiring Claude Code 2.1.287+. Install is via the Claude Code plugin marketplace or `npx ruflo init`, and it exposes an MCP server ("314 MCP tools or 26 CLI commands"). First commit June 2, 2025 — [GitHub ruvnet/ruflo](https://github.com/ruvnet/ruflo)
- Communication and delegation: the README describes "Queen-led hierarchy (Raft, Byzantine, Gossip)", hive mind with "3 queen types, 8 worker types", 5 consensus algorithms, HNSW vector memory (AgentDB), "Intelligent routing (89% accuracy)" (vendor claim), and federation via mTLS + ed25519. The README also shows an "Illustrative download counter" starting at 98,000,000 — [ruflo README](https://github.com/ruvnet/ruflo)
- Cost: the ruflo-cost-tracker plugin provides budgets with alerts at 50/75/90% and a hard stop at 100%, a counterfactual comparison against always-haiku/sonnet/opus, and "Agent Booster (Tier 1, $0, WASM)". Its own README admits: "CLAUDE.md root percentage claims (-32% retrieval, -15% booster edits, 352x speedup, 95% cache hit) are claimed upstream, not yet verified in this repo." — [ruflo-cost-tracker README](https://github.com/ruvnet/ruflo/tree/main/plugins/ruflo-cost-tracker)
- No independent user reports on ruflo/claude-flow token cost turned up in searches (see Gaps).

**oh-my-claudecode (OMC, Yeachan-Heo)**
- Activity: 40k stars, v5.7.5, last commit 2026-10-18. "Multi-agent orchestration for Claude Code. Zero learning curve." Since v4.1.7, Team is the canonical surface and the legacy `swarm` was removed — [GitHub Yeachan-Heo/oh-my-claudecode](https://github.com/Yeachan-Heo/oh-my-claudecode)
- Team runs on Claude Code native agent teams (it requires `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`) as a staged pipeline: `team-plan → team-prd → team-exec → team-verify → team-fix (loop)`. `omc team N:codex|gemini|cursor|claude` spawns tmux CLI workers on demand that "die when their task completes". Worktrees for native team workers are "being added behind an opt-in/config gate" — [OMC README](https://github.com/Yeachan-Heo/oh-my-claudecode)
- Cost claim (vendor, unverified): "Smart model routing saves 30-50% on tokens" (Haiku for simple, Opus for complex). The author also points users who find OMC "a bit overkill" to a lighter gajae-code — [OMC README](https://github.com/Yeachan-Heo/oh-my-claudecode)

**MCP Agent Mail (Dicklesworthstone)**
- Activity: the Python repo has 2.2k stars and is now marked "Superseded by mcp_agent_mail_rust … This Python version is no longer maintained". The Rust repo has 209 stars and is active — [GitHub mcp_agent_mail](https://github.com/Dicklesworthstone/mcp_agent_mail); [mcp_agent_mail_rust](https://github.com/Dicklesworthstone/mcp_agent_mail_rust)
- Mechanism: "A mail-like coordination layer for coding agents, exposed as an HTTP-only FastMCP server". It provides identities, inbox/outbox, threads, search, and "voluntary file reservation 'leases'" such as `file_reservation_paths(..., ["src/**"], ttl_seconds=3600, exclusive=true)`. A pre-commit guard blocks commits that conflict with others' exclusive reservations. Storage is Git plus SQLite. It "Keeps communication out of your token budget by storing messages in a per-project archive" — [mcp_agent_mail README](https://github.com/Dicklesworthstone/mcp_agent_mail)
- Recommended pairing with Beads: Beads is the task status/dependency authority; Mail carries conversation and reservations; Beads IDs serve as thread IDs. Vendor claim (unverified): "One disciplined hour of GPT-5 Codex … often produces 10–20 'human hours' of work". There is a commercial Companion app — [mcp_agent_mail README](https://github.com/Dicklesworthstone/mcp_agent_mail)

**Beads (steveyegge/beads, now gastownhall/beads)**
- Activity: 28k stars, v1.3.1, last commit 2026-10-19. "Distributed graph issue tracker for AI agents, powered by Dolt". `bd ready` lists tasks with no open blockers. `bd update <id> --claim` = "Atomically claim a task (sets assignee + in_progress)". Hash-based IDs "prevent merge collisions in multi-agent/multi-branch workflows". "Compaction: Semantic 'memory decay' summarizes old closed tasks to save context window." Embedded Dolt is single-writer; server mode supports multiple concurrent writers — [GitHub steveyegge/beads](https://github.com/steveyegge/beads)
- Conflict: the Agent Mail installer replaces Go `bd` with Beads Rust `br` (1.1k stars), claiming the Go version is "no longer actively maintained" — [mcp_agent_mail README](https://github.com/Dicklesworthstone/mcp_agent_mail). This is contradicted by the Go repo's commit on 2026-10-19 — [gastownhall/beads](https://github.com/gastownhall/beads)

**Gas Town / Gas City (Steve Yegge, gastownhall)**
- Gas Town: 18k stars, last commit 2026-07-23. Roles:
  - Mayor: Claude Code coordinator;
  - Rigs: one per repo;
  - Polecats: workers with persistent identity and ephemeral sessions;
  - Hooks: git-worktree persistent storage;
  - Convoys: bundles of beads;
  - Witness / Deacon: stuck-agent detection;
  - Refinery: per-rig merge queue, "Bors-style bisecting queue" with verification gates.

  Mail is injected via Claude Code hooks. Claim: "4-10 agents become chaotic" → "Scale comfortably to 20-30 agents" — [GitHub steveyegge/gastown](https://github.com/steveyegge/gastown)
- Yegge's post-mortem (Aug 2026): Gas Town "was intended to be reusable, but I only ever wound up using it to build itself"; "Gas Town fell apart at the seams with Opus 4.7"; "The Opus tic never went away, so Gas Town effectively burned down." — [Yegge, The Shape of Things to Come](https://yegge.ai/essays/the-shape-of-things-to-come/) via [Simon Willison 2026-08-04](https://simonwillison.net/2026/Aug/4/steve-yegge/)
- Gas City (gastownhall/gascity, 1.4k stars, active) "extracts the reusable infrastructure from Gas Town into a configurable toolkit". It offers runtime providers (tmux, subprocess, ACP, Kubernetes) and "Beads-backed work tracking, formulas, molecules, waits, and mail", plus a "Coming from Gas Town?" guide — [GitHub gastownhall/gascity](https://github.com/gastownhall/gascity)
- A secondary summary of the essay says Yegge's successor is a closed-source personal harness, "Wheelhouse", and that he has "given up on building reusable harnesses" — [vanja.io](https://vanja.io/yegge-agent-city-four-claims/)

**multi-agent-shogun (yohey-w)**
- Activity: 1.4k stars, v5.1.0, last commit Aug 2026. Structure: Shogun → Karo (manager) → 7 Ashigaru workers + 1 Gunshi (strategist), each in a tmux pane. Communication is "YAML files on disk" with event-driven notification and no polling. It claims "Zero coordination overhead" (vendor; each agent still pays for its own context) — [GitHub yohey-w/multi-agent-shogun](https://github.com/yohey-w/multi-agent-shogun)
- Sequel (Aug 2026): "The author has since disbanded his own 10-agent army down to a single agent that carries his judgment." The successor, kagemusha (16 stars), ships "a judgment loop (corrections → principles → standing rules), not the agents" — [shogun README](https://github.com/yohey-w/multi-agent-shogun); [kagemusha](https://github.com/yohey-w/kagemusha)

**Smaller orchestrators**
- **claude_code_agent_farm (Dicklesworthstone):** 922 stars, last commit Sep 2026, no releases. Runs "20+ Claude Code agents simultaneously (up to 50)" in tmux. Coordination is through `/coordination/active_work_registry.json` plus `agent_locks/{agent_id}_{timestamp}.lock`; stale locks older than 2h are handled; agents auto-`/clear` near context limits — [GitHub claude_code_agent_farm](https://github.com/Dicklesworthstone/claude_code_agent_farm)
- **ccswarm (nwiizo):** 153 stars, v0.10.2, Oct 2026. A Rust workflow engine running "plan → Sangha quorum → implement → review → fix". It uses `claude --max-budget-usd` and `--worktree`, and `ccswarm cost <run-id>` gives a per-stage/per-agent breakdown. Several features are flagged as design, not shipped — [GitHub nwiizo/ccswarm](https://github.com/nwiizo/ccswarm)

**General frameworks and session managers**
- **AutoGen:** README now says "Project archived and no longer maintained … New users should start with Microsoft Agent Framework" — [GitHub microsoft/autogen](https://github.com/microsoft/autogen)
- **OpenHands (91k stars, v1.28.1):** the README now leads with "Agent Canvas — The self-hosted developer control center for coding agents and automations". It can run OpenHands, Claude Code, Codex, Gemini or any ACP agent across local, remote and cloud backends. This is a control plane, not peer messaging — [GitHub OpenHands/OpenHands](https://github.com/OpenHands/OpenHands)
- **CrewAI (60k stars), LangGraph (44k):** active general-purpose frameworks for building your own agents. They do not orchestrate Claude Code sessions natively — [crewAI](https://github.com/crewAIInc/crewAI); [langgraph](https://github.com/langchain-ai/langgraph)
- **Subagent definition libraries:** wshobson/agents (41k stars) and VoltAgent/awesome-claude-code-subagents (26k stars) are collections of `.claude/agents` definitions rather than orchestrators — [wshobson/agents](https://github.com/wshobson/agents); [awesome-claude-code-subagents](https://github.com/VoltAgent/awesome-claude-code-subagents)
- **Session managers (cross-reference only):** claude-squad (8.6k stars, last commit Aug 2026) gives "Each task … its own isolated git workspace" with no inter-agent messaging — [GitHub smtg-ai/claude-squad](https://github.com/smtg-ai/claude-squad). stravu/crystal (3.1k stars) last committed Feb 2026, so it looks stale — [crystal](https://github.com/stravu/crystal)

### Inferences
- The durable, low-risk building blocks are boring ones:
  - a dependency-aware task graph with atomic claims (Beads, or the native agent-team task list);
  - an async mailbox outside the context window (Agent Mail, the native mailbox);
  - file leases or worktrees;
  - a merge queue with gates (Gas Town's Refinery idea).

  Teams can adopt these without the heavyweight harnesses.
- The more ambitious "hive mind/consensus" frameworks (Ruflo) publish few independently verified numbers, and their own sub-READMEs disclaim headline figures. Treat them as experimental for cost-sensitive teams.
- Communication-mechanism taxonomy:
  - Shared files: Shogun YAML, Agent Farm lock registry, the C-compiler `current_tasks/` approach, native JSON mailboxes.
  - MCP mailbox: Agent Mail.
  - Task board: Beads, the native task list, Gas Town convoys.
  - Script/variables: native workflows.

  Delegation is almost always orchestrator-worker. True peer-to-peer appears only in agent teams, where teammates message each other, and in the leaderless C-compiler experiment.

### Gaps
- No independent, quantified user reports were found on token cost or reliability for Ruflo/claude-flow hive-mind, OMC Team, or Agent Mail swarms. Searches returned only vendor docs and skill-listing sites.
- Exact maintenance status of Gas Town: the repo is quiet since July 2026 and a successor SDK exists. An uncorroborated Spanish article claims it was "shut down".
- I did not check GitHub issue trackers for bug and complaint volume, because GitHub API access is blocked.

## 3. Cost evidence: token multiples of multi-agent vs single agent

### Takeaway
Every credible measurement shows multi-agent setups cost a multiple of a single agent:
- Anthropic research system: ~15x vs chat (agents alone ~4x).
- Claude Code agent teams: ~7x in plan mode per Anthropic.
- Vals AI, Oct 2026, Claude Code headless with subagents enabled on Opus 5.5: 2.2x–5.1x per app, with no statistically significant score gain.
- Anthropic's 16-agent C compiler: ~$20k for 2B input tokens.

The extra spend is dominated by each agent re-reading its own context, i.e. cached input. Multi-agent pays off mainly for breadth-first, parallelizable work (research, review, independent modules), not typical sequential coding.

### Cited Findings
**Anthropic research system (June 2025)**
- "agents typically use about 4× more tokens than chat interactions, and multi-agent systems use about 15× more tokens than chats" — [Anthropic: How we built our multi-agent research system](https://www.anthropic.com/engineering/multi-agent-research-system)
- "token usage by itself explains 80% of the variance" on BrowseComp; with tool calls and model choice, 95% — [Anthropic multi-agent research system](https://www.anthropic.com/engineering/multi-agent-research-system)
- Opus 4 lead + Sonnet 4 subagents "outperformed single-agent Claude Opus 4 by 90.2%" on the internal research eval. But "most coding tasks involve fewer truly parallelizable tasks than research", and multi-agent is a poor fit where agents share the same context or have many dependencies — [Anthropic multi-agent research system](https://www.anthropic.com/engineering/multi-agent-research-system)

**Anthropic's Claude Code docs**
- "Agent teams use approximately 7x more tokens than standard sessions when teammates run in plan mode, because each teammate maintains its own context window and runs as a separate Claude instance." — [Claude Code docs: Costs](https://code.claude.com/docs/en/costs)
- "Token costs scale linearly"; "token usage is roughly proportional to team size"; "Each active teammate continues consuming tokens until it exits or the session ends." — [Agent teams](https://code.claude.com/docs/en/agent-teams); [Costs](https://code.claude.com/docs/en/costs)
- Baseline for single agents: "the average cost is around $13 per developer per active day and $150-250 per developer per month, with costs remaining below $30 per active day for 90% of users" — [Costs](https://code.claude.com/docs/en/costs)
- Workflows: "a single run can use meaningfully more tokens than working through the same task in conversation". A `Large workflow` warning appears when a run schedules "more than 25 agents, or its projected token total passes 1.5 million" — [Dynamic workflows](https://code.claude.com/docs/en/workflows)

**Vals AI, "Do Agent Teams Pay Off?" (2026-10-09)**
- Setup: Claude Opus 5.5 in Claude Code CLI headless, with subagent tools removed for "single" and enabled for "team". 50 Vibe Code Bench apps.
- Results:

  | Effort | Single | Team | Cost multiple |
  |---|---|---|---|
  | Medium | 91.5%, $4.08/app | 91.2%, $9.10 | 2.2x |
  | Max | 89.8%, $23.77 | 93.2%, $122 | 5.1x |

- Neither Opus difference was statistically significant. GPT 6 Sol at medium was the only significant team gain (+7.3 points, p=0.005, 2.5x cost).
- "Most of the extra spend was cached input": at Opus max effort, subagents read a median of 224M cached tokens per app, vs 17M for the lead and 55M for the single agent.

  Source: [Vals AI](https://www.vals.ai/blogs/multi-agent-vibe-code-bench)

**Anthropic C compiler (Feb 2026, Opus 4.6)**
- 16 parallel agents ran "nearly 2,000 Claude Code sessions" over two weeks, using 2 billion input and 140 million output tokens, for "just under $20,000". The result was a ~100,000-line Rust C compiler that builds Linux 6.9 on x86/ARM/RISC-V. Coordination used lock files in `current_tasks/` and git, with "no orchestration agent" — [Anthropic: Building a C compiler with a team of parallel Claudes](https://www.anthropic.com/engineering/building-c-compiler)
- Coverage noted the compiler produces inefficient code and is not a drop-in replacement — [The Register](https://www.theregister.com/2026/02/09/claude_opus_46_compiler/)

**Academic results**
- arXiv 2606.05670 ("Do More Agents Help?", v2 2026-10-09, GPT-4.1, 10 benchmarks): only EvoAgent beat the single-agent baseline (79.70% vs 76.65%, at 1.27x tokens). LLM-Debate used 1.39x tokens and scored 74.69%; ChatEval used 4.34x and scored 74.94%. "Higher token use did not reliably produce higher accuracy." — [arXiv 2606.05670](https://arxiv.org/html/2606.05670v2)
- The same paper's observational Claude Code case study on GAIA: the CC workflow reached 66.67% at ~53k tokens per instance, vs the Core baseline at 37.58% and ~460k. Budgets were not matched — [arXiv 2606.05670](https://arxiv.org/html/2606.05670v2)
- MAST: "Despite enthusiasm for Multi-Agent LLM Systems (MAS), their performance gains on popular benchmarks are often minimal" — [Cemri et al., arXiv 2503.13657](https://arxiv.org/abs/2503.13657)

**Cognition**
- June 2025: "Share context, and share full agent traces, not just individual messages"; "Actions carry implicit decisions, and conflicting decisions carry bad results"; recommends a single-threaded linear agent — [Cognition: Don't Build Multi-Agents (2025-06-12)](https://cognition.com/blog/dont-build-multi-agents)
- April 2026 follow-up: "writes stay single-threaded and the additional agents contribute intelligence rather than actions". The review agent (no shared context) catches "2 bugs per PR, of which roughly 58% are severe". Unstructured swarms are "mostly a distraction". "The open problems are all communication problems." — [Cognition: Multi-Agents: What's Actually Working (2026-04-22)](https://cognition.com/blog/multi-agents-working)

**Practitioner numbers**
- Yegge's own usage (secondary summary): 69 billion tokens in July (96% cache hits), ≈$87,000/month at API list price, vs ~$2,800/month in subscription accounts — [vanja.io](https://vanja.io/yegge-agent-city-four-claims/)
- Shogun author's estimate: "8 agents × Opus ~$100+/hour" via API vs "~$200/month" CLI flat rate — [multi-agent-shogun README](https://github.com/yohey-w/multi-agent-shogun)
- Third-party estimates, not measured:
  - a dev running 3 agents at $30–40/day; 5–10 agents at $50–130/day — [CloudZero (2026-05-18)](https://www.cloudzero.com/blog/claude-code-agents/);
  - a 3–4x rule of thumb for a 3-teammate team — [bestagent.dev (2026-06-09)](https://bestagent.dev/claude-code-agent-teams-worth-it-2026).

### Inferences
- Rule of thumb for budgeting:
  - subagents doing read-heavy side work can save main-context tokens, but add their own;
  - N parallel workers cost ≈ N× plus coordination;
  - agent teams in plan mode ≈ 7x;
  - max-effort Opus teams can reach 5x a comparable single agent and ~30x a medium-effort single agent, often with no significant quality gain.
- Because cached input dominates, the per-agent base context matters a lot: CLAUDE.md, MCP tool listings, skills, spawn prompt. A spawn costs about base context × number of turns × number of agents, discounted at cache-read rates.
- Spend is justified when work is breadth-first and independent: multi-angle review, competing-hypothesis debugging, research, many-file mechanical migrations. Clean verification oracles help (the C compiler used tests and GCC). Spend is not justified for sequential feature work on a shared file set.

### Gaps
- No controlled measurement of Claude Code agent teams proper (interactive, mailbox-based) vs single session on the same coding tasks was found. Vals AI tested headless subagents, because agent teams cannot run headless.
- No published measurement of the 7x figure's methodology.
- Subscription vs API economics differ hugely (Yegge's 30x figure), but these are self-reported.

## 4. Cost-control patterns

### Takeaway
The documented levers are:
- a strong orchestrator with cheaper workers (Sonnet/Haiku per agent definition or spawn prompt);
- context isolation, returning compact summaries or file references instead of transcripts;
- small teams (3–5) with right-sized tasks (5–6 per teammate);
- explicit caps: max depth, max concurrency, `--max-budget-usd` / `maxBudgetUsd`, workflow size guidelines, 1,000-agent run cap;
- prompt-cache sharing across identical sibling agents;
- shutting down idle teammates;
- moving orchestration into scripts (workflows) so intermediate results never touch an LLM context.

Cheap-primary-escalates-to-smart-model routing has mixed evidence. Cognition found the weak primary didn't know when to escalate.

### Cited Findings
**Official Claude Code guidance**
- Agent teams: "Use Sonnet for teammates", "Keep teams small", "Keep spawn prompts focused" (everything in the spawn prompt adds to the teammate's starting context), "Shut down teammates when their work is done" — [Costs](https://code.claude.com/docs/en/costs)
- Subagents: "For simple subagent tasks, specify `model: haiku`". Delegate verbose operations (tests, docs fetches, logs) "so the verbose output stays in the subagent's context while only a summary returns". Hooks can pre-filter output (e.g. grep test failures) "reducing context from tens of thousands of tokens to hundreds" — [Costs](https://code.claude.com/docs/en/costs)
- Team size: "Start with 3-5 teammates for most workflows … If you have 15 independent tasks, 3 teammates is a good starting point … Three focused teammates often outperform five scattered ones"; "Having 5-6 tasks per teammate keeps everyone productive" — [Agent teams](https://code.claude.com/docs/en/agent-teams)

**Prompt caching across agents**
- Workflow agents with the same model, effort, agent type, tools, schema and working directory share a cached prefix. Claude Code "holds all but the first until the first agent's response begins, then releases the held agents together so their first requests read the shared prefix instead of each processing it uncached" (`CLAUDE_CODE_WORKFLOW_PREFIX_STAGGER_MS`, default 5000) — [Dynamic workflows](https://code.claude.com/docs/en/workflows)
- Teammate and workflow-agent requests "fall outside the main conversation's cache TTL bucket, so its cache holds for five minutes by default". `subagentPromptCacheTtl: "1h"` keeps it longer; "The API bills 1-hour cache writes at a higher rate" — [Agent teams](https://code.claude.com/docs/en/agent-teams); [Dynamic workflows](https://code.claude.com/docs/en/workflows)

**Hard caps**
- Agent SDK: `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH` (default 3; 1 disables nesting), `CLAUDE_CODE_MAX_CONCURRENT_SUBAGENTS` (default 20), `maxBudgetUsd` (counts subagent requests and stops background subagents at the cap) — [Agent SDK subagents](https://code.claude.com/docs/en/agent-sdk/subagents)
- Workflows:
  - up to 16 concurrent agents by default;
  - "1,000 agents total per run — Prevents runaway loops";
  - `workflowSizeGuideline` values small (<5 agents), medium (<10, default) and large (<50);
  - "run the workflow on a small slice first";
  - `/workflows` shows per-agent token usage;
  - ask for "a smaller model for stages that don't need the strongest one".

  Source: [Dynamic workflows](https://code.claude.com/docs/en/workflows)

**Compact handoffs instead of transcripts**
- Anthropic's research system: "Subagents call tools to store their work in external systems, then pass lightweight references back to the coordinator" (avoids the "game of telephone"). The lead saves its plan to Memory because context over 200,000 tokens is truncated. Effort-scaling rules: 1 agent and 3–10 tool calls for simple tasks; 2–4 subagents for comparisons; >10 only for complex research — [Anthropic multi-agent research system](https://www.anthropic.com/engineering/multi-agent-research-system)
- Workflow `agent()` calls can take a JSON `schema`, so subagents return structured output instead of prose (up to 5 validation retries) — [Dynamic workflows](https://code.claude.com/docs/en/workflows)
- Agent Mail keeps messages in a per-project archive outside agents' context; agents fetch an inbox page (e.g. `limit=20`) on demand — [mcp_agent_mail README](https://github.com/Dicklesworthstone/mcp_agent_mail)
- Beads compaction ("memory decay") summarizes old closed tasks to save context — [beads README](https://github.com/steveyegge/beads)

**Avoiding hidden spend**
- Cross-session messages delivered to an idle session start a new turn "sending your full context each time". Set `crossSessionInbound` to `hold` to avoid this — [Costs](https://code.claude.com/docs/en/costs)
- With agent teams enabled, Claude may name subagents and they launch as teammates. Set `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=0` to stop it — [Agent teams](https://code.claude.com/docs/en/agent-teams)
- Opus 5 "delegates to subagents more readily", so set limits — [Agent SDK subagents](https://code.claude.com/docs/en/agent-sdk/subagents)

**Model routing evidence**
- Cognition's "smart friend" (SWE-1.5 primary escalating to Sonnet 4.5) underperformed: "SWE 1.5 was not good enough at being the primary model for this setup to really work". Cross-frontier Claude/GPT routing did work — [Cognition 2026](https://cognition.com/blog/multi-agents-working)
- Vals AI: raising reasoning effort is "a real alternative" to teams. For GPT 6 Sol, max effort alone raised the single-agent score 11.4 points (p<0.001) — [Vals AI](https://www.vals.ai/blogs/multi-agent-vibe-code-bench)
- Vendor routing claims (unverified): OMC "Smart model routing saves 30-50% on tokens" — [OMC README](https://github.com/Yeachan-Heo/oh-my-claudecode); Ruflo "Downgrade simple tasks to Haiku 80-92%" — [ruflo-cost-tracker](https://github.com/ruvnet/ruflo/tree/main/plugins/ruflo-cost-tracker); CloudZero estimates Opus orchestrator + Sonnet workers ≈40% cheaper than all-Opus — [CloudZero](https://www.cloudzero.com/blog/claude-code-agents/)

**Context hygiene for parallel workers (C compiler)**
- Print few lines; log to files with `ERROR` + reason on one line; `--fast` 1%/10% deterministic per-agent test sampling; extensive READMEs and progress files, because "each agent starts with no context" — [Anthropic C compiler](https://www.anthropic.com/engineering/building-c-compiler)

### Inferences
- The highest-leverage control is choosing the cheapest coordination primitive that works:
  - one session + Haiku/Sonnet subagents for read-heavy side work;
  - a workflow script for fan-out/fan-in (results stay in variables and siblings share cache);
  - an agent team only when mid-task peer discussion is the point.
- Chatty peer-to-peer messaging is expensive by construction: each delivered message is a model turn over the receiver's full context. Prefer task-board state changes (claim/complete), files, and one final summary over conversational messages.
- Keep base context small for every agent: a CLAUDE.md under 200 lines, specialized instructions in skills, unused MCP servers disabled, `omitClaudeMd` for narrow workers. This is multiplied by N agents.

### Gaps
- No measured A/B of Haiku-workers vs Sonnet-workers inside Claude Code agent teams was found.
- No quantification of the cache-sharing savings from the workflow prefix stagger.

## 5. Non-blocking coordination: worktrees, file leases, task claiming, merging and review

### Takeaway
The proven non-blocking patterns are:
- one git worktree, container or clone per writing agent (subagent `isolation: worktree`, `/batch`, agent view, workflows' "isolated copy", Gas Town hooks, C-compiler containers);
- atomic task claiming on a shared board (native task list with file locking, `bd update --claim`, lock files in `current_tasks/`);
- advisory file leases with TTL plus a pre-commit guard (Agent Mail);
- a single integration point: merge queue with test gates (Gas Town Refinery, C-compiler CI), or a lead/human reviewer.

Native agent teams lack worktree isolation, so file ownership must be partitioned by hand.

### Cited Findings
**Worktree isolation**
- Subagent `isolation: worktree` "runs the subagent in a temporary git worktree", cleaned up automatically if no changes are made — [Subagents](https://code.claude.com/docs/en/sub-agents)
- Agent-view sessions move into their own worktree before editing; "Agent teams don't isolate teammates in worktrees" — [Run agents in parallel](https://code.claude.com/docs/en/agents)
- Workflow example: "migrate every component … working on each file in its own isolated copy" — [Dynamic workflows](https://code.claude.com/docs/en/workflows)

**Task claiming and leases**
- Native task claiming "uses file locking to prevent race conditions"; dependent tasks unblock automatically; "Agents without the Task tools coordinate through messages instead" — [Agent teams](https://code.claude.com/docs/en/agent-teams)
- C compiler: each agent works in its own Docker container cloned from a bare upstream repo. An agent claims a task by writing `current_tasks/<task>.txt`; "git's synchronization makes the second pick a different one". It then pulls, merges, pushes and removes the lock. Merge conflicts were frequent, but the agents resolved them themselves (paraphrased from a summary of the post; exact wording not captured) — [Anthropic C compiler](https://www.anthropic.com/engineering/building-c-compiler)
- Agent Mail: `file_reservation_paths(project_key, agent_name, ["src/**"], ttl_seconds=3600, exclusive=true)`; the "pre-commit guard can block commits that conflict with others' active exclusive file reservations"; on `FILE_RESERVATION_CONFLICT`, "adjust patterns, wait for expiry, or use a non-exclusive reservation" — [mcp_agent_mail README](https://github.com/Dicklesworthstone/mcp_agent_mail)
- Agent Farm: `active_work_registry.json` + per-agent lock files; agents "Queue work if their preferred files are locked" and handle "stale locks (>2 hours old)" — [claude_code_agent_farm README](https://github.com/Dicklesworthstone/claude_code_agent_farm)

**Integration and review**
- Gas Town Refinery: "batches merge requests, runs verification gates, and merges to main using a Bors-style bisecting queue" — [gastown README](https://github.com/steveyegge/gastown)
- Yegge (Aug 2026, secondary summary): "Once commit rate outruns build capacity, one-commit-per-green-build stops scaling", hence "Megabatch landings, red main, and roll-forward repair" — [vanja.io](https://vanja.io/yegge-agent-city-four-claims/)
- Review: Cognition's reviewer "works best when the coding and review agents do not share any context beforehand" (clean-context diff review) — [Cognition 2026](https://cognition.com/blog/multi-agents-working)
- Native hooks `TaskCompleted` / `TeammateIdle` can enforce quality gates, with exit code 2 blocking completion — [Agent teams](https://code.claude.com/docs/en/agent-teams)

**Asynchronous signaling**
- Cross-session messages are read "between tool calls … so a running tool is never interrupted". `notify_when_idle` sends one notice without spending tokens in the watched session. The docs list "Coordinate parallel worktrees" (telling other sessions what landed) as a use case — [Cross-session messaging](https://code.claude.com/docs/en/cross-session-messaging)

### Inferences
- A minimal, robust stack for a small team combines four things:
  - worktree per writer;
  - Beads (or the native task list) for claim/complete with dependencies;
  - optional Agent Mail leases when agents must share a tree;
  - a merge queue or CI gate as the sole path to main.
- Leases are advisory in Agent Mail and in the native docs (partitioning). Real protection comes from worktrees plus a gated merge.
- Review is the bottleneck. A clean-context reviewer agent plus CI shifts human review to final integration rather than per-agent output.

### Gaps
- No quantified merge-conflict rates or rework percentages for worktree-based swarms were found. The C compiler reports conflicts as "frequent" without numbers.

## 6. Reported failure modes

### Takeaway
Recurring failures:
- duplicated work, where agents converge on the same obvious bug;
- conflicting edits and overwrites;
- inconsistent implicit decisions (style or assumptions) across parallel writers;
- context gaps from not inheriting the lead's history (the telephone game);
- over-spawning (50 subagents for a simple query);
- leads that stop early or do the work themselves;
- stale task status blocking dependents;
- idle agents burning tokens;
- harness self-tinkering loops (Gas Town with Opus 4.7);
- review/integration bottlenecks and regressions.

The most aggressive swarm practitioners publicly scaled back in 2026.

### Cited Findings
**Duplication, overwrites and regressions**
- C compiler: "every agent hit the same bug, fixed it, and overwrote the others' changes. Running 16 agents didn't help". Other problems: regressions where "new features often broke existing functionality" (fixed by adding CI), and duplicated code (fixed by adding a dedicated dedup agent) — [Anthropic C compiler](https://www.anthropic.com/engineering/building-c-compiler)
- Anthropic research system: early agents were "spawning 50 subagents for simple queries", and subagents "duplicated work" on the same topic — [Anthropic multi-agent research system](https://www.anthropic.com/engineering/multi-agent-research-system)

**Inconsistent decisions and context gaps**
- Cognition: the Flappy Bird split produced a Mario-style background and a mismatched bird — conflicting implicit decisions — [Cognition 2025](https://cognition.com/blog/dont-build-multi-agents)
- Cognition 2026: "Agents assume they share state with their children when they don't"; cross-agent communication "doesn't happen by default"; managers become overly prescriptive (latter per ZenML summary) — [Cognition 2026](https://cognition.com/blog/multi-agents-working); [ZenML summary](https://www.zenml.io/llmops-database/multi-agent-systems-in-production-code-generation-and-review-at-scale)

**Native agent-team issues**
- Official troubleshooting list:
  - "Task status can lag: teammates sometimes fail to mark tasks as completed, which blocks dependent tasks";
  - "The lead can stop early";
  - the lead "starts implementing tasks itself instead of waiting";
  - teammates "may stop after encountering errors";
  - no resumption of in-process teammates;
  - "Letting a team run unattended for too long increases the risk of wasted effort".

  Source: [Agent teams](https://code.claude.com/docs/en/agent-teams)
- Practitioners:
  - a 3-agent team's cost "jump[ed] fast" once agents shared context;
  - contradictory instruction files were a bigger failure than agent errors;
  - tmux/iTerm split panes were finicky.

  Source: [Push To Prod, 30 Tips (2026-03-21)](https://getpushtoprod.substack.com/p/30-tips-for-claude-code-agent-teams)
- "a five-teammate debugging session burns through tokens fast"; sequential or same-file work is "token theater" — [bestagent.dev](https://bestagent.dev/claude-code-agent-teams-worth-it-2026)

**Runaway loops and retreats**
- Runaway loops: Gas Town "fell apart at the seams with Opus 4.7" because of a "just two more things" tic that kept the model from converging on real work. The harness was only ever used "to build itself" — [Yegge](https://yegge.ai/essays/the-shape-of-things-to-come/) via [Simon Willison](https://simonwillison.net/2026/Aug/4/steve-yegge/)
- Built-in loop guards: the workflow runtime caps runs at 1,000 agents; cross-session messaging drops identical repeats and caps queues at 50 — [Dynamic workflows](https://code.claude.com/docs/en/workflows); [Cross-session messaging](https://code.claude.com/docs/en/cross-session-messaging)
- Retreat: the Shogun author "disbanded his own 10-agent army down to a single agent that carries his judgment" (Aug 2026) — [multi-agent-shogun README](https://github.com/yohey-w/multi-agent-shogun)

**Taxonomy**
- MAST: 14 failure modes in 3 categories (system design issues, inter-agent misalignment, task verification), from 1,600+ annotated traces across 7 multi-agent frameworks (kappa 0.88) — [arXiv 2503.13657](https://arxiv.org/abs/2503.13657)

### Inferences
- Most failures trace to three causes: shared mutable state (files, main branch), missing shared context (implicit decisions), and weak verification. Swarm size makes all three worse.
- Mitigations map one-to-one:
  - isolate writes (worktrees, single-threaded writes);
  - share the decision record (plan / ADR / task graph in files, a full spec in spawn prompts);
  - add oracles and gates (tests, CI, a clean-context reviewer);
  - cap spawning and runtime.

### Gaps
- No large-sample statistics on duplicate-work rates or wasted-token percentages in coding swarms. Evidence is case studies and anecdotes.

## 7. Recommended starter architecture for a small team (collaborating agents without token burn)

### Takeaway
Start with "one writer, many readers": a single main Claude Code session (Opus or Sonnet) that owns all writes. It is supported by read-only or verbose-work subagents on Haiku/Sonnet, plus a clean-context reviewer subagent. Escalate in steps:
1. worktree-isolated parallel writers for clearly independent tasks, coordinated by a shared Beads/task board and a CI-gated merge;
2. dynamic workflows for big fan-outs with small size guidelines;
3. agent teams only for research/review/debate tasks where peer discussion is the value.

Always set budget, depth and concurrency caps.

### Cited Findings (evidence underpinning each choice)
- Single-threaded writes, extra agents adding "intelligence rather than actions"; a clean-context reviewer finds ~2 bugs/PR, 58% severe — [Cognition 2026](https://cognition.com/blog/multi-agents-working)
- Subagents keep verbose output out of main context; use `model: haiku` for simple subagents; Sonnet for teammates — [Costs](https://code.claude.com/docs/en/costs)
- Start teams with research and review: "tasks that have clear boundaries and don't require writing code"; 3–5 teammates; partition file ownership — [Agent teams](https://code.claude.com/docs/en/agent-teams)
- Workflows for fan-out with results kept in script variables; size guideline small (<5) / medium (<10); test on a small slice; 1,000-agent cap — [Dynamic workflows](https://code.claude.com/docs/en/workflows)
- Caps: depth=1, concurrency=5, `max_budget_usd=5` example — [Agent SDK subagents](https://code.claude.com/docs/en/agent-sdk/subagents)
- Task graph with atomic claims and dependency-aware "ready" work — [beads README](https://github.com/steveyegge/beads)
- Optional leases and mailbox outside context — [mcp_agent_mail README](https://github.com/Dicklesworthstone/mcp_agent_mail)
- Teams gain most "when work splits into parts that can run side by side without coordination eating the time saved"; higher effort on a single agent is an alternative — [Vals AI](https://www.vals.ai/blogs/multi-agent-vibe-code-bench)
- Parallel agents need near-perfect verifiers, progress files and concise test output — [Anthropic C compiler](https://www.anthropic.com/engineering/building-c-compiler)

### Inferences (proposed starter setup, derived from the findings above)
- **Tier 0 (default, cheapest).** One main session on Sonnet; Opus only for planning or architecture. Project subagents in `.claude/agents/`:
  - `explorer`: read-only, `model: haiku`. Also override the built-in `Explore` with `model: haiku`.
  - `test-runner`: Bash/Read, haiku or sonnet; returns failures only.
  - `reviewer`: read-only, sonnet; sees only the diff or branch, not the history.

  Keep CLAUDE.md short and put specialized knowledge in skills. Leave `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` unset, so named subagents don't silently become teammates.
- **Tier 1 (parallel writers, non-blocking).** For 2–4 independent tickets, use worktree-isolated sessions or subagents (`isolation: worktree`, agent view, or `/batch` for mechanical changes). Keep a shared task graph (Beads `bd ready` / `bd update --claim`) as the blackboard. Agents post compact status via cross-session messaging, or simply update the task, rather than chatting. Integration goes through PRs with CI and the clean-context reviewer. Humans review only at merge.
- **Tier 2 (big fan-out).** For audits or N-file migrations, use a dynamic workflow with `workflowSizeGuideline=small|medium`, a smaller model per stage, structured `schema` outputs, a pilot slice first, and `CLAUDE_CODE_WORKFLOW_MAX_CONCURRENT_AGENTS` tuned to rate limits.
- **Tier 3 (agent teams, opt-in per task).** Use for multi-lens review, competing-hypothesis debugging and research. Settings: 3 Sonnet teammates, read-only or disjoint file ownership, `TaskCompleted` hooks to require tests, and shut down when done. Budget about 3–7x a single session.
- **Guardrails everywhere:**
  - `--max-budget-usd` (CLI) or `maxBudgetUsd` (SDK);
  - `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH=1–2`;
  - `CLAUDE_CODE_MAX_CONCURRENT_SUBAGENTS≈5`;
  - `crossSessionInbound=hold` for sessions that should not be woken;
  - `/usage` attribution to watch the subagent share;
  - `subagentPromptCacheTtl=1h` only for long-running workers that are reused within the hour.
- **Avoid for now:** heavyweight hive-mind/consensus harnesses whose cost claims are self-reported or self-disclaimed (Ruflo, OMC routing claims), and 10–30-agent "towns". Their two most prominent practitioners (Gas Town, Shogun) publicly scaled back in 2026.

### Gaps
- None of these tiers has been benchmarked end-to-end for cost vs a single agent on a small team's real workload. Teams should pilot with `/usage` attribution or OpenTelemetry before standardizing.
