# Persistent memory & knowledge management for AI coding agents (Claude Code focus) — state as of 19 Oct 2026

Method note: GitHub numbers (stars, last commit, latest release + date, license) come from shields.io JSON endpoints (`https://img.shields.io/github/{stars|last-commit|v/release|release-date|license}/OWNER/REPO.json`) fetched 2026-10-19 (a Monday). Shields reports relative dates: "today" = 2026-10-19, "yesterday" = 10-18, "last Wed/Thu/Fri/Sat/Tue" = ~10-14/15/16/17/13; a month name without year = 2026. README facts come from `raw.githubusercontent.com/OWNER/REPO/HEAD/README.md` fetched the same day. Vendor claims (benchmarks, token savings) are labelled as such. api.github.com/gh was not used (blocked).

## 1. Native options: CLAUDE.md hierarchy & imports, rules, auto memory, /memory, subagent memory, Anthropic API memory tool — what exists and how well it works

### Takeaway
Claude Code now ships a complete, file-based, git-friendly memory stack: hierarchical CLAUDE.md (or AGENTS.md since v2.1.277) + `.claude/rules/` with path-scoped loading + on-by-default auto memory (`MEMORY.md` index + topic files, machine-local) + per-subagent memory (project scope is git-shareable). It is transparent and cheap, but it is advisory context, not enforcement, and it decays (stale/contradictory entries) unless humans prune it; Anthropic's API "memory tool" is only relevant if you build your own agents.

