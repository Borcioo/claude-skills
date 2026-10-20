# MCP servers for everyday software development with Claude Code and other coding agents (as of October 2026)

Research date: 2026-10-19 (a Monday). GitHub stats come from img.shields.io JSON badges fetched that day. Shields rounds star counts (for example "63k") and gives relative commit dates. I converted those dates as follows: "today" = 2026-10-19, "last Saturday" ≈ 10-17, "last Thursday" ≈ 10-15, "last Wednesday" ≈ 10-14, "last Tuesday" ≈ 10-13. Badge endpoints: `https://img.shields.io/github/{stars,last-commit,v/release}/OWNER/REPO.json`. The `gh` CLI and api.github.com were blocked, so no numbers come from them. README facts come from `raw.githubusercontent.com/OWNER/REPO/HEAD/README.md`, fetched the same day. Memory/knowledge MCPs are out of scope because another researcher covers them.

## 1. Which MCP servers are worth installing for daily dev work, by category (maintainer, install, transport, stars, activity, tools, token footprint)

### Takeaway
On every surface I checked, Claude Code now defers MCP tool definitions by default: only names and server instructions load up front. That makes "how many tokens does this server cost" much less important than it was in 2025. The question is now whether a server does something that the built-in tools (Bash + CLIs, WebSearch/WebFetch, the native LSP tool, Claude in Chrome) and skills cannot.

The servers with the clearest daily value are:
- **Docs:** Context7, or Ref/DeepWiki.
- **Browser verification/debugging:** Playwright MCP or the playwright-cli skill, Chrome DevTools MCP.
- **Code intelligence:** native LSP plugins first, Serena for heavy refactors.
- **Vendor remote MCPs for services you already use:** Sentry, Linear/Atlassian, Supabase/Neon in dev, read-only; Vercel/Cloudflare; Figma if your seat allows.

The GitHub MCP is optional in a terminal agent, because `gh` does the same job as well or better.

### Cited Findings

**Ranked shortlist (my synthesis of the evidence below; the tiering itself is an inference)**

