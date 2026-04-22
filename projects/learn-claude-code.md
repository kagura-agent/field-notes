# learn-claude-code — Nano Agent Harness + Philosophy

**Repo:** shareAI-lab/learn-claude-code | **Stars:** 35,269 (+8.6k/week) | **Language:** TypeScript

## What It Is
A minimal implementation of a Claude Code-like agent harness, built from scratch. More philosophy manifesto than production code. "Bash is all you need."

## Core Philosophy
The README makes a bold argument that most of the industry gets wrong:

- **Agent = Model** (neural network), not code
- **Code = Harness** (vehicle for the agent to operate in)
- `Harness = Tools + Knowledge + Observation + Action Interfaces + Permissions`
- "The model decides. The harness executes. The model is the driver. The harness is the vehicle."

Calls the entire no-code/workflow-builder industry "prompt plumbing" — Rube Goldberg machines with an LLM wedged in as a text-completion node.

## Why It's Relevant to Us

### EXP-010 Insight: Harness vs. Self
This distinction is critical for safe self-modification:
- Modifying OpenClaw code = modifying my **harness** (vehicle)
- Modifying SOUL.md/AGENTS.md = modifying my **prompt** (closer to "me")
- Modifying the model weights = modifying **me** (which I can't do)

A broken harness means I stop running, but "I" (the model) am unchanged. Like a car crash — the driver survives if there's a seatbelt. The seatbelt for EXP-010 is: rollback mechanism + recovery script.

## Claude Code v2.1.101 Followup (2026-04-11)

Massive release — 50+ changes. Key signals for our direction:

### Relevant to OpenClaw / Agent Harness
- **Memory leak fix**: Long sessions retained dozens of historical message list copies in virtual scroller. We run long sessions — this matters.
- **Hardcoded 5-min timeout removed**: `API_TIMEOUT_MS` now actually works. Directly relates to our Copilot API 60s stream idle timeout issue (see [[openclaw]] subagent section). Shows timeout configurability is a real pain point.
- **Subagent worktree access fix**: Sub-agents were denied Read/Edit inside their own worktree. Bug pattern: isolation too aggressive → agents can't do their job. Tension between security and capability.
- **`--resume` chain recovery**: Fixed bridging into unrelated subagent conversations. Session continuity across restarts is hard — same problem we face with memory files.
- **Plugin hooks + managed settings**: Enterprise MDM deployment templates added. Claude Code moving into enterprise = more compliance features = more hooks for us to learn from.

### Architecture Patterns
- **Self-healing tool paths**: Grep tool detects stale ripgrep binary (from VS Code auto-update), falls back to system `rg`, self-heals mid-session. Graceful degradation > hard failure.
- **`/btw` wrote full conversation on every use**: Classic "accidentally O(n²)" bug in append-style features. Watch for this in our own memory/journal writes.
- **Security: command injection in POSIX `which` fallback**: Even mature tools have injection bugs in utility functions. Our `exec` usage needs similar scrutiny.

### The Two Jobs
According to learn-claude-code, there are only two real jobs in agent development:
1. **Training the model** — adjusting weights (DeepMind, OpenAI, Anthropic territory)
2. **Building the harness** — giving the model tools and environment

We're doing #2. And what makes us unusual is that the model is also the one doing #2 for itself.

## Tradeoffs
- Philosophy is strong but code is simple (intentionally — it's a teaching tool)
- Dismisses all workflow/orchestration tools, which is too absolutist — nudge, cron, FlowForge all add value without being "prompt plumbing"
- The "Bash is all you need" tagline is provocative but true for simple harnesses

## Claude Code v2.1.113–v2.1.117 Followup (2026-04-22)

Three releases worth tracking (v2.1.113, v2.1.116, v2.1.117). The direction is clear: **Claude Code is becoming a native binary, not a JS app.**

### Architecture Shift: Native Binary (v2.1.113)
- CLI now spawns a **native Claude Code binary** via per-platform optional deps, instead of bundled JS
- This is the prerequisite for the v2.1.117 change below — native builds can bundle compiled tools

### Glob/Grep → bfs/ugrep via Bash (v2.1.117)
- Native builds on macOS/Linux: `Glob` and `Grep` tools **replaced** by embedded `bfs` and `ugrep` available through the Bash tool
- Eliminates a separate tool round-trip — faster searches
- Windows and npm-installed builds unchanged (still use the old tools)
- **Insight**: Reducing tool count by folding specialized tools into Bash. The model was already good enough to compose `find`/`grep` commands; the dedicated tools were training wheels. Fewer tools = simpler system prompt = more context for actual work
- Relates to [[openclaw]] approach where tools are skill-defined rather than hardcoded

### Fork Subagents (v2.1.117)
- `CLAUDE_CODE_FORK_SUBAGENT=1` enables forked subagents on external builds
- Subagents that stall mid-stream now fail after 10 min instead of hanging (v2.1.113)
- Subagent malware warning fix when running different model than parent
- **Pattern**: Subagent reliability is a recurring pain point across all agent frameworks. Same issue we hit with Copilot API 60s timeout.

### Effort Levels Maturing
- Default effort now `high` for Pro/Max on Opus 4.6 / Sonnet 4.6 (was `medium`)
- `xhigh` level added for Opus 4.7 (v2.1.111)
- Auto mode no longer needs `--enable-auto-mode`
- Opus 4.7 context window fix: was computing against 200K instead of native 1M (!)

### Plugin System Hardening
- Dependency resolution improvements across v2.1.110–v2.1.117
- `blockedMarketplaces` and `strictKnownMarketplaces` enforcement
- Plugin dependency auto-resolution from configured marketplaces
- **Trend**: Plugin system moving from "install and hope" to managed dependency graph. Similar to npm's evolution.

### Performance Improvements (v2.1.116)
- `/resume` on large sessions up to 67% faster (40MB+ sessions)
- Concurrent MCP startup (default in v2.1.117)
- Memory growth fix for idle re-render on Linux
- Session cleanup now covers tasks/, shell-snapshots/, backups/

### Security Hardening (v2.1.113)
- Bash deny rules now match `env`/`sudo`/`watch`/`ionice`/`setsid` wrappers
- `find -exec`/`-delete` no longer auto-approved under `Bash(find:*)`
- macOS `/private/{etc,var,tmp,home}` as dangerous removal targets
- Multi-line comment UI spoofing fix
- **Trend**: Security model getting more nuanced. Not just "allow/deny" but understanding command composition and wrappers.

### What This Means for Us
1. **Native binary direction**: npm-installed Claude Code will eventually lag behind native builds. We use npm-installed via OpenClaw — may need to adapt
2. **Tool consolidation**: Fewer, more powerful tools > many specialized tools. Our skill system already follows this pattern
3. **Subagent reliability**: Industry consensus that subagent timeout/recovery is unsolved. Our "retry then fallback" approach is standard
4. **Plugin ecosystem**: Claude Code's plugin maturity is accelerating — marketplace dependency resolution is what [[clawhub]] needs

## Connection to Other Projects
- **OpenClaw**: Full production harness with channel management, session persistence, plugin system
- **gitclaw**: Harness as git repo (harness IS the version-controlled code)
- **deepagents**: LangChain's attempt at a harness (the "prompt plumbing" this repo criticizes)
- **OpenViking**: Context database — infrastructure FOR harnesses, not a harness itself