### Cited Findings
**CLAUDE.md hierarchy & loading**
- Two mechanisms: CLAUDE.md (you write; instructions) and auto memory (Claude writes; learnings); both loaded at session start; "Claude treats them as context, not enforced configuration. To block an action regardless of what Claude decides, use a PreToolUse hook." — [Claude Code docs: memory](https://code.claude.com/docs/en/memory)
- Scopes in load order: managed policy (`/etc/claude-code/CLAUDE.md` Linux/WSL, `/Library/Application Support/ClaudeCode/CLAUDE.md` macOS, `C:\Program Files\ClaudeCode\CLAUDE.md` Windows; cannot be excluded) → user `~/.claude/CLAUDE.md` → project `./CLAUDE.md` or `./.claude/CLAUDE.md` ("Team members via source control") → local `./CLAUDE.local.md` (gitignored, personal). Managed content can also be set via `claudeMd` key in managed-settings.json. — [memory docs](https://code.claude.com/docs/en/memory)
- Files above the working dir load at launch and are concatenated (not overriding), root → cwd; subdirectory CLAUDE.md files load lazily when Claude reads/writes a file in that subdirectory; `claudeMdExcludes` skips files in monorepos; `--add-dir` dirs' CLAUDE.md only load with `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1`. — [memory docs](https://code.claude.com/docs/en/memory)
- `@path` imports: relative to the importing file, recursive max depth 4 hops; imports outside the working dir ("external") trigger a one-time approval dialog; "Imports help you organize a long file but don't reduce its context cost". Block-level HTML comments are stripped before injection (free maintainer notes). — [memory docs](https://code.claude.com/docs/en/memory)
- Size: "target under 200 lines per CLAUDE.md file. Longer files consume more context and reduce adherence"; files up to 4 MiB load in full, larger are skipped; startup warning when a file exceeds recommended length or files exceed a combined limit. — [memory docs](https://code.claude.com/docs/en/memory)
- "If two instructions contradict each other, Claude may pick one arbitrarily." `/doctor prompt-audit` (v2.1.283+) reports outdated instructions, references to non-existent files/commands and contradictions across CLAUDE.md/AGENTS.md/rules/skills, proposing edits; `/doctor` proposes trimming content Claude can derive from the codebase. — [memory docs](https://code.claude.com/docs/en/memory)
- AGENTS.md read natively (v2.1.277+) when no CLAUDE.md/CLAUDE.local.md exists; "Project instructions" setting: `claude-md-or-agents-md` (default) / `claude-md-and-agents-md` / `claude-md` / `managed-only`; `@AGENTS.md` import recommended for one-file-for-all-tools (symlink breaks on Windows). — [memory docs](https://code.claude.com/docs/en/memory)
- Project-root CLAUDE.md is re-read and re-injected after `/compact`; nested CLAUDE.md and path-scoped rules reload on demand; conversation-only instructions are lost on compaction. — [memory docs](https://code.claude.com/docs/en/memory)

**Rules directory**
- `.claude/rules/**/*.md` (recursive); rules without `paths` frontmatter load at launch like `.claude/CLAUDE.md`; with `paths:` globs they load only when Claude Reads/Writes/Edits (or `cat`s) a matching file; `paths` is the only frontmatter field read; user-level `~/.claude/rules/`; symlinks supported (external targets need approval); user vs project rule conflict: "Claude may follow either one". Rules support added in v2.0.64. — [memory docs](https://code.claude.com/docs/en/memory); [Claude Code CHANGELOG](https://raw.githubusercontent.com/anthropics/claude-code/HEAD/CHANGELOG.md)

**Auto memory & /memory**
- Introduced v2.1.59 ("Claude automatically saves useful context to auto-memory. Manage with /memory"); shared across git worktrees since v2.1.63; `autoMemoryDirectory` since v2.1.74; 25KB cap added v2.1.83; over-limit writes return explicit error since v2.1.210; v2.1.284 neutralizes "invisible characters and tags that imitate Claude Code's own markup" in MEMORY.md and recalled notes (injection hardening). Latest changelog version seen: 2.1.304. — [CHANGELOG](https://raw.githubusercontent.com/anthropics/claude-code/HEAD/CHANGELOG.md)
- On by default in local sessions; four memory types in frontmatter `type`: `user`, `feedback`, `project`, `reference`; "Claude skips anything it can derive from the codebase, such as architecture, file paths, or debugging fixes. It also skips anything your CLAUDE.md files already say." — [memory docs](https://code.claude.com/docs/en/memory)
- Storage `~/.claude/projects/<project>/memory/` = `MEMORY.md` index (one line per memory) + topic files; per git repo (shared across worktrees); "Auto memory is machine-local ... Files are not shared across machines or cloud environments." Only first 200 lines or 25KB of MEMORY.md load each session; topic files are read on demand. Claude Code stamps a `modified` ISO-8601 timestamp into memory frontmatter on write. Memory files are excluded from the `cleanupPeriodDays` transcript sweep. — [memory docs](https://code.claude.com/docs/en/memory)
- Toggle via `/memory` (writes `autoMemoryEnabled`), per-project `"autoMemoryEnabled": false`, or `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1`. "Remember X" requests go to auto memory; "add this to CLAUDE.md" goes to CLAUDE.md. `/memory` lists all memory files and opens them in your editor; `/context` shows which loaded. — [memory docs](https://code.claude.com/docs/en/memory)
- Auto memory is not loaded into subagents (except forks). — [memory docs](https://code.claude.com/docs/en/memory)

**Subagent memory**
- Subagent frontmatter `memory: user | project | local` (added v2.1.33) → `~/.claude/agent-memory/<agent>/`, `.claude/agent-memory/<agent>/` (git-shareable), `.claude/agent-memory-local/<agent>/`; first 200 lines/25KB of that MEMORY.md injected; Read/Write/Edit auto-enabled; "`project` is the recommended default scope. It makes subagent knowledge shareable via version control." Disabled when auto memory is off. — [sub-agents docs](https://code.claude.com/docs/en/sub-agents); [CHANGELOG](https://raw.githubusercontent.com/anthropics/claude-code/HEAD/CHANGELOG.md)

**Cloud "Projects" memory**
- Claude Code Projects (cloud threads) have their own project memory (MEMORY.md index + files Claude writes) and project instructions (≤16,000 chars), separate from local auto memory; public beta on Pro/Max, "not available on Team or Enterprise plans yet"; locally-run Remote Control threads don't load project memory files. — [Claude Code docs: Projects](https://code.claude.com/docs/en/claude-projects)

**Anthropic API memory tool (for teams building their own agents)**
- `{"type": "memory_20250818", "name": "memory"}`, all Claude 4+ models, no beta header required; client-side: Claude issues `view/create/str_replace/insert/delete/rename` under `/memories` and *your* code stores it (files, DB, encrypted); Python/TS SDKs ship `BetaLocalFilesystemMemoryTool`. API auto-adds a system prompt "ALWAYS VIEW YOUR MEMORY DIRECTORY BEFORE DOING ANYTHING ELSE ... ASSUME INTERRUPTION". You must implement path-traversal protection, size caps, expiry of unused files, sensitive-data stripping; `view` truncates >16,000 chars. Pairs with context editing and server-side compaction; recommends a "multisession software development pattern" (initializer session writes progress log + feature checklist; each session reads then updates). — [Claude API docs: memory tool](https://platform.claude.com/docs/en/agents-and-tools/tool-use/memory-tool)

**How well it works (evidence of decay)**
- Third-party analyses describe typical auto-memory decay over many sessions: contradictory entries (e.g., "uses PostgreSQL" vs later "migrated to MySQL"), outdated debugging notes, relative dates like "yesterday"; entries truncated out of the 200-line index never load. — [mem0 library article](https://mem0.ai/library/coding-agents/how-memory-works-in-claude-code); [Milvus blog](https://milvus.io/blog/claude-code-memory-memsearch.md) (both are vendors of competing memory products)
- "Auto Dream" (automatic memory consolidation) is described in several blogs ([claudefa.st](https://claudefa.st/blog/guide/mechanics/auto-dream), [MindStudio](https://www.mindstudio.ai/blog/what-is-claude-code-autodream-memory-consolidation)) but does not appear in the official memory docs or in the CHANGELOG through v2.1.304 — [CHANGELOG](https://raw.githubusercontent.com/anthropics/claude-code/HEAD/CHANGELOG.md).
- Critique of auto memory: "you can't search what it chose not to write down" (selective writes); per-tool silo (Cursor doesn't read it). — [DEV: CLAUDE.md vs a memory MCP (author sells Kireo memory MCP)](https://dev.to/wang1051992187/claudemd-vs-a-memory-mcp-what-actually-goes-where-438n)

### Inferences
- For a team new to memory tooling, the native stack already covers ~80% of needs: shared conventions (CLAUDE.md/rules in git), personal preferences (`~/.claude/CLAUDE.md`, CLAUDE.local.md), automatic personal learnings (auto memory), and specialised shared learnings (project-scoped subagent memory). Every artifact is plain Markdown, reviewable and diffable.
- Token cost of native memory is predictable and bounded: everything in CLAUDE.md + unscoped rules + imports every session; MEMORY.md capped at 25KB (≈6k tokens, estimate at ~4 chars/token); path-scoped rules and topic files cost nothing until touched.
- Weak spots: auto memory is per-machine and per-person (not team knowledge), has no semantic search over past sessions, and relies on Claude's judgement of what to save; staleness is mitigated only by `modified` timestamps, `/doctor prompt-audit` (for instruction files) and manual pruning.
- Anthropic's API memory tool is not a Claude Code feature to "turn on"; it matters only if the team builds agents on the API/Agent SDK.

### Gaps
- No official or independent measurement of auto memory's effect on task success or cost was found.
- "Auto Dream" consolidation: unverified; possibly unreleased/feature-flagged.
- Changelog v2.1.172 mentions "mounted team memory stores (`CLAUDE_MEMORY_STORES`) in remote sessions" and Managed Agents "memory stores"; no documentation found describing a team memory store for local CLI users.

## 2. Obsidian-based setups: MCP servers, vault as second brain, popular workflows, setup patterns & pitfalls

### Takeaway
In 2026 there are three viable ways to connect Claude Code to an Obsidian vault: (a) simplest and most popular — run Claude Code *in* the vault folder (plain Markdown files + a root CLAUDE.md, optionally Obsidian's official Agent Skills / official CLI); (b) MCP: the Local REST API plugin now has a built-in MCP endpoint, or a filesystem-based server (mcpvault) that doesn't need Obsidian running; (c) add local search (qmd) when the vault outgrows grep. Main pitfalls: Obsidian must be running for REST/CLI routes, sync conflicts, stale third-party bridges, and treating a personal vault as team memory.

### Cited Findings
**Workflows / patterns**
- Kenneth Reitz (6 Mar 2026): Claude Code pointed at a 467-file iCloud-synced PARA vault with a ~200-line root CLAUDE.md defining conventions (wikilinks, required frontmatter `type`/`status`/`date`) and prohibitions ("no new files unless asked", "no restructuring folder hierarchies"); Obsidian Git plugin for versioning; "Claude proposes, you dispose". — [Reitz essay](https://kennethreitz.org/essays/2026-03-06-obsidian_vaults_and_claude_code)
- Karpathy's "LLM Wiki / LLM Knowledge Bases" pattern (X post + gist, early Apr 2026): raw sources (Obsidian Web Clipper) in `raw/` → LLM compiles an interlinked Markdown wiki with summaries and index files → read it in Obsidian; periodic LLM "lint"/health checks for inconsistencies; at ~100 articles / ~400k words navigation via index files is enough without RAG; "You rarely ever write or edit the wiki manually; it's the domain of the LLM." — [VentureBeat, 3 Apr 2026](https://venturebeat.com/data/karpathy-shares-llm-knowledge-base-architecture-that-bypasses-rag-with-an)
- 2026 "Claude + Obsidian second brain" guides converge on: launch Claude Code from the vault dir, CLAUDE.md at root (optionally per-subfolder), human review loop; the Claudian plugin puts a Claude panel inside Obsidian; pitfall: sync conflicts when Claude edits notes while Obsidian Sync or git-sync is active (workaround: Claude for read-heavy work). — [CodeWithSeb guide](https://www.codewithseb.com/blog/claude-code-obsidian-second-brain-guide); [obsidianmate](https://obsidianmate.com/article/obsidian-second-brain-claude-code) (search-summary level; not individually deep-verified)
- Memory caveat in guides: neither CLAUDE.md nor auto memory indexes the vault; a `memory.md` in a vault is not Claude Code's auto memory. — [obsidianmate](https://obsidianmate.com/article/obsidian-second-brain-claude-code) (via search summary)

**Official Obsidian building blocks**
- kepano/obsidian-skills (Obsidian CEO Steph Ango): Agent Skills `obsidian-markdown`, `obsidian-bases`, `json-canvas`, `obsidian-cli`, `defuddle`, `knap`; install `/plugin marketplace add kepano/obsidian-skills` + `/plugin install obsidian@obsidian-skills`, or copy into the vault's `.claude/` folder. ~50k stars, MIT, last commit Sep 2026, no GitHub releases. — [README](https://github.com/kepano/obsidian-skills); [shields stars](https://img.shields.io/github/stars/kepano/obsidian-skills.json)
- Official Obsidian CLI: requires Obsidian 1.12 installer (recommends ≥1.12.7); the app must be running (CLI connects to it; first command launches it); enable in Settings → General → "Command line interface"; commands `search`, `read`, `create`, `append/prepend`, `daily:*`, `tasks`, `property:set/read`, `tags`, `backlinks`, `move/rename/delete`, `bases`, dev `eval`; "allow agentic coding tools to automatically test and debug"; Obsidian Headless for sync without the desktop app. — [Obsidian help: CLI](https://obsidian.md/help/cli)

**MCP servers (all numbers from shields.io on 2026-10-19 + READMEs)**
- coddingtonbear/obsidian-local-rest-api — Obsidian community plugin, ~3k stars, MIT, v5.5.2 (~2026-10-17). Now "Local REST API with MCP": built-in MCP server at `https://127.0.0.1:27124/mcp/` (local self-signed CA; optional plain HTTP `http://127.0.0.1:27123/mcp/`), bearer API key; `claude mcp add --transport http obsidian https://127.0.0.1:27124/mcp/ --header "Authorization: Bearer <key>"`; CRUD, surgical heading/block/frontmatter PATCH, JsonLogic search, SSE vault events, command execution. — [README](https://github.com/coddingtonbear/obsidian-local-rest-api)
- MarkusPfundstein/mcp-obsidian — ~4.5k stars, MIT, Python, no GitHub releases, last commit Aug 2026; bridges to the REST plugin; 7 tools (list_files_in_vault, list_files_in_dir, get_file_contents, search, patch_content, append_content, delete_file); env `OBSIDIAN_API_KEY/HOST/PORT`; README: pinned `mcp<2.0` because with `mcp>=2.0` it "will crash at import"; "Sometimes Claude has issues detecting the location of uv/uvx"; "Its good to first instruct Claude to use Obsidian". — [README](https://github.com/MarkusPfundstein/mcp-obsidian)
- cyanheads/obsidian-mcp-server — ~698 stars, Apache-2.0, v3.7.0 (Oct 2026); via REST plugin; 14 tools + 3 resources; section/block/frontmatter edits, tag management, BM25 via Omnisearch plugin if present; folder-scoped read/write permissions (`OBSIDIAN_READ_PATHS`), delete-confirmation elicitation, command execution opt-in; stdio or Streamable HTTP. — [README](https://github.com/cyanheads/obsidian-mcp-server)
- bitbonsai/mcpvault (formerly bitbonsai "mcp-obsidian") — ~1.7k stars, MIT, last commit Oct 2026 (npm-distributed, no GH releases); works directly on vault files (no REST plugin, Obsidian need not run), restricts operations to vault root, preserves frontmatter formatting; `npx @bitbonsai/mcpvault@latest /path/to/vault`; Node ≥20. — [README](https://github.com/bitbonsai/mcpvault)
- Others: StevenStavrakis/obsidian-mcp (~742 stars, v2.0.0 Aug 2026); jacksteamdev/obsidian-mcp-tools (~829 stars, last release/commit May 2026); aaronsb/obsidian-mcp-plugin (~466 stars, v0.12.9 Sep 2026; MCP inside an Obsidian plugin); iansinnott/obsidian-claude-code-mcp (~355 stars, last commit/release Jun 2025 → **stale**). — shields.io endpoints for each repo (e.g. [stars](https://img.shields.io/github/stars/iansinnott/obsidian-claude-code-mcp.json), [last-commit](https://img.shields.io/github/last-commit/iansinnott/obsidian-claude-code-mcp.json))

**Search layer**
- tobi/qmd (Tobi Lütke) — ~30k stars, MIT, v2.8.3 (Aug 2026), last commit ~2026-10-15: on-device search over Markdown collections: BM25 + vector + LLM rerank (query expansion, HyDE, RRF) via node-llama-cpp; three GGUF models auto-downloaded (embeddinggemma-300M ~300MB, qwen3-reranker-0.6b ~640MB, qmd-query-expansion-1.7B ~1.1GB) cached in `~/.cache/qmd/models/`; CLI + MCP; Claude Code plugin `claude plugin marketplace add tobi/qmd` / `claude plugin install qmd@qmd`; HTTP daemon keeps models loaded. — [README](https://github.com/tobi/qmd)
- basic-memory: "Obsidian — No setup. Point Obsidian at ~/basic-memory (or your project folder)" — AI and human edit the same Markdown. — [README](https://github.com/basicmachines-co/basic-memory)

### Inferences
- Lowest-friction, most robust pattern for developers: keep the vault as plain Markdown in git (Obsidian Git or plain git), and either run Claude Code inside it or reference it from projects via `--add-dir` / `@~/vault/...` imports (external imports need one-time approval). No MCP server needed for read/write; add qmd only when grep stops being enough.
- If an MCP route is wanted: prefer the Local REST API plugin's *built-in* MCP (one component, maintained, v5.5.2 this month) or mcpvault (no running app); the older Python bridge (mcp-obsidian) is pinned to MCP SDK 1.x and is more fragile.
- Obsidian vaults are a natural *personal* cross-project knowledge base (decisions, snippets, research, journals). They are not a substitute for project memory that teammates need — that belongs in the repo.
- Main pitfalls to plan for: Obsidian-must-be-running (REST/CLI), self-signed certs, concurrent edits vs. Obsidian Sync/iCloud, agent restructuring the vault (mitigate with CLAUDE.md prohibitions + git), privacy of personal notes being sent to the model, MCP tool-schema overhead (cyanheads exposes 14 tools).

### Gaps
- Obsidian forum threads and Obsidian community-plugin stats (download counts) were not reviewed directly.
- No measured comparison of "Claude in vault folder" vs MCP access (token cost, accuracy) found.
- The Claudian plugin and "claude-obsidian" plugin were not verified (stars/maintenance unknown).

## 3. Dedicated memory tools: mechanism, install, privacy, stars, activity, token cost, maturity, failure modes

### Takeaway
The field split into (a) **file/markdown-first** tools that stay git-reviewable (basic-memory, Serena memories, Cline-style memory bank, official MCP knowledge-graph server), (b) **automatic capture + vector/LLM** systems that hook every session (claude-mem, MemPalace, Hindsight, OpenViking, mcp-memory-service, episodic-memory for transcripts), (c) **general agent-memory platforms** better suited to building products than to daily coding (mem0, Letta, Zep/Graphiti, Cognee, Supermemory), and (d) **task memory** (beads). Star counts are huge and partly hype-driven; several leaders are monetising via hosted tiers; vendor benchmarks (LongMemEval/LoCoMo) measure chat recall, not coding outcomes.

### Cited Findings
**Snapshot table (shields.io, 2026-10-19; licence per shields; "n/r" = no GitHub releases)**

| Tool (repo) | Mechanism | Local vs cloud | Stars | Last commit | Latest release (date) | License |
|---|---|---|---|---|---|---|
| claude-mem (thedotmack/claude-mem) | hooks capture tool use → LLM-compressed "observations" → SQLite FTS5 + Chroma; MCP search | local worker; default sign-in to hosted observer (trial) | 102k (GitHub page: 101.8k) | 10-19 | v14.0.1 (~10-17) | Apache-2.0 |
| basic-memory (basicmachines-co) | Markdown + wikilinks KG, SQLite/Postgres index, FastEmbed hybrid search; MCP | local free; cloud $15/mo | 4.3k | 10-19 | v0.23.2 (Aug) | AGPL-3.0 |
| beads (steveyegge → gastownhall/beads) | Dolt (versioned SQL) issue graph + `bd remember` | local, sync via git remote | 28k | 10-19 | v1.3.1 (Sep) | MIT |
| episodic-memory (obra) | archives transcripts; local Transformers.js embeddings + SQLite(-vec); Haiku summaries | local (summaries via your Claude auth) | 492 | Sep | v1.6.0 (Sep) | MIT |
| MemPalace (milla-jovovich → MemPalace/mempalace) | verbatim conversation storage, ChromaDB, "wings/rooms/drawers" | local; optional shared hub | 60k | 10-18 | v3.11.0 (~10-14) | MIT |
| Hindsight (vectorize-io) | retain/recall/reflect, observations, mental models; Postgres server + LLM | self-host (Docker) or cloud | 52k | 10-19 | v1.0.0 (~10-13) | MIT |
| OpenViking (volcengine) | `viking://` virtual FS, L0/L1/L2 tiered context, session→Markdown memories | self-host or Volcengine cloud | 40k | 10-19 | v0.5.1 (10-19) | AGPL-3.0 |
| mem0 (mem0ai) | LLM fact extraction + vector/entity linking | lib / self-host / cloud | 67k | ~10-14 | ts-v3.3.1 (Sep) | Apache-2.0 |
| mem0-mcp (mem0ai) | **archived**; replaced by hosted MCP | cloud | 662 | Mar | — | Apache-2.0 |
| Letta (letta-ai/letta) | stateful agents, memory blocks | self-host / cloud | 25k | 10-18 | v0.16.8 (May) | Apache-2.0 |
| claude-subconscious (letta-ai) | background Letta agent "whispers" via hooks | Letta server/cloud | 2.9k | Sep | v2.1.1 (Mar) | MIT |
| Graphiti (getzep) | temporal knowledge graph (Neo4j/FalkorDB/Neptune) + LLM extraction | self-host; Zep = managed | 32k | 10-19 | v0.31.1 (~10-15) | Apache-2.0 |
| Cognee (topoteretes) | KG + embeddings; can run with local GLiNER, no API key | self-host / cloud | 33k | ~10-16 | v1.6.5 (~10-16) | Apache-2.0 |
| Supermemory (supermemoryai) | hosted memory API (facts, profiles, forgetting); Claude Code plugin | cloud (self-host option) | 31k | 10-18 | server-v0.0.9 (Oct) | MIT |
| mcp-memory-service (doobidoo) | REST+MCP, local ONNX embeddings, KG | self-host | 2k | 10-19 | v12.1.1 (~10-16) | Apache-2.0 |
| Official MCP memory (modelcontextprotocol/servers `src/memory`) | entities/relations/observations in one JSONL file | local | 91k (whole monorepo) | 10-19 | v2.0.0 (10-19, monorepo) | n/i |
| Serena (oraios/serena) | Markdown memories `.serena/memories/` (+global) inside LSP code toolkit | local | 30k | 10-19 | v2.1.0 (10-19) | n/i by shields |
| ByteRover CLI (campfirein/cipher) | "context tree" w/ git-like branch/commit/merge + cloud sync | local + cloud | 4.9k | Jun | v3.16.1 (May) | n/i |
| Context Portal (GreatScottyMac/context-portal) | SQLite project knowledge graph MCP | local | 767 | Jan | v0.3.13 (Oct 2025) | Apache-2.0 |
| MemOS (MemTensor) | memory OS | self-host | 12k | Sep | v2.0.34 (Sep) | Apache-2.0 |
| memento-mcp (gannonh) | Neo4j KG MCP | local | 424 | May 2025 | v0.3.9 (May 2025) | MIT — **stale** |
| mcp-knowledge-graph (shaneholloman) | fork of official KG server | local | 885 | May | v1.3.2 (Dec 2025) | MIT |
— Source for all rows: shields.io JSON endpoints, e.g. [claude-mem stars](https://img.shields.io/github/stars/thedotmack/claude-mem.json), [claude-mem last-commit](https://img.shields.io/github/last-commit/thedotmack/claude-mem.json); GitHub page check for claude-mem: [github.com/thedotmack/claude-mem](https://github.com/thedotmack/claude-mem). `git ls-remote` showed steveyegge/beads and gastownhall/beads (and milla-jovovich/mempalace and MemPalace/mempalace) resolve to the same HEAD commit, i.e. transferred repos.

**claude-mem** — [README](https://github.com/thedotmack/claude-mem)
- "Persistent memory compression system built for Claude Code". 6 lifecycle hooks (SessionStart, UserPromptSubmit, PreToolUse, PostToolUse, Stop, SessionEnd), Bun worker with local HTTP API + web viewer, SQLite + FTS5, Chroma vector DB, `mem-search` skill; MCP 3-layer retrieval: `search` (~50–100 tokens/result) → `timeline` → `get_observations` (~500–1,000 tokens/result), claims "~10x token savings" (vendor claim). Requires Node ≥20, Bun, uv. Install `npx claude-mem install` or `/plugin marketplace add thedotmack/claude-mem` + `/plugin install claude-mem`.
- Installer asks you to sign in to the hosted "claude-mem observer" (30-day free trial; afterwards "memory automatically falls back to your Anthropic plan unless you subscribe"); alternatives: own OpenRouter/Gemini key or Anthropic plan; opt out with `--provider` or `CLAUDE_MEM_ONLINE_OPTIN=false`. Optional cmem.ai Cloud Sync and hosted "TeamBrain". `<private>` tags exclude content.
- README section "What About CMEM?": a third-party crypto token "officially embraced by the creator", with a Base contract address.
- Security audit issue #1251 (opened 2026-02-26, v10.5.2): path traversal in MCP tools `smart_unfold`/`smart_outline`; unauthenticated worker HTTP API on port 37777 enabling exfiltration, **memory poisoning**, deletion; network exposure if bound to 0.0.0.0; `GET /api/settings` returns API keys in cleartext; a second reviewer listed 23 findings incl. prompt injection via stored observations. Closed 2026-04-15 by the maintainer "during backlog cleanup ... not a bug or feature request" without addressing findings; forks later patched (upstream merge status unknown). — [issue #1251](https://github.com/thedotmack/claude-mem/issues/1251)
- Issue #618 (Jan 2026) "Uses too much tokens" — tokens exhausted in <10 messages, marked confirmed bug. — [issue #618](https://github.com/thedotmack/claude-mem/issues/618). Issue #781: `/plugin uninstall` left processes running; manual removal of hooks/MCP config and killing zombie processes needed; CLAUDE.md files generated despite settings. — [issue #781](https://github.com/thedotmack/claude-mem/issues/781)
- Third-party review: observation generation adds 60–90 s per tool invocation (unverified). — [trigidigital review](https://trigidigital.com/blog/claude-mem-plugin-review-2026/)

**basic-memory** — [README](https://github.com/basicmachines-co/basic-memory)
- Local-first Markdown files ("Plain text on your disk. Forever."); observations + wikilinks form a knowledge graph; SQLite (or Postgres) index; hybrid FTS + FastEmbed vector search, optional cross-encoder rerank; MCP tools annotated read-only/destructive/idempotent; Claude Code plugin with `/basic-memory:*` commands and SKILL.md files.
- Install: `uv tool install basic-memory --prerelease=allow` (README: 0.23 depends on a FastMCP 4 pre-release; without the flag uv "silently installs an older release"); `claude mcp add basic-memory -- uvx --prerelease=allow basic-memory mcp`.
- Cloud: $15/mo locked (regular $19), 7-day trial; "Basic Memory Teams ... single, shared cloud workspace ... Same pricing - start with one user and add more as needed"; hosted on WorkOS AuthKit, Neon Postgres, Tigris S3. AGPL-3.0.

**beads (bd)** — [README](https://github.com/steveyegge/beads)
- "Distributed graph issue tracker for AI agents, powered by Dolt" — "replaces messy markdown plans with a dependency-aware graph". Embedded Dolt in `.beads/embeddeddolt/`; cross-machine sync `bd dolt push/pull` against `refs/dolt/data` on the git remote; hash IDs (`bd-a1b2`) prevent merge collisions; `bd ready`, `bd update --claim`, `bd close`; "Compaction: Semantic 'memory decay' summarizes old closed tasks"; `bd remember "insight"` + `bd prime` inject durable project facts. `bd init` creates/updates AGENTS.md and installs Claude Code/Codex/Cursor integrations unless `--skip-agents`/`--stealth`. Schema migrations across clones require one designated clone to migrate.
- Practitioner review (Tom Rochette, 13 Sep 2026): recommended for teams running several agents on long-horizon work; not for solo/small projects or teams unwilling to put a DB in the repo; architecture changed twice in ~1 year (community `beads_rust` fork freezes the older SQLite+JSONL design); 1,148 open issues; alternatives Backlog.md, TODO.md ("hardest competitor at small scale"). — [tomrochette.com](https://tomrochette.com/agents/beads/); Show HN "I replaced Beads with a faster, simpler Markdown-based task tracker" — [HN](https://news.ycombinator.com/item?id=46487580)

**episodic-memory (Jesse Vincent / obra)** — [README](https://github.com/obra/episodic-memory)
- Semantic search over past Claude Code/Codex/Cursor/opencode/OMP conversations; `/plugin install episodic-memory@superpowers-marketplace`; copies new conversations from `~/.claude/projects` etc. into its own archive and indexes at session end; embeddings local (Transformers.js), search local SQLite (sqlite-vec); summaries via your Claude Code auth, default model Haiku, "up to 10 calls/sync", can be disabled (`EPISODIC_MEMORY_SKIP_SUMMARIES=1`); warns if summarization would bill a metered API.

**MemPalace** — [README](https://github.com/milla-jovovich/mempalace)
- "Local-first AI memory. Verbatim storage, pluggable backend, 96.6% R@5 raw on LongMemEval — zero API calls" (vendor claim); stores conversation history verbatim (no summarisation); structured index (wings/rooms/drawers); ChromaDB default; MCP + skills (`npx skills add MemPalace/mempalace`), `uv tool install mempalace`, Docker. README warns "Claude Code sessions expire in 30 days without auto-save hooks wired" and about impostor sites.

**Hindsight** — [README](https://github.com/vectorize-io/hindsight)
- Docker server with Postgres; needs an LLM key (25+ providers incl. local Ollama/LM Studio/llama.cpp); `npx @vectorize-io/hindsight-coding-agents install claude-code` builds "a per-repo bank built automatically from git history and past sessions, injected into the agent as it starts working, plus curated knowledge pages covering architecture, conventions and in-flight work". Claims SOTA LongMemEval, "independently reproduced" by Virginia Tech Sanghani Center and The Washington Post (vendor statement).

**Serena memories** — [Serena docs 045_memories.md](https://github.com/oraios/serena/blob/main/docs/02-usage/045_memories.md)
- Plain Markdown: project memories in `.serena/memories/` ("can be committed, reviewed in PRs, and reverted"), global in `~/.serena/memories/global/`; agent receives the memory *name list* up front and reads deliberately (`mem:core` entry point, `mem:NAME` references; `serena memories check` finds stale references); read-only/ignored regex patterns. Explicit stance: "Prefer references to search ... any retrieval method (lexical or semantic) produces both false positives and false negatives"; database-backed memory and hook-injection rejected by design.

**Official MCP Knowledge Graph Memory server** — [README](https://github.com/modelcontextprotocol/servers/tree/main/src/memory)
- `@modelcontextprotocol/server-memory`: "A basic implementation of persistent memory using a local knowledge graph ... remember information about the user across chats"; entities/relations/observations; tools `create_entities`, `create_relations`, `add_observations`, `delete_*`, `read_graph`, `search_nodes`, `open_nodes`; single JSONL file (`MEMORY_FILE_PATH`) with lock file for multi-process writes; supports the 2026-07-28 MCP protocol era.

**Cline Memory Bank** — [Cline docs](https://docs.cline.bot/best-practices/memory-bank)
- A custom-instructions *methodology*, not a built-in feature: `memory-bank/` with `projectbrief.md`, `productContext.md`, `activeContext.md` (changes most), `systemPatterns.md`, `techContext.md`, `progress.md`; commands "initialize memory bank", "update memory bank", "follow your custom instructions"; instructions in `.clinerules/memory-bank.md`, shareable; "works with any AI that can read docs".

**mem0 / OpenMemory** — [mem0 README](https://github.com/mem0ai/mem0); [mem0-mcp README](https://github.com/mem0ai/mem0-mcp)
- "New Memory Algorithm (April 2026)": LoCoMo 71.4→92.5, LongMemEval 67.8→94.4 at ~7K retrieved tokens, p50 ~1 s — README states scores reflect the managed platform with proprietary optimizations; "Single-pass ADD-only extraction ... Memories accumulate; nothing is overwritten." Self-hosted server: dashboard yes, advanced features "Teasers"; Cloud "All included".
- mem0-mcp: "This project has been archived"; replaced by hosted MCP `https://mcp.mem0.ai/mcp`. `openmemory/README.md` in mem0 repo returns 404; a third-party guide says OpenMemory was folded into the self-hosted server — [contextbolt](https://contextbolt.com/blog/mem0-mcp/) (not officially confirmed). OpenMemory originally launched as local-first MCP in May 2025 — [mem0 blog](https://mem0.ai/blog/introducing-openmemory-mcp).

**Letta / claude-subconscious** — [claude-subconscious README](https://github.com/letta-ai/claude-subconscious)
- README: "demo app built using the Letta Code SDK, and is not intended to be used in production" — use Letta Code (`npm install -g @letta-ai/letta-code`; letta-code ~3.7k stars) instead. Sends each transcript to a background Letta agent that reads files/web and "whispers" guidance before each prompt/tool use.

**Zep / Graphiti** — [Graphiti README](https://github.com/getzep/graphiti); [Graphiti MCP README](https://github.com/getzep/graphiti/tree/main/mcp_server)
- Temporal context graphs tracking how facts change over time with provenance; requires Neo4j 5.26 / FalkorDB / Neptune (Kuzu deprecated, upstream unmaintained) plus LLM + embedder. MCP server: "reference implementation. Do not use the server as a production deployment ... no authentication, no authorization, and no prompt-injection protection"; "experimental".

**Cognee, Supermemory, OpenViking, mcp-memory-service, ByteRover**
- Cognee: self-hosted KG + embeddings; "Runs locally for free — no API key required" (local GLiNER + embeddings); positions "Company Brain". — [README](https://github.com/topoteretes/cognee)
- Supermemory: claims "#1 on LongMemEval, LoCoMo, and ConvoMem" (vendor); fact extraction, contradiction handling, automatic forgetting; Claude Code plugin (supermemoryai/claude-supermemory, ~2.8k stars). — [README](https://github.com/supermemoryai/supermemory)
- OpenViking (ByteDance/Volcengine): 0.x; vendor chart "LoCoMo ... Claude Code 57.21% native vs 80.32% with OpenViking". — [README](https://github.com/volcengine/OpenViking)
- mcp-memory-service: "Embeddings run locally via ONNX — memory never leaves your infrastructure"; REST + MCP + dashboard. — [README](https://github.com/doobidoo/mcp-memory-service)
- ByteRover CLI (`brv`, repo campfirein/cipher): curates a "context tree" with git-like branch/commit/merge/push/pull and cloud sync "to share it across tools and teammates". — [README](https://github.com/campfirein/cipher)

### Inferences
- **Mechanism → failure mode mapping**: Markdown-first (basic-memory, Serena, memory bank, native) fail by *staleness/bloat* but are human-auditable and diffable. Auto-capture + vector (claude-mem, MemPalace, Hindsight, OpenViking) fail by *context pollution, retrieval misses (probabilistic), silent poisoning* and add daemons, hooks and LLM summarisation cost; mem0's ADD-only design means contradictions accumulate and must be resolved at retrieval. Graph systems (Graphiti, Cognee, official KG server) need extraction LLMs and DBs — high ops for a dev team; the official KG server's `read_graph` returns the whole graph, so cost grows with size.
- **Maturity flags**: claude-mem — very popular but unresolved security audit closed without fixes, commercial upsell, crypto token, uninstall leftovers → not recommended for company code without a security review. claude-subconscious — explicitly not for production. mem0-mcp — archived. iansinnott/obsidian-claude-code-mcp, memento-mcp — stale (last activity mid-2025). Graphiti MCP — reference only. OpenViking 0.x. beads — powerful but churny.
- **Stars are not a quality signal here**: several repos jumped to 30k–100k stars within months (claude-mem 102k vs basic-memory 4.3k); treat as attention, not validation.
- **Most defensible picks** for a newcomer team: native stack first; then (personal) episodic-memory for searchable past sessions (local, small, MIT, by a well-known practitioner) or basic-memory for a Markdown knowledge base shared with Obsidian; Serena memories if the team already uses Serena; beads only for multi-agent, long-horizon task tracking.
- Retrieval token cost is only published by vendors (claude-mem 50–1,000 tokens/result; mem0 ~7K tokens/query); for file-based approaches cost equals what is loaded (bounded by the 200-line/25KB conventions).

### Gaps
- No independent benchmark of any memory tool on *coding* outcomes (task success, rework); all LongMemEval/LoCoMo numbers are conversational-recall benchmarks and mostly vendor-run.
- Retrieval token costs for basic-memory, Hindsight, MemPalace, Serena not measured/published in sources found.
- Whether claude-mem upstream fixed the #1251 findings is unknown.
- MemPalace's provenance (original "milla-jovovich" account) and Hindsight/MemPalace star velocity were not investigated.
- Letta server/Letta Code memory internals and Zep pricing not researched in depth.

## 4. What experienced practitioners report: measurable help or noise? Minimum viable setup

### Takeaway
The only rigorous evidence (ETH Zurich, arXiv 2602.11988) shows that always-loaded repository context files do **not** generally improve task success and raise inference cost by >20%, with small gains only from minimal human-written content — so "more memory" is not automatically better. Practitioner consensus: a short, human-curated CLAUDE.md (+ path-scoped rules, hooks for hard rules) is the minimum viable and often sufficient setup; add a queryable memory store only for concrete triggers (multiple tools/machines, team knowledge, volume), and keep promotion from memory into rules a reviewed step.

### Cited Findings
- Gloaguen, Mündler-Sasahara, Müller, Raychev, Vechev (ETH Zurich), "Evaluating AGENTS.md: Are Repository-Level Context Files Helpful for Coding Agents?" (v1 12 Feb 2026, v3 29 Sep 2026; ICLR 2026): "providing context files does not generally improve task success rates"; inference cost +>20% on average; agents follow the instructions; repository overviews don't help; context files useful for non-standard coding practices; improvements should be rigorously evaluated. — [arXiv 2602.11988](https://arxiv.org/abs/2602.11988)
- Coverage of the same paper: LLM-generated files +3.92 steps / +23% cost on the new benchmark, +2.45 steps / +20% on SWE-bench; human-written files ≈ +4 pp; tested Claude Code + Sonnet 4.5, Codex GPT-5.2/5.1-mini, Qwen Code; 138 tasks from 12 repos + SWE-bench Lite. — [AI Weekly](https://aiweekly.co/alerts/paper-finds-agentsmd-files-hurt-coding-agent-task-success) (secondary)
- Anthropic best practices: keep CLAUDE.md short; "For each line, ask: 'Would removing this cause Claude to make mistakes?' If not, cut it. Bloated CLAUDE.md files cause Claude to ignore your actual instructions!"; include commands Claude can't guess, non-default style, test runners, repo etiquette, architectural decisions, env quirks, gotchas; exclude what Claude can read from code, frequently-changing info, file-by-file descriptions; use skills for sometimes-relevant knowledge, hooks for must-happen actions. — [Claude Code best practices](https://code.claude.com/docs/en/best-practices)
- HumanLayer (Kyle, 25 Nov 2025): <300 lines, their root file <60 lines; frontier LLMs follow ~150–200 instructions consistently and Claude Code's system prompt already uses ~50; CLAUDE.md is wrapped in a reminder ("You should not respond to this context unless it is highly relevant to your task") so irrelevant-looking content may be ignored; progressive disclosure via `agent_docs/*.md`; prefer `file:line` pointers; don't auto-generate with `/init`; don't use it as a linter. — [HumanLayer blog](https://www.humanlayer.dev/blog/writing-a-good-claude-md)
- "A file is loaded. A store is queried." Skip a memory MCP if one project / one tool / one machine / few facts; triggers: multiple tools, multiple machines, team context never committed, volume; put always-apply constraints in the always-loaded file because retrieval is probabilistic; memories need provenance, scope, expiry; beware "poisoned write-backs"; promote memory → rules via reviewed diff (author builds the Kireo memory MCP). — [DEV, Aug–Sep 2026](https://dev.to/wang1051992187/claudemd-vs-a-memory-mcp-what-actually-goes-where-438n)
- Search-level summary of guides: "CLAUDE.md is enough for a single-project, single-tool setup"; no rigorous head-to-head evidence in practitioner sources. — [MindStudio comparison](https://www.mindstudio.ai/blog/claude-code-memory-systems-compared); [russ.cloud on codebase-memory-mcp](https://www.russ.cloud/2026/05/10/codebase-memory-mcp-giving-claude-code-and-codex-a-map/) (reviewer's experience "more modest" than README claims)
- Serena maintainers: "Prefer references to search" — retrieval yields false positives and negatives; deliberate name-based reads. — [Serena docs](https://github.com/oraios/serena/blob/main/docs/02-usage/045_memories.md)
- Noise/overhead reports for heavy tools: claude-mem token exhaustion (#618), uninstall leftovers (#781), 60–90 s per tool call (third-party); beads auto-AGENTS.md/hooks and architecture churn. — [#618](https://github.com/thedotmack/claude-mem/issues/618); [#781](https://github.com/thedotmack/claude-mem/issues/781); [tomrochette.com](https://tomrochette.com/agents/beads/)
- Anthropic's own long-running-agent guidance: deliberate progress log + feature checklist read at session start and updated at end; "Work on one feature at a time." — [memory tool docs](https://platform.claude.com/docs/en/agents-and-tools/tool-use/memory-tool)

### Inferences
- **Minimum viable memory setup (recommended starting point for a team new to this):**
  1. Per repo: committed `CLAUDE.md` (or `AGENTS.md` + `@AGENTS.md` import if multiple agents are used) ≤ ~60–200 lines, human-written, containing only non-derivable facts (commands, non-default conventions, gotchas, decisions). Review it like code.
  2. `.claude/rules/*.md` with `paths:` for area-specific conventions (frontend/backend/migrations) so they cost nothing elsewhere.
  3. Hooks / `permissions.deny` for anything that must always happen (lint, tests, forbidden paths) — not prose.
  4. Leave auto memory ON for personal learnings; audit `/memory` monthly; promote durable team-relevant items into CLAUDE.md/rules via PR.
  5. Personal cross-project prefs in `~/.claude/CLAUDE.md` / `~/.claude/rules/`; personal per-project notes in `CLAUDE.local.md` (or `@~/...` import for worktrees).
  6. For multi-session features: a committed `docs/progress.md` / ADR folder (memory-bank style) referenced from CLAUDE.md rather than imported, read deliberately.
- **Optional add-ons with clear triggers**: episodic-memory (when people often ask "how/why did we do X last month" — note Claude Code deletes session transcripts after `cleanupPeriodDays`, default 30 days — [settings reference](https://code.claude.com/docs/en/settings-reference); raise it (e.g. 3650) if you rely on transcript-search tools); Obsidian vault + qmd (personal research/second brain across projects); beads (multiple concurrent agents on long-horizon backlogs).
- **Measure before scaling**: given the ETH result, a team should A/B any memory addition on its own tasks (cost per task, rework, corrections repeated) rather than trust vendor benchmarks.

### Gaps
- No Reddit/HN thread with quantitative before/after data for claude-mem, basic-memory or auto memory was found; practitioner evidence is anecdotal.
- No study isolates *auto memory* or *retrieval-based memory* (vs static context files) on coding benchmarks.

## 5. Team sharing: shared & versioned (git) vs personal-only

### Takeaway
Team-shareable memory today means "Markdown in the repo, reviewed in PRs": CLAUDE.md/AGENTS.md, `.claude/rules/`, project-scoped subagent memory, `.serena/memories/`, memory-bank/ADR docs, and (for tasks) beads via Dolt-on-git. Native auto memory, CLAUDE.local.md, episodic transcripts and most auto-capture tools are personal and machine-local. Hosted "team brains" (Basic Memory Teams, claude-mem TeamBrain, mem0/Supermemory/Zep cloud, ByteRover cloud) exist but move code knowledge to third-party clouds and add access-control questions.

### Cited Findings
- Project CLAUDE.md "Shared with: Team members via source control"; CLAUDE.local.md "Only you (current project)"; managed policy CLAUDE.md "All users in organization", deployable via MDM/Ansible or `claudeMd` in managed settings; `.claude/rules/` "keeps instructions modular and easier for teams to maintain"; shared rules across projects via symlinks (external targets need per-project approval). — [memory docs](https://code.claude.com/docs/en/memory)
- "Auto memory is machine-local ... not shared across machines or cloud environments." — [memory docs](https://code.claude.com/docs/en/memory)
- Subagent memory `project` scope at `.claude/agent-memory/<agent>/` "is shareable via version control" and is the recommended default. — [sub-agents docs](https://code.claude.com/docs/en/sub-agents)
- "Check CLAUDE.md into git so your team can contribute. The file compounds in value over time." — [best practices](https://code.claude.com/docs/en/best-practices)
- Serena project memories "can be committed, reviewed in PRs, and reverted"; global memories are not versioned — docs suggest making `~/.serena/memories/` its own git repo. — [Serena docs](https://github.com/oraios/serena/blob/main/docs/02-usage/045_memories.md)
- Cline memory bank instructions in a project rules file "can be shared with collaborators". — [Cline docs](https://docs.cline.bot/best-practices/memory-bank)
- beads: hash IDs avoid merge collisions in "multi-agent/multi-branch workflows"; sync via `bd dolt push/pull` to `refs/dolt/data` on the git remote; `--stealth` keeps it personal on shared repos; `--contributor` routes planning to a separate repo. — [beads README](https://github.com/steveyegge/beads)
- Basic Memory Teams: "single, shared cloud workspace ... anything a teammate writes is immediately available to everyone else and to their AI assistants" (paid cloud). Local edition syncs across devices only manually ("Git, Syncthing, etc."). — [basic-memory README](https://github.com/basicmachines-co/basic-memory)
- claude-mem TeamBrain: "optional shared workspace ... Each person chooses what to share" (hosted at cmem.ai). — [claude-mem README](https://github.com/thedotmack/claude-mem)
- ByteRover: context tree with git-like version control and cloud sync "to share it across tools and teammates". — [ByteRover README](https://github.com/campfirein/cipher)
- MemPalace guided setup offers "a private local palace, a shared-brain hub, or a client connected to an existing hub". — [MemPalace README](https://github.com/milla-jovovich/mempalace)
- Shared-store risks raised by practitioners: "a namespace is not an access-control boundary"; a memory from the wrong repo or customer is harmful; review promotion of memories to policy. — [DEV article & comments](https://dev.to/wang1051992187/claudemd-vs-a-memory-mcp-what-actually-goes-where-438n)
- Claude Code cloud "Projects" project memory is shared across a user's cloud threads but Projects are "not available on Team or Enterprise plans yet". — [Projects docs](https://code.claude.com/docs/en/claude-projects)

### Inferences
- **Team layer (git, reviewed)**: CLAUDE.md/AGENTS.md + rules + project subagent memory + `docs/decisions` (ADR) / memory-bank files; optionally `.serena/memories/` or beads. These inherit git's review, history, blame and access control — the decisive advantage for a team.
- **Personal layer (never committed)**: `~/.claude/CLAUDE.md`, `~/.claude/rules/`, CLAUDE.local.md, auto memory, episodic-memory, a personal Obsidian vault. Good learnings flow upward into the team layer only via PR.
- **Org layer**: managed CLAUDE.md / `claudeMd` for security & compliance reminders (cannot be excluded by users).
- Hosted shared memory services should be treated like any SaaS receiving source-code-derived data (DPA, retention, access control, prompt-injection/poisoning risk); none of the reviewed tools showed per-memory ACLs or review workflows comparable to PRs.
- Multi-project consistency: share common rules via a separate "standards" repo symlinked into `.claude/rules/` or imported with `@` (one-time approval), or distribute via an internal Claude Code plugin/skills marketplace (beads, basic-memory, qmd, obsidian-skills all ship as plugins — the same mechanism works for internal content).

### Gaps
- No documented native Claude Code feature for a shared, queryable *team* memory store for local CLI sessions (the `CLAUDE_MEMORY_STORES` changelog mention is undocumented for this use).
- No case studies found of teams (>5 devs) running a shared vector/graph memory for daily coding with measured outcomes.
- Pricing/ACL details for claude-mem TeamBrain, mem0 cloud, Supermemory, Zep for teams were not researched.