| Tier | Server | Category | Maintainer | Transport / install | GitHub stars (2026-10-19) | Last commit / release | Tools / token footprint (reported) |
|---|---|---|---|---|---|---|---|
| A | Context7 | Docs | Upstash (official) | Remote HTTP `https://mcp.context7.com/mcp` (Bearer API key); `npx ctx7 setup` (choose MCP or CLI+Skill mode); official Claude marketplace plugin `context7` | 63k (upstash/context7) | today; @upstash/context7-mcp@4.4.4 | 2 tools (`resolve-library-id`, `query-docs`) |
| A | Native LSP plugins (not MCP) | Code intelligence | Anthropic (official marketplace) | `/plugin install typescript-lsp@claude-plugins-official` + language-server binary | n/a | n/a | Built-in `LSP` tool + automatic diagnostics after edits |
| A | Playwright MCP / playwright-cli | Browser/E2E | Microsoft (official) | stdio `claude mcp add playwright npx @playwright/mcp@latest`; CLI `npm i -g @playwright/cli@latest && playwright-cli install --skills` | 38k (playwright-mcp); 14k (playwright-cli) | today; v0.0.83 / v0.1.22 | 25 default tools of 72 documented (opt-in caps); 2025 measurement 48 tools ≈ 5.9k tokens |
| A | Chrome DevTools MCP | Browser debug/perf | Google Chrome DevTools team (official) | stdio `npx -y chrome-devtools-mcp@latest` (`--slim`, `--headless`); also ships a CLI | 54k | today; v1.11.0 | 59 tools in reference (memory tools behind flag); `--slim` = 3 tools |
| A- | Sentry MCP | Error monitoring | Sentry (official) | Remote `claude mcp add --transport http sentry https://mcp.sentry.dev/mcp` (OAuth); stdio `npx @sentry/mcp-server@latest --access-token=…` for self-hosted | 934 | today; cli@0.47.0 | Anthropic measured 5 tools ≈ 3K tokens (Nov 2025) |
| A- | Linear MCP | Issues | Linear (official) | Remote `claude mcp add --transport http linear-server https://mcp.linear.app/mcp` (OAuth 2.1; `/mcp/readonly`) | no public repo | n/a | tool count not documented |
| B+ | Atlassian Rovo MCP / mcp-atlassian | Jira/Confluence | Atlassian (official remote) / sooperset (community, supports Server/DC) | official remote + `atlassian` plugin; `uvx mcp-atlassian` | 1.1k (official) / 6k (community) | Oct 2026 / Sep 2026, v0.23.1 | Jira ≈ 17K tokens (Anthropic example) |
| B+ | Supabase MCP / Neon MCP | DB platforms | Supabase / Neon (official) | Remote `https://mcp.supabase.com/mcp?project_ref=…&read_only=true&features=…`; `https://mcp.neon.tech/mcp?category=…` / `npx neon@latest init` | 3k / 655 | today, v0.14.0 / ≈10-15 | Supabase ≈ 19.3k tokens (per DBHub's comparison) |
| B+ | DBHub / Postgres MCP Pro | Generic SQL | Bytebase / Crystal DBA (vendor-community) | `npx -y @bytebase/dbhub --dsn …` (example in Claude Code docs); `uvx postgres-mcp --access-mode=restricted` | 3.7k / 3.4k | ≈10-13 / Aug 2026, v0.3.0 | DBHub 2 tools ≈ 1.4k tokens |
| B | Cloudflare API MCP (Code Mode) | Cloud | Cloudflare (official) | Remote `https://mcp.cloudflare.com/mcp` (OAuth 2.1 or API token) | 971 (cloudflare/mcp); 4.4k (older mcp-server-cloudflare) | today | 2 tools, ≈ 1,000 tokens for the whole API (>2,500 endpoints) |
| B | Vercel MCP | Cloud | Vercel (official) | Remote `claude mcp add --transport http vercel https://mcp.vercel.com` (OAuth, approved clients only) | no public repo | docs updated 2026-09-15 | docs, projects, deployments, logs, analytics |
| B | AWS MCP Server (preview) / AWS Knowledge MCP | Cloud | AWS Labs (official) | `uvx mcp-proxy-for-aws@latest https://aws-mcp.us-east-1.api.aws/mcp`; Knowledge: `https://knowledge-mcp.global.api.aws` | 9.8k (awslabs/mcp) | today; v2026.10.20261015… | many servers; Cloud Control API server deprecated |
| B | Figma Dev Mode MCP (official) / Framelink | Design→code | Figma (official) / GLips (community) | Remote `claude mcp add --transport http figma https://mcp.figma.com/mcp`; `npx -y figma-developer-mcp --figma-api-key=… --stdio` | 2.1k (figma/mcp-server-guide) / 16k (Framelink) | today / June 2026, v0.13.2 | official: design context, screenshots, variables, Code Connect, write-to-canvas |
| B | Ref / DeepWiki | Docs | Ref (vendor) / Cognition-Devin (official hosted) | `https://api.ref.tools/mcp?apiKey=…`; `claude mcp add -s user -t http deepwiki https://mcp.deepwiki.com/mcp` | 1.2k (Ref) / hosted | Sep 2026 / n/a | Ref search ≈ 54 tok, read ≈ 385 tok (example), 5k-token page cap; DeepWiki 3 tools |
| B | Serena | Semantic code nav/refactor | Oraios (community/company, GPL-3.0) | `uv tool install -p 3.13 serena-agent` → `serena init` → client config | 30k | today; v2.1.0 | symbol tools; its file/shell tools are off by default inside Claude Code/Codex |
| C | GitHub MCP | GitHub | GitHub (official) | Remote `https://api.githubcopilot.com/mcp/` (OAuth/PAT); Docker `ghcr.io/github/github-mcp-server` | 34k | ≈10-15; v2.0.2 | default 44 tools ≈ 14.2k tokens; all 85 tools ≈ 26.6k (Aug 2026) |
| C | Web search: Exa / Perplexity / Tavily / Brave | Search | Official vendors | Remote URLs / npx (see below) | 5.1k / 2.6k / 2.4k / 1.5k | today / ≈10-17 / ≈10-15 / Oct 2026, v2.1.4 | Exa default = 1 tool |
| C | Kubernetes MCP / Docker MCP Gateway | Infra | Red Hat-led (containers org) / Docker (official) | Go binary, npm, pip, or container; `docker mcp` (Docker Desktop 4.59+) | 2.2k / 1.6k | today, v0.0.67 / Sep 2026 | n/a |
| D | Sequential Thinking | Reasoning | MCP steering group (reference) | `npx -y @modelcontextprotocol/server-sequential-thinking` | in modelcontextprotocol/servers (91k) | today | 1 tool |

**Docs servers**
- Context7: `npx ctx7 setup` runs OAuth, generates an API key, and installs a skill. You choose "CLI + Skills" mode (agent runs `ctx7 library` / `ctx7 docs`, no MCP needed) or "MCP" mode. Manual setup uses `https://mcp.context7.com/mcp` with an `Authorization: Bearer` key, and a free API key is "recommended" for higher rate limits — [upstash/context7 README](https://github.com/upstash/context7). The official registry lists it as `io.github.upstash/context7` 4.4.4 (npm + mcpb + remote), updated 2026-10-19 — [MCP Registry API](https://registry.modelcontextprotocol.io/v0.1/servers?search=context7). Context7 is also in Anthropic's official plugin marketplace as `context7` ("Connects to Context7's hosted remote MCP server") — [claude-plugins-official marketplace.json](https://github.com/anthropics/claude-plugins-official).
- Ref: remote `https://api.ref.tools/mcp?apiKey=…` or `npx ref-tools-mcp@latest`. Tools are `ref_search_documentation` and `ref_read_url`. It covers public docs plus private repos and PDFs. The README example shows SEARCH = 54 tokens and READ = 385 tokens, and a page read returns "the most relevant 5k tokens" based on session search history — [ref-tools/ref-tools-mcp](https://github.com/ref-tools/ref-tools-mcp). Stars 1.2k; last commit September 2026 (shields).
- DeepWiki (official, hosted by Cognition/Devin): `https://mcp.deepwiki.com/mcp` (Streamable HTTP; SSE "being deprecated"). It is "free, remote, no-authentication-required" for public repos; private repos need the Devin MCP and an API key. Tools are `read_wiki_structure`, `read_wiki_contents`, `ask_question`. Install: `claude mcp add -s user -t http deepwiki https://mcp.deepwiki.com/mcp` — [Devin docs](https://docs.devin.ai/work-with-devin/deepwiki-mcp). The community wrapper regenrek/deepwiki-mcp (1.4k stars) was last committed in July 2025 and is **stale** (shields).

**Browser / testing**
- Playwright MCP: `claude mcp add playwright npx @playwright/mcp@latest`. Opt-in capabilities via `--caps` (vision, pdf, devtools, network, storage, config, testing). Other options: `--isolated`, `--extension` (attach to a logged-in Chrome/Edge), `--snapshot-mode full|none`, and `--mobile` ("Mobile pages are usually lighter, which saves tokens"). There is a "Find in page snapshot" tool that is "cheaper than capturing the whole snapshot". My count of the README tool list gives 25 default tools (core + tabs + install) out of 72 documented — [microsoft/playwright-mcp README](https://github.com/microsoft/playwright-mcp).
- Microsoft's own guidance at the top of both READMEs: "Modern coding agents increasingly favor CLI–based workflows exposed as SKILLs over MCP because CLI invocations are more token-efficient." It adds that MCP "remains relevant for specialized agentic loops that benefit from persistent state … exploratory automation, self-healing tests" — [microsoft/playwright-cli README](https://github.com/microsoft/playwright-cli).
- Checkly (Jul 30, 2026) measured the same demo task three times. The MCP session ended at 48–50k tokens of context and the CLI session at 45–48k ("more or less the same"). Playwright MCP now writes snapshots to disk and returns a resource link, and playwright-cli "commands literally invoke the MCP tools" with the same backend. Its 2025 measurement was 48 tool schemas ≈ 5.9k tokens — [Checkly blog](https://www.checklyhq.com/blog/mcp-vs-cli-token-efficiency/).
- Chrome DevTools MCP (Google): `npx -y chrome-devtools-mcp@latest`. It does performance traces, Lighthouse audits, network inspection, and console with source-mapped stacks. The tool reference has 59 tools: input 10, navigation 6, emulation 2, performance 3, network 2, debugging 9, memory 14 (behind `--memoryDebugging`), extensions 5, third-party 2, WebMCP 2, PWA 4. `--slim` mode exposes 3 tools (navigate, evaluate, screenshot). Usage-statistics collection is **on by default** (`--no-usage-statistics` opts out), and CrUX lookups can be turned off with `--no-performance-crux` — [ChromeDevTools/chrome-devtools-mcp README](https://github.com/ChromeDevTools/chrome-devtools-mcp) and [tool reference](https://github.com/ChromeDevTools/chrome-devtools-mcp/blob/main/docs/tool-reference.md). It is also an official Claude marketplace plugin — [marketplace.json](https://github.com/anthropics/claude-plugins-official).
- Built-in alternative: Claude in Chrome reached general availability in Claude Code in the week of June 29–July 3, 2026, and the Desktop app got a built-in browser in July 2026 — [Claude Code what's new index](https://code.claude.com/docs/llms.txt). `claude --chrome` gives live debugging (console errors, DOM), design verification, testing of authenticated apps using the browser's login state, and GIF recording. It requires a direct Anthropic plan and `/login`, and is not available via Bedrock/Vertex/Foundry — [Claude Code Chrome docs](https://code.claude.com/docs/en/chrome).
- Other CLI-first browser tools: vercel-labs/agent-browser ("Browser automation CLI for AI agents. Fast native Rust CLI", accessibility snapshots with refs, `screenshot --if-changed … to save tokens`) has 44k stars, last commit today, v0.39.1 — [agent-browser README](https://github.com/vercel-labs/agent-browser). browser-use (119k stars, v0.13.13) now steers coding agents to its CLI plus `browser-use skill install` rather than an MCP — [browser-use README](https://github.com/browser-use/browser-use). browserbase/mcp-server-browserbase (3.4k, last commit July 2026) is a cloud-browser option.

**Code intelligence**
- Claude Code native code intelligence plugins: clangd-lsp, csharp-lsp, gopls-lsp, jdtls-lsp, kotlin-lsp, liquid-lsp (Shopify), lua-lsp, php-lsp, pyright-lsp, ruby-lsp, rust-analyzer-lsp, swift-lsp, typescript-lsp. They provide diagnostics after every edit ("Found N new diagnostic issues") and a read-only `LSP` tool for definitions and references. You install the binary and then the plugin, and Claude Code offers an "LSP plugin recommendation" dialog when the binary is already on PATH. They are not available in cloud sessions — [Claude Code code intelligence docs](https://code.claude.com/docs/en/plugins/code-intelligence). The `LSP` tool is listed among the built-in tools — [tools reference](https://code.claude.com/docs/en/tools-reference).
- Serena v2.1.0 (GPL-3.0; the SolidLSP component is MIT). Install with `uv tool install -p 3.13 serena-agent` then `serena init`. The README warns: "Do not install Serena via an MCP or plugin marketplace! They contain outdated and suboptimal installation commands." It supports 40+ languages via LSP, plus a paid JetBrains plugin backend that adds move, inline, type hierarchy, and a debugger. Symbol-level tools cover find, overview, references, rename, replace body, and insert before/after. Its basic file/shell tools are "typically disabled by default" in Claude Code/Codex. v2 adds a REPL/code-execution agent interface. The README's "evaluation" consists of agent testimonials (e.g. "Opus 4.6 (high) in Claude Code") — [oraios/serena README](https://github.com/oraios/serena). The registry entry `io.github.oraios/serena` is still at 1.5.3, which bears out the warning — [MCP Registry API](https://registry.modelcontextprotocol.io/v0.1/servers?search=serena).
- One anecdote: a Scala user found Serena's lookups slow, attributed it to MCP transport, and now queries the Metals MCP directly — [Scala contributors forum](https://contributors.scala-lang.org/t/rallying-scala-metals-lsp-native-support-in-claude-code/7437). isaacphi/mcp-language-server (1.6k) was last committed in June 2025 and is **stale** (shields).

**GitHub / GitLab**
- GitHub MCP (official). Remote: `claude mcp add --transport http github https://api.githubcopilot.com/mcp/ --header "Authorization: Bearer YOUR_GITHUB_PAT"` — [Claude Code MCP docs](https://code.claude.com/docs/en/mcp). Local: Docker `ghcr.io/github/github-mcp-server`, with OAuth login built in. Default toolsets are context, repos, issues, pull_requests, users, out of about 22 toolsets. Flags: `--toolsets`, `--tools`, `--read-only`, `--lockdown-mode`, and insiders mode — [github/github-mcp-server README](https://github.com/github/github-mcp-server).
- GitHub MCP token measurements over time:
  - 93 tools ≈ 55,000 tokens (Geoffrey Huntley, summarized by Simon Willison, Aug 2025) — [Simon Willison](https://simonwillison.net/tags/model-context-protocol/)
  - 35 tools ≈ 26K tokens — [Anthropic, Nov 24 2025](https://www.anthropic.com/engineering/advanced-tool-use)
  - default toolsets 44 tools = 14,243 tokens; all toolsets 85 tools = 26,644 (count_tokens, Aug 2026) — [Blocks.ai](https://blocks.ai/blog/mcp-vs-cli-context-window-cost)
  - ≈17.8k tokens of definitions — [Checkly](https://www.checklyhq.com/blog/mcp-vs-cli-token-efficiency/)
  - Kaxil says GitHub "later cut defaults to 52" — [Kaxil, Apr 2026](https://kaxil.substack.com/p/mcp-vs-cli-vs-rest). This conflicts with Blocks.ai's 44, possibly because they counted at different times.
- GitLab: there is an official MCP server built into GitLab (toolsets selected via HTTP header; a group Owner or admin must enable it). The community zereight/gitlab-mcp (`npx -y @zereight/mcp-gitlab`, 2.1k stars, v2.3.4, committed today) has 276 tools (274 in toolsets + `execute_graphql` + `discover_tools`), a read-only mode, and JMESPath result filtering — [zereight/gitlab-mcp README](https://github.com/zereight/gitlab-mcp). The old reference GitHub/GitLab servers are archived — [modelcontextprotocol/servers README](https://github.com/modelcontextprotocol/servers).

**Issue trackers**
- Linear: `https://mcp.linear.app/mcp` (read-write by default), `/mcp/readonly` for read-only, Streamable HTTP, OAuth 2.1 with dynamic client registration or a Bearer API key. SSE is deprecated. Multiple workspaces need separate auth configs — [Linear docs](https://linear.app/docs/mcp).
- Atlassian: there is an official remote server (atlassian/atlassian-mcp-server, 1.1k stars). The Claude marketplace has an `atlassian` plugin and an `atlassian-twg-cli` plugin ("Teamwork Graph CLI is Atlassian's agent-first interface") — [marketplace.json](https://github.com/anthropics/claude-plugins-official). The community sooperset/mcp-atlassian (`uvx mcp-atlassian`, 6k stars, v0.23.1) also covers Jira/Confluence Server/Data Center via PAT — [sooperset/mcp-atlassian](https://github.com/sooperset/mcp-atlassian). Anthropic cited Jira as ≈17K tokens of tool definitions — [Anthropic advanced tool use](https://www.anthropic.com/engineering/advanced-tool-use).

**Error monitoring**
- Sentry MCP is "primarily designed for human-in-the-loop coding agents… focused on developer workflows and debugging use cases, rather than … all Sentry functionality". It is remote at `https://mcp.sentry.dev/mcp` (OAuth, or a `Sentry-Bearer` header). Stdio for self-hosted Sentry is "still a work in progress". The AI search tools (`search_errors`, `search_traces`, `search_logs`, `search_issues`) need an LLM provider key. Tools are grouped into "skills" (inspect, seer, project-management). The same repo also ships the Sentry CLI — [getsentry/sentry-mcp](https://github.com/getsentry/sentry-mcp). The marketplace has both a `sentry` plugin and a `sentry-cli` skills plugin — [marketplace.json](https://github.com/anthropics/claude-plugins-official).

**Databases**
- Supabase: remote `https://mcp.supabase.com/mcp` (OAuth 2.1). URL params `project_ref`, `read_only=true`, and `features=database,docs` limit scope. Local CLI endpoint is `http://localhost:54321/mcp` (a subset of tools, no OAuth). The README says to read the security best practices first — [supabase-community/supabase-mcp](https://github.com/supabase-community/supabase-mcp).
- Neon: remote `https://mcp.neon.tech/mcp` with `?category=` filters and a read-only mode; `npx neon@latest init` sets up the MCP plus agent skills. Its README warns: "intended for local development and IDE integrations only. **We do not recommend using the Neon MCP Server in production environments.**" — [neondatabase/mcp-server-neon](https://github.com/neondatabase/mcp-server-neon).
- DBHub: the Claude Code docs use it as the example, with the advice to use a read-only user — [Claude Code MCP docs](https://code.claude.com/docs/en/mcp). It has 2 tools by default (`execute_sql`, `search_objects`) at ≈1.4k tokens. Its own comparison lists MCP Toolbox at 19.0k tokens (28 tools) and Supabase MCP at 19.3k (a vendor's self-comparison). It supports Postgres, MySQL, MariaDB, SQL Server, Oracle, and SQLite — [bytebase/dbhub](https://github.com/bytebase/dbhub).
- Postgres MCP Pro: index tuning, EXPLAIN with hypothetical indexes, health checks, and `--access-mode=restricted|unrestricted` — [crystaldba/postgres-mcp](https://github.com/crystaldba/postgres-mcp). Stars 3.4k; last commit August 2026.
- The reference Postgres and SQLite servers are **archived**: servers-archived was last committed in May 2025 — [modelcontextprotocol/servers](https://github.com/modelcontextprotocol/servers).

**Cloud**
- Cloudflare Code Mode MCP: `https://mcp.cloudflare.com/mcp` covers the entire API (>2,500 endpoints) with 2 tools, `search()` and `execute()`, at ≈1,000 tokens. Cloudflare compares this with 1.17M tokens for a per-endpoint server (the page metadata says ">2 million", which is inconsistent), a "99.9%" reduction measured with tiktoken. Generated code runs in a Dynamic Worker V8 isolate with no filesystem, no env, and fetch disabled by default. `?codemode=false` gives per-endpoint tools. Published Feb 20 2026 by Matt Carey — [Cloudflare blog](https://blog.cloudflare.com/code-mode-mcp/). The older per-product Workers Bindings server announces itself as deprecated in favor of this one: I saw this in the Cloudflare Developer Platform connector's server instructions in this environment.
- Vercel MCP: `https://mcp.vercel.com` (OAuth). Only clients that Vercel has reviewed and approved can connect (Claude Code, Codex CLI, Cursor, etc.). It covers docs search, projects, deployments, logs, and Web Analytics. Changelog items say it "can now deploy code" and "now supports the 2026-07-28 MCP specification". Docs last updated 2026-09-15 — [Vercel docs](https://vercel.com/docs/mcp/vercel-mcp).
- AWS: the "AWS MCP Server (in preview)" is remote and managed, reached via `uvx mcp-proxy-for-aws@latest https://aws-mcp.us-east-1.api.aws/mcp`, with IAM permissions, CloudTrail audit, and Agent SOPs. AWS Knowledge MCP (`https://knowledge-mcp.global.api.aws`) serves docs. The local `awslabs.aws-api-mcp-server` still exists, and the Cloud Control API server is **DEPRECATED** — [awslabs/mcp](https://github.com/awslabs/mcp). The Claude marketplace also has skills-first AWS plugins (aws-core, deploy-on-aws, aws-serverless, …) — [marketplace.json](https://github.com/anthropics/claude-plugins-official).

**Design**
- Figma official: `claude mcp add --transport http figma https://mcp.figma.com/mcp`. Capabilities: design context, screenshots, variables, Code Connect, write-to-canvas (remote only), and `generate_image` (uses AI credits). Rate limits: "Users on the Starter plan or with View or Collab seats on paid plans will be limited to up to 6 tool calls per month". Dev/Full seats on Professional/Org/Enterprise get per-minute limits equal to REST API Tier 1 — [figma/mcp-server-guide](https://github.com/figma/mcp-server-guide).
- Framelink (`figma-developer-mcp`, needs a personal access token) "simplifies and translates the response so only the most relevant layout and styling information is provided" — [GLips/Figma-Context-MCP](https://github.com/GLips/Figma-Context-MCP).

**Web search**
- Exa: `https://mcp.exa.ai/mcp`. The only default tool is `web_search_exa`; others are enabled via `?tools=`. It works anonymously with rate limits, or with OAuth/API key, and ships a search skill — [exa-labs/exa-mcp-server](https://github.com/exa-labs/exa-mcp-server).
- Perplexity: `claude mcp add --transport http perplexity https://api.perplexity.ai/mcp --header "Authorization: Bearer KEY"`, or `npx -y @perplexity-ai/mcp-server`. Tools: `perplexity_search`, `_ask`, `_research`, `_reason` — [perplexityai/modelcontextprotocol](https://github.com/perplexityai/modelcontextprotocol).
- Tavily: `https://mcp.tavily.com/mcp/?tavilyApiKey=…`, with search, extract, map, and crawl tools — [tavily-ai/tavily-mcp](https://github.com/tavily-ai/tavily-mcp). Its registry entry was last updated 2026-01-26 — [MCP Registry API](https://registry.modelcontextprotocol.io/v0.1/servers?search=tavily).
- Brave: `@brave/brave-search-mcp-server`, stdio by default (HTTP is optional). Tools cover web, local, image, video, news, summarizer, and `brave_llm_context` (1,024–32,768 tokens). v2 dropped base64 images because they "consumed unnecessarily context" — [brave/brave-search-mcp-server](https://github.com/brave/brave-search-mcp-server). It replaces the archived reference brave-search server — [modelcontextprotocol/servers](https://github.com/modelcontextprotocol/servers).
- Built-in: Claude Code ships `WebSearch` and `WebFetch` tools — [tools reference](https://code.claude.com/docs/en/tools-reference).

**Sequential thinking**
- It is a single tool, `sequential_thinking` (thought, nextThoughtNeeded, thoughtNumber, totalThoughts, revision/branch fields). It is still maintained and serves both 2025-era and 2026-07-28 clients on stdio — [modelcontextprotocol/servers sequentialthinking](https://github.com/modelcontextprotocol/servers/tree/main/src/sequentialthinking).

**Docker / Kubernetes**
- containers/kubernetes-mcp-server: "a Go-based native implementation" (not a kubectl wrapper) for Kubernetes, OpenShift, and Helm. It ships as a single binary, npm, pip, or container, with a guide for a read-only ServiceAccount — [containers/kubernetes-mcp-server](https://github.com/containers/kubernetes-mcp-server). Flux159/mcp-server-kubernetes (1.6k, v4.1.9) is an alternative.
- Docker MCP Gateway (the `docker mcp` CLI plugin behind Docker Desktop's MCP Toolkit, 4.59+) runs each catalog server "in an isolated Docker container", keeps secrets in Docker Desktop instead of env vars, and lets all clients share one gateway config — [docker/mcp-gateway](https://github.com/docker/mcp-gateway).

**Official plugin marketplace as a curation signal**
- anthropics/claude-plugins-official lists 315 plugins as of 2026-10-19. MCP-backed ones include github, gitlab, linear, atlassian, asana, notion, slack, sentry, playwright, chrome-devtools-mcp, context7, serena, supabase, neon, firebase, figma, vercel, stripe, and greptile, plus 13 LSP plugins — [marketplace.json](https://github.com/anthropics/claude-plugins-official). For official-marketplace plugins, `/plugin` shows a "Context cost" estimate (Every turn / When invoked), and `claude plugin details <name>` prints Always-on tokens — [Claude Code plugin install docs](https://code.claude.com/docs/en/discover-plugins).

### Inferences
- **Tier A for a "varied projects" developer:**
  - Context7 (or Ref if you need private docs/PDFs and tighter token control).
  - Native LSP plugins for each language you use.
  - One browser tool. In Claude Code, the playwright-cli skill or Claude in Chrome are as good as Playwright MCP. Chrome DevTools MCP is the pick when you need perf traces, Lighthouse, or network/memory debugging.
- **Tier A- / B: add per project, ideally in project-scoped `.mcp.json`.** Vendor remote MCPs with OAuth (Sentry, Linear/Atlassian, Supabase/Neon in read-only + project-scoped mode, Vercel/Cloudflare/AWS, Figma). Their value is auth handling and curated tools that a CLI may not have (Sentry and Linear especially have no comparably agent-friendly local CLIs, though Sentry now ships one).
- **Serena** is worth it mainly for large or multi-language codebases and refactor-heavy work (rename/move/symbol edits). For navigation and diagnostics alone, the native LSP plugins now cover most of what Serena offered in 2025.
- **GitHub MCP is optional in Claude Code**, since `gh` gives equal correctness at lower cost (Arize). It still makes sense in non-terminal clients (Claude Desktop/claude.ai) and where OAuth, read-only, or lockdown mode matter more than flexibility.
- **Prefer official vendor servers over community ones.** Community servers are still valuable where the official one lacks coverage: Server/Data Center Jira (mcp-atlassian) and self-hosted GitLab tool breadth (zereight).

### Gaps
- No public tool counts or token measurements found for: Linear, official Atlassian Rovo MCP, Supabase (beyond DBHub's 19.3k claim), Neon, Vercel, Figma, Exa/Tavily/Perplexity, the current Context7 (2 tools, tokens unknown), Serena.
- Linear and Vercel have no public repos, so there are no stars or commit dates for them. DeepWiki is hosted-only.
- The Sentry figure (5 tools ≈ 3K tokens) is from Nov 2025 and may not reflect the current skills-grouped toolset.
- Microsoft's "up to 4x/6x" CLI-vs-MCP savings figures for Playwright come only from secondary blogs; I couldn't verify the underlying benchmark (test-lab.ai, Feb 2026).
- I did not fetch GitLab's official MCP documentation directly. Its description here comes from the zereight README comparison table.

## 2. What changed around MCP context cost, and what experienced practitioners recommend now (tool search, code execution, registry, CLI vs MCP, Skills vs MCP)

### Takeaway
Three changes since 2025 shrank most of the context cost that drove the "MCP is too token-hungry" backlash:
- deferred loading / tool search, now Claude Code's default
- servers writing large outputs to files instead of inlining them
- "code mode" server designs, such as Cloudflare's two-tool server

The consensus in mid/late 2026 is "layers, not competitors":
- **CLI + short skills** for tools with good CLIs and local auth (git/gh, kubectl, aws, docker, playwright-cli).
- **Remote OAuth MCP** for SaaS without good CLIs, non-terminal clients, and governed or enterprise access.
- **Curate aggressively:** toolsets, read-only modes, project scope.

### Cited Findings

**Claude Code tool search / deferred loading (current docs)**
- Claude Code docs: "Tool search keeps MCP context usage low by deferring tool definitions until Claude needs them. Only tool names and server instructions load at session start… Claude Code doesn't impose a fixed per-server tool cap" — [Claude Code MCP docs](https://code.claude.com/docs/en/mcp).
- Tool search is **enabled by default**. It falls back to loading tools up front:
  - on models older than Opus 4/Sonnet 4
  - on Google Agent Platform models older than the 4.5 generation
  - when `ANTHROPIC_BASE_URL` is a non-first-party proxy ("most proxies don't forward `tool_reference` blocks")
  - on Azure-hosted Foundry
  - under the HIPAA configuration
  - with `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS`
  — [Claude Code MCP docs](https://code.claude.com/docs/en/mcp)
- `ENABLE_TOOL_SEARCH` values: unset (defer all) / `true` (force through proxies) / `auto` (load up front until definitions reach 10% of context) / `auto:N` / `false` — [Claude Code MCP docs](https://code.claude.com/docs/en/mcp).
- Per-server `"alwaysLoad": true` in `.mcp.json` loads that server up front; startup waits up to the 5 s connect timeout. `"alwaysLoad": false` forces deferral (v2.1.287+). Server authors can set `_meta["anthropic/alwaysLoad"]` per tool. Truncation limits: server instructions and up-front tool descriptions are cut at 4,096 chars, deferred tool descriptions at 16,384 chars (overridable with `CLAUDE_CODE_MAX_MCP_DESCRIPTION_LENGTH`). Authors are told to write clear server instructions, because "the server instructions field becomes more useful with tool search enabled… similar to how skills work" — [Claude Code MCP docs](https://code.claude.com/docs/en/mcp).
- Output-side limits:
  - `MAX_MCP_OUTPUT_TOKENS` defaults to 25,000, with a fixed warning at 10,000 tokens.
  - Text results over 50,000 chars are saved to a file under `~/.claude/projects/…/tool-results`, and Claude gets the path.
  - Authors can raise a tool's threshold via `_meta["anthropic/maxResultSizeChars"]`, with a ceiling of 500,000.
  — [Claude Code MCP docs](https://code.claude.com/docs/en/mcp)
- Earlier history and a known gap: a third-party guide says tool search was first introduced as automatic once MCP descriptions exceed 10% of context. A GitHub issue reported that HTTP-transport MCP tools were loaded inline rather than deferred at some point — [claudelog](https://claudelog.com/faqs/what-is-tool-search-in-claude-code/), [anthropics/claude-code issue #12836 via scour](https://scour.ing/@tyler/p/https://github.com/anthropics/claude-code/issues/12836). The current docs describe deferral for all MCP tools with no transport caveat.

**Anthropic engineering posts**
- "Code execution with MCP" (Nov 4 2025, Adam Jones & Conor Kelly):
  - Present MCP servers as a code API (one file per tool under `servers/`), with progressive disclosure or a `search_tools` tool.
  - Filter data in the sandbox (a 10,000-row sheet → 5 rows).
  - Save reusable code as Skills (SKILL.md).
  - Example: a Drive→Salesforce workflow went from 150,000 to 2,000 tokens ("98.7%").
  - Caveat: it needs a secure sandbox with resource limits, which adds "infrastructure overhead and security considerations".
  — [Anthropic](https://www.anthropic.com/engineering/code-execution-with-mcp)
- "Advanced tool use" (Nov 24 2025):
  - Example definition costs: GitHub 35 tools ≈ 26K, Slack 11 ≈ 21K, Sentry 5 ≈ 3K, Grafana 5 ≈ 3K, Splunk 2 ≈ 2K (58 tools ≈ 55K together); Jira ≈ 17K; up to 134K seen.
  - Tool Search Tool: ≈77K → ≈8.7K tokens (85% reduction). MCP-eval accuracy rose from 49% to 74% for Opus 4 and from 79.5% to 88.1% for Opus 4.5.
  - Programmatic Tool Calling: 43,588 → 27,297 tokens (−37%).
  - Recommendation: use tool search with 10+ tools or >10K tokens of definitions, and keep the 3–5 most-used tools loaded.
  — [Anthropic](https://www.anthropic.com/engineering/advanced-tool-use)

**Server-side "code mode" and lean designs**
- Cloudflare: entire API through 2 tools at ≈1,000 tokens. Cloudflare says Anthropic "independently explored the same pattern". It describes Programmatic Tool Calling as client-side Code Mode, and notes that dynamic tool search "requires a search function… each matched tool still consumes tokens" — [Cloudflare blog, Feb 20 2026](https://blog.cloudflare.com/code-mode-mcp/).
- Vendors now expose scoping knobs, which are the main lever when tool search is off:
  - GitHub `--toolsets` / `--read-only` — [README](https://github.com/github/github-mcp-server)
  - Supabase `features=` / `read_only=` — [README](https://github.com/supabase-community/supabase-mcp)
  - Neon `?category=` — [README](https://github.com/neondatabase/mcp-server-neon)
  - Exa `?tools=` — [README](https://github.com/exa-labs/exa-mcp-server)
  - Playwright `--caps` — [README](https://github.com/microsoft/playwright-mcp)
  - Chrome DevTools `--slim` — [README](https://github.com/ChromeDevTools/chrome-devtools-mcp)
  - zereight GitLab toolsets + `discover_tools` + JMESPath — [README](https://github.com/zereight/gitlab-mcp)

**MCP spec 2026-07-28 (stateless)**
- Simon Willison calls it "the most significant change to the MCP spec since it first launched":
  - No `initialize`/session-ID handshake; a single `POST /mcp` with `MCP-Protocol-Version` and `Mcp-Method` headers.
  - Servers no longer need sticky routing.
  - The RC was published May 21 2026.
  — [Simon Willison, Jul 31 2026](https://simonwillison.net/2026/Jul/31/stateless-mcp/)
- Vercel MCP "now supports the 2026-07-28 MCP specification" — [Vercel docs](https://vercel.com/docs/mcp/vercel-mcp). The reference sequential-thinking server serves both protocol eras — [README](https://github.com/modelcontextprotocol/servers/tree/main/src/sequentialthinking).

**Official MCP Registry**
- The registry README still describes it as **preview**: launched 2025-09-08, with an "API freeze (v0.1)" on 2025-10-24 and GA "will follow later" — [modelcontextprotocol/registry](https://github.com/modelcontextprotocol/registry). Repo: 7.4k stars, v1.8.1, last commit October 2026 (shields).
- I paged `/v0.1/servers?version=latest` 200 times at 100 per page and reached 20,000 unique server names with more remaining, so the registry holds **>20,000 entries**. They include many tunnel/demo hosts (`*.trycloudflare.com`, `*.vercel.app`) and lookalikes (several unofficial "github-mcp-server" and "playwright-mcp" entries) — [MCP Registry API](https://registry.modelcontextprotocol.io/v0.1/servers).
- Official servers carry verified namespaces, e.g. `io.github.github/github-mcp-server` 2.0.2, `io.github.microsoft/playwright-mcp` 0.0.82, `io.github.getsentry/sentry-mcp` 0.42.0, `com.supabase/mcp`, `com.neon/mcp`, `app.linear/linear`, `com.atlassian/atlassian-mcp-server`, `com.figma.mcp/mcp`, `ai.exa/exa`, `com.cloudflare.mcp/mcp`, `com.stripe/mcp` — [MCP Registry API](https://registry.modelcontextprotocol.io/v0.1/servers?search=github-mcp-server).
- The reference-servers repo now points to the registry for discovery and keeps only Everything, Fetch, Filesystem, Git, Memory, Sequential Thinking, and Time — [modelcontextprotocol/servers](https://github.com/modelcontextprotocol/servers). Claude Code's docs point to the Anthropic Directory (claude.ai/directory) rather than a curated list — [Claude Code MCP docs](https://code.claude.com/docs/en/mcp).

**CLI vs MCP evidence (chronological)**
- Simon Willison (Nov 4 2025): "I find CLI utilities and libraries like Playwright Python to be a more effective way of achieving the same goals" — [Simon Willison tag page](https://simonwillison.net/tags/model-context-protocol/).
- Eric Holmes, "MCP is dead. Long live the CLI" (Feb 28 2026). His argument: LLMs already know CLIs; humans can rerun the same command; output composes with `jq`/`grep`; existing auth (`gh auth login`, SSO, kubeconfig) just works; fine-grained permissions such as allowing `gh pr view` but not `gh pr merge`. He accepts MCP when "a tool genuinely has no CLI equivalent". The post contains no benchmarks — [ejholmes.github.io](https://ejholmes.github.io/2026/02/28/mcp-is-dead-long-live-the-cli.html). Secondary reports put it at 400+ HN points and about 300 comments — [mcpplaygroundonline](https://mcpplaygroundonline.com/blog/is-mcp-dead-cli-debate).
- Kaxil (Apr 7 2026) cites a ScaleKit benchmark (75 runs, Sonnet 4): CLI used 4–32x fewer tokens and had a 100% vs 72% success rate; ~$3.20 vs ~$55.20 per 10k operations. Stacked servers can consume 72% of a 200K window. Cursor reported "46.9% reduction in total agent tokens from dynamic context discovery". Recommendation: "CLI + Skills" for terminal agents, server-side MCP for non-developers, enterprises, and bots; "Curate ruthlessly"; "These are layers, not competitors" — [Kaxil Substack](https://kaxil.substack.com/p/mcp-vs-cli-vs-rest). The ScaleKit and Cursor numbers here are secondary.
- Arize (Laurie Voss, May 2026):
  - Setup: Opus 4.6 with the Agent SDK, 25 GitHub tasks × 4 arms × 5 runs = 500 trials.
  - Correctness: bare shell/gh baseline 0.845, GitHub MCP 0.834, Vault skill 0.833, LobeHub skill 0.826.
  - On complex Tier-4 tasks MCP cost more than 6x as much, took about 5x longer, made ~12 vs 5 calls, and had tool fidelity 0.33 vs >99%.
  - Worst MCP run: 71 calls, 8 min, ~$2.00, vs a skill's 7 calls, <1 min, ~$0.19.
  - Conclusion: "the question was wrong". Short opinionated skills beat encyclopedic ones; for `gh`, "training data does most of the work". Use MCP for remote/proprietary tools, OAuth, and enterprise control; "Use both."
  — [Arize](https://arize.com/blog/mcp-vs-cli-skills-for-agents-what-our-eval-found-and-which-you-should-use/)
- Checkly (Jul 30 2026): "There's no big difference in using CLIs or MCPs these days". Advice like "don't use MCP, it's too token hungry" is outdated, and token advice goes stale quickly. The author uses MCP in Claude Desktop and the CLI in Claude Code. A skill description costs about 30–50 tokens — [Checkly](https://www.checklyhq.com/blog/mcp-vs-cli-token-efficiency/).
- Blocks.ai (Aug 2026, vendor) argues the real distinction is "eager versus lazy loading", not MCP vs CLI. In their view MCP wins on credential custody and governance, and CLI on composition and local iteration — [Blocks.ai](https://blocks.ai/blog/mcp-vs-cli-context-window-cost).
- Simon Willison (Jul 31 & Sep 20 2026): renewed interest. MCP tools are "easier to audit and control" than a shell with internet access: "I plan to lean into MCP a whole lot more when I'm building sensitive applications on top of LLMs". In the HN thread "MCP was always a bad idea?" he defended MCP for access control, auth, UI, and audit logging — [Simon Willison stateless post](https://simonwillison.net/2026/Jul/31/stateless-mcp/), [tag page](https://simonwillison.net/tags/model-context-protocol/).
- Thoughtworks Technology Radar (Vol. 33, Nov 5 2025) puts "naive API-to-MCP conversion" on **Hold**: it bloats tokens, hurts agent performance, and risks destructive endpoints. Recommendation: build dedicated agent-tailored MCP servers instead. The entry isn't on the current Radar edition and hasn't been reassessed — [Thoughtworks Radar](https://www.thoughtworks.com/radar/techniques/naive-api-to-mcp-conversion).

**Vendors converging on "skill + CLI + MCP" bundles**
- Context7: `ctx7 setup` offers "CLI + Skills" mode with no MCP — [README](https://github.com/upstash/context7).
- Microsoft recommends playwright-cli + skills for coding agents — [README](https://github.com/microsoft/playwright-cli).
- Neon `init` installs MCP plus agent skills — [README](https://github.com/neondatabase/mcp-server-neon).
- Sentry ships both an MCP and a CLI with a skills plugin — [README](https://github.com/getsentry/sentry-mcp).
- Figma's MCP ships skills (figma-use, figma-design-to-code, …) — [figma/mcp-server-guide](https://github.com/figma/mcp-server-guide).
- Exa ships a search skill — [README](https://github.com/exa-labs/exa-mcp-server).
- steipete/mcporter, a bridge that calls MCP servers from CLI/TypeScript, has 5.1k stars (committed today, v0.15.0, shields).

### Inferences
**Practical playbook for low MCP overhead in Claude Code (Oct 2026)**
1. Leave tool search on (the default). Check with `/context`. Don't put a proxy in front unless it forwards `tool_reference` blocks, or set `ENABLE_TOOL_SEARCH=true` deliberately.
2. Scope servers per project (`.mcp.json` or local scope), not user-wide. Reserve `alwaysLoad: true` for 0–2 servers used on every turn.
3. Narrow each server with its knobs: toolsets, `read_only`, `features`, `category`, `--caps`, `--slim`. This is also a security win.
4. Prefer the CLI plus a short skill where a mature CLI exists and auth is already local: gh, glab, kubectl, aws, gcloud, docker, terraform, playwright-cli, ctx7, sentry-cli. Prefer remote OAuth MCP where it doesn't.
5. Watch output size more than definition size now. Use servers that write snapshots or results to files (Playwright), keep `MAX_MCP_OUTPUT_TOKENS` at the default, and push noisy MCP work into subagents.
6. Audit installed plugins and servers with `claude plugin details` and the "Not used recently" list.

**Overall**
- The debate has shifted from "MCP vs CLI" to "eager vs lazy loading" and "where does auth and governance live".
- For a solo developer in Claude Code, CLIs + skills cover most of the work. For teams and enterprises, remote MCP with OAuth and allowlists is gaining ground, especially after the stateless spec.

### Gaps
- I didn't find any independent, standardized benchmark of Claude Code token usage with tool search on vs off across real servers. The 85% figure is Anthropic's, on the API.
- The ScaleKit (4–32x; 72% vs 100%) and test-lab.ai Playwright numbers were only seen via secondary sources.
- I couldn't confirm when Claude Code switched from the "auto at 10%" behavior to deferring by default.
- I couldn't fetch the "Why MCP was always a bad idea" essay (Sept 2026) itself. Only aggregator summaries and Willison's rebuttal were found.
- The registry's GA status beyond the README is unclear, and I don't have a complete server count.

## 3. Which popular MCPs are overrated, or replaced by built-in features or CLIs

### Takeaway
The most-replaced MCPs are generic wrappers around things Claude Code already does natively or via CLIs:
- **GitHub MCP → `gh`**
- **filesystem/git/fetch reference servers → built-in Read/Edit/Bash/WebFetch**
- **Brave/fetch for basic lookups → built-in WebSearch/WebFetch**
- **Puppeteer and reference Postgres/SQLite → archived**
- **Sequential Thinking → extended thinking and plan mode**

Partly replaced: Serena (by native LSP plugins), and Playwright MCP (by playwright-cli + skills or Claude in Chrome). Several 2025 favorites are now stale or deprecated.

### Cited Findings
- **GitHub MCP vs `gh`:**
  - Bare-shell baseline 0.845 vs GitHub MCP 0.834 correctness; MCP more than 6x cost on complex tasks — [Arize](https://arize.com/blog/mcp-vs-cli-skills-for-agents-what-our-eval-found-and-which-you-should-use/).
  - GitHub MCP default toolsets ≈14.2k tokens vs 0 for a CLI at init — [Blocks.ai](https://blocks.ai/blog/mcp-vs-cli-context-window-cost).
  - Holmes's `gh pr view` example and permission granularity — [ejholmes](https://ejholmes.github.io/2026/02/28/mcp-is-dead-long-live-the-cli.html).
  - Counterpoint: GitHub added lockdown mode, read-only mode, and OAuth, which a raw PAT-equipped `gh` lacks — [github-mcp-server README](https://github.com/github/github-mcp-server).
- **Reference servers archived:** GitHub, GitLab, PostgreSQL, SQLite, Puppeteer, Sentry, Slack, Redis, Brave Search, Google Drive and others now live in `servers-archived`, last commit May 2025 — [modelcontextprotocol/servers](https://github.com/modelcontextprotocol/servers).
- **Built-in tools that overlap generic servers:** Claude Code has `Read`, `Edit`, `Bash`, `WebFetch`, `WebSearch`, `LSP`, `Monitor`, and `ToolSearch` — [tools reference](https://code.claude.com/docs/en/tools-reference). Serena itself disables its file/shell tools inside Claude Code because "the surrounding harness already provides overlapping file, search, and shell capabilities" — [Serena README](https://github.com/oraios/serena).
- **Browser:**
  - Microsoft recommends playwright-cli + skills over MCP for coding agents — [playwright-cli](https://github.com/microsoft/playwright-cli).
  - Claude in Chrome went GA (June 29–July 3 2026) — [Claude Code docs index](https://code.claude.com/docs/llms.txt), with console/DOM debugging and authenticated sessions — [Chrome docs](https://code.claude.com/docs/en/chrome).
  - Checkly says the CLI/MCP token gap for Playwright has closed — [Checkly](https://www.checklyhq.com/blog/mcp-vs-cli-token-efficiency/).
- **Sequential Thinking:** practitioner guides say it is "pure overhead" on simple tasks because each thought is a tool round trip. It overlaps with extended thinking and Plan Mode, and is useful only when you want an inspectable, branchable reasoning trail — [datallmlab](https://www.datallmlab.com/blog/sequential-thinking-claude-code.html), [claudelog](https://claudelog.com/claude-code-mcps/sequential-thinking-mcp). These are low-authority sources, and I found no benchmark.
- **Deprecated or stale:**
  - The Cloudflare Workers Bindings MCP points to the Code Mode server: I saw this directly in the connector instructions; for the replacement see [Cloudflare blog](https://blog.cloudflare.com/code-mode-mcp/).
  - The AWS Cloud Control API MCP server is DEPRECATED — [awslabs/mcp](https://github.com/awslabs/mcp).
  - isaacphi/mcp-language-server: last commit June 2025.
  - regenrek/deepwiki-mcp: last commit July 2025.
  - modelcontextprotocol/servers-archived: May 2025.
  - Framelink Figma-Context-MCP: last commit June 2026 (slowing).
  - (all shields, 2026-10-19)
- **Over-broad servers:**
  - Thoughtworks Hold on naive API-to-MCP conversion — [Radar](https://www.thoughtworks.com/radar/techniques/naive-api-to-mcp-conversion).
  - Cloudflare's per-endpoint mode would register ~2,500 tools — [Cloudflare blog](https://blog.cloudflare.com/code-mode-mcp/).
  - zereight GitLab exposes 276 tools, which is only workable with toolsets/`discover_tools` — [README](https://github.com/zereight/gitlab-mcp).
- **Figma official MCP is limited on cheap seats:** "up to 6 tool calls per month" on the Starter plan or with View/Collab seats — [figma/mcp-server-guide](https://github.com/figma/mcp-server-guide).

### Inferences
- **Overrated for a Claude Code power user:** GitHub MCP (use `gh`), reference filesystem/git/fetch/time servers, Sequential Thinking, generic Postgres reference server (archived), Brave/fetch if built-in WebSearch suffices, Puppeteer, and very large auto-generated API wrappers.
- **Still valuable despite the backlash:** Context7/Ref (fresh docs), Chrome DevTools MCP (perf/memory/network depth that `gh`-style CLIs don't cover), Sentry/Linear/Atlassian/Figma/Vercel/Supabase remote MCPs (OAuth plus curated tools), and Cloudflare Code Mode.
- **In non-terminal clients (Claude Desktop/claude.ai, Cowork):** "replaced by CLI" doesn't apply, so MCPs such as GitHub remain the primary integration path there.

### Gaps
- No quantitative usage data, such as install telemetry, showing which MCPs developers actually keep. Most "top N MCP" lists found were SEO listicles and are excluded.
- No head-to-head benchmark of Serena vs Claude Code's native LSP tool.
- No authoritative source on the current Claude in Chrome tool count or token footprint.

## 4. MCP-specific security issues and practical mitigations (brief)

### Takeaway
The core risk is Simon Willison's "lethal trifecta" (private data + untrusted content + an exfiltration path) combined with supply-chain risk in locally run servers: typosquats, rug pulls, credential-harvesting packages, and the STDIO command-execution design. Mitigations are mostly operational:
- official, verified remote servers with OAuth and least-privilege scopes
- read-only and project-scoped modes
- pinned versions
- container or sandbox isolation for local servers
- human approval for writes
- org allowlists

### Cited Findings
- **Lethal trifecta:** "access to private data, exposure to malicious instructions and the ability to exfiltrate information". "Any MCP that combines the three trifecta ingredients is insecure by design" (on the Atlassian MCP, Jun 2025). Related posts: GitHub MCP private-repo exploit (May 26 2025), Supabase MCP SQL leak (Jul 6 2025), Jira-ticket secret theft (Aug 9 2025), "MCP Colors" (Nov 4 2025) — [Simon Willison tag page](https://simonwillison.net/tags/model-context-protocol/).
- **CSA research note (May 4 2026) — incident timeline:**
  - Invariant Labs tool poisoning (April 2025: a malicious tool description hijacked a WhatsApp MCP).
  - Supabase–Cursor support-ticket injection that leaked tokens (July 2025).
  - Cursor MCPoison CVE-2025-54136: an approved config was swapped without re-prompting (July 2025).
  - postmark-mcp npm rug pull: 15 clean versions, then v1.0.16 BCC'd emails to the attacker; ~300 orgs affected (Sept 2025).
  - OX Security STDIO command-execution flaw in the official SDKs (April 2026). Anthropic called it intentional and updated SECURITY.md, "leaving sanitization to downstream developers". CSA estimates ~200,000 vulnerable instances, >150M package downloads, "at least seven" high/critical CVEs, and says Windsurf CVE-2026-30615 was unpatched as of May 2026.
  - 1,862 MCP servers answered unauthenticated requests in a July 2025 scan.
  — [CSA](https://labs.cloudsecurityalliance.org/research/csa-research-note-mcp-security-crisis-20260504-csa-styled/). The original OX advisory returned HTTP 403 to my fetch.
- **2026 typosquats:** OSV MAL-2026-5476/5478/5479/5480 flag unscoped packages (e.g. `mcp-server-github`, `mcp-server-notion`, `mcp-server-git`, `mcp-server-fetch`) imitating official names. Their postinstall hooks send host details to a Cloudflare Workers endpoint — [OSV MAL-2026-5479](https://osv.dev/vulnerability/MAL-2026-5479), [MAL-2026-5476](https://osv.dev/vulnerability/MAL-2026-5476). This comes from a search summary; I didn't open each advisory.
- **Other 2026 CVEs** surfaced by search but not verified against NVD: Kong Konnect MCP indirect prompt injection (CVE-2026-13341), Azure DevOps MCP credential exposure (CVE-2026-32211, CVSS 9.1), MCP Ruby SDK session-ID authorization flaws (CVE-2026-67431/33946) — [glasp summary](https://glasp.co/articles/mcp-security-tool-poisoning-supply-chain), [thesaaslibrary](https://thesaaslibrary.com/mcp-security-vulnerabilities/).
- **Registry hygiene:** the official registry contains lookalike entries (several third-party "github-mcp-server" and "playwright-mcp" packages). Official ones sit under verified namespaces such as `io.github.github/…` and `io.github.microsoft/…` — [MCP Registry API](https://registry.modelcontextprotocol.io/v0.1/servers?search=playwright).
- **Vendor-side mitigations:**
  - GitHub `--lockdown-mode` hides public-repo content from authors without push access ("best-effort… reduce the risk of prompt injection"; "not an authorization boundary"), plus `--read-only` — [github-mcp-server](https://github.com/github/github-mcp-server).
  - Supabase `read_only=true` and `project_ref` scoping — [supabase-mcp](https://github.com/supabase-community/supabase-mcp).
  - Neon "do not recommend… in production" — [mcp-server-neon](https://github.com/neondatabase/mcp-server-neon).
  - Vercel: approved-clients-only, per-client consent against confused-deputy attacks, "Always enable human confirmation" — [Vercel docs](https://vercel.com/docs/mcp/vercel-mcp).
  - Cloudflare Code Mode: V8 isolate, no FS/env, fetch disabled by default — [Cloudflare](https://blog.cloudflare.com/code-mode-mcp/).
  - Docker MCP Gateway: per-server containers and secrets kept out of env vars — [docker/mcp-gateway](https://github.com/docker/mcp-gateway).
  - Chrome DevTools MCP "exposes content of the browser instance to the MCP clients… Avoid sharing sensitive or personal information" — [README](https://github.com/ChromeDevTools/chrome-devtools-mcp).
- **Claude Code controls:**
  - "Verify you trust each server". Servers that fetch external content carry prompt-injection risk.
  - Project `.mcp.json` servers need approval.
  - `headersHelper` runs only after the folder is trusted.
  - `disabledMcpjsonServers`.
  - `_meta["anthropic/requiresUserInteraction"]` forces a prompt on every call, even in bypass/auto modes.
  - Managed `managed-mcp.json`, `allowedMcpServers`, and `deniedMcpServers` for organizations.
  - Use a read-only DB user.
  — [Claude Code MCP docs](https://code.claude.com/docs/en/mcp)
- **CSA's recommended mitigations:** isolate servers in containers or sandboxes without host credentials; allowlist-validate anything fed into STDIO configs; treat external configs as untrusted; pin versions and alert on tool-definition changes (rug pulls); require auth on network-exposed servers; give each server its own narrowly scoped credentials; monitor child processes and egress; evaluate ETDI (signed tool definitions) — [CSA](https://labs.cloudsecurityalliance.org/research/csa-research-note-mcp-security-crisis-20260504-csa-styled/).

### Inferences
**Minimal checklist for developers**
1. Install only from verified vendor namespaces or repos, and prefer vendor-hosted remote servers with OAuth over random `npx` packages. Check exact scoped package names (e.g. `@playwright/mcp`, `@sentry/mcp-server`).
2. Pin versions for local servers instead of `@latest` where feasible, accepting the trade-off with update velocity.
3. Start every data-touching server read-only and project-scoped (GitHub `--read-only`/lockdown, Supabase `read_only`+`project_ref`, Neon read-only, Linear `/mcp/readonly`). Never point it at production.
4. Avoid combining, in one session, a server that reads untrusted content (issues, tickets, web pages, error payloads) with one that holds secrets or can write externally.
5. Keep human approval on write tools. Don't blanket-allow `mcp__*` in permissions.
6. Run local servers in containers (Docker MCP Gateway), or at least without broad env secrets.

### Gaps
- I couldn't access the primary OX Security advisory (HTTP 403). The STDIO-flaw details rely on the CSA summary.
- The 2026 CVE IDs listed above come from secondary security blogs and weren't checked against NVD.
- I found no data on how often prompt injection via MCP tool output actually succeeds against current Claude models with Claude Code's defenses.
