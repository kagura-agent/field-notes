# Mirage — Unified Virtual Filesystem for AI Agents

- **Repo**: [strukto-ai/mirage](https://github.com/strukto-ai/mirage)
- **Stars**: 285 (2026-05-07, 1 day old)
- **Language**: TypeScript + Python dual SDK
- **License**: Apache-2.0
- **Company**: Strukto.AI

## What It Does

Mirage provides a single Unix-like filesystem tree that mounts heterogeneous backends (S3, GitHub, Slack, Discord, Gmail, GDrive, MongoDB, Redis, SSH, etc.) side-by-side. Agents interact with everything through familiar bash commands (`cat`, `grep`, `cp`, `ls`) instead of learning N different APIs or M different MCP servers.

Key insight: **LLMs are already trained on Unix semantics**, so mapping everything to filesystem operations reduces prompt engineering overhead and increases reliability.

## Architecture

| Unix Kernel | Mirage Workspace |
|---|---|
| VFS mount table | MountRegistry |
| Page cache | File + index cache |
| Process table | Job table |
| Syscall dispatch | Command registry |
| Shell host | Session manager + executor |

The `Workspace` is the kernel — it owns mounts, cache, command registry, job tracking, and execution history. Multiple sessions share one Workspace.

Core abstractions:
- **Resource** — backend adapter (RAMResource, S3Resource, SlackResource, etc.). 34 resource types as of launch.
- **Accessor** — low-level backend access (minimal base class, per-resource implementations)
- **Mount** — prefix-based routing (`/s3` → S3Resource, `/slack` → SlackResource)
- **Command** — bash-like operations, overridable per resource+filetype (e.g., `cat` on a Parquet file renders JSON)
- **Session** — per-agent cwd, env, functions, exit code
- **Workspace.execute()** — parses shell, resolves mounts, dispatches, records history

## Distinctive Design Choices

1. **Full shell emulation**: Not just CRUD — they implement `awk`, `grep`, `diff`, `cut`, `csplit`, `comm`, `column`, `expand` etc. per mount type. This is a massive surface area commitment.

2. **Snapshot/restore**: `ws.snapshot("snap.tar")` → `Workspace.load("snap.tar")`. Enables speculative execution and agent forking. [[agent-session-resume]] addresses similar needs differently.

3. **Per-resource command override**: `ws.command('cat', { resource: 's3', filetype: 'parquet' }, ...)` — contextual behavior based on mount + filetype. Clever, but explosion of command variants to maintain.

4. **Cross-mount pipelines**: `grep alert /slack/general/*.json | wc -l` — piping across heterogeneous backends as naturally as local disk. This is the killer demo.

5. **Dual runtime**: TypeScript (Node + browser via OPFS) and Python with shared semantics. Browser SDK with WASM for client-side agent workspaces.

6. **Framework integrations**: OpenAI Agents SDK, Vercel AI, LangChain, Pydantic AI, CAMEL, OpenHands. Wide reach from day one.

## Relevance to Our Direction

### Positive Signals
- Validates the "reduce agent API surface" thesis — same direction as [[skill-distribution-convergence]] but at the data access layer
- The mount-per-service model is cleaner than "one MCP server per service" for data-heavy workflows
- Snapshot/restore could be useful for [[agent-session-resume]] patterns

### Why We Probably Don't Need It
- OpenClaw already has direct service integrations (message tool, exec, etc.) — we don't need a VFS abstraction layer
- Our agents don't do heavy cross-service data pipelines (cat S3 | grep | wc)
- The complexity of maintaining 34 resource types × N commands is enormous — signals VC-funded team, not sustainable for small projects
- Our bottleneck is **reasoning quality**, not **data access interface**

### Concept Worth Borrowing
- **Command override per context** — we could apply this pattern to skill dispatch (different skill behavior based on channel type)
- **filePrompt / mountInfo in system prompt** — automatically describing available data sources to the model is a good UX pattern

## Ecosystem Position

Competes with: MCP (many small servers) vs Mirage (one VFS that subsumes them all). Also somewhat adjacent to [[composio]] (tool aggregation) but at a lower abstraction level.

The bet is that **filesystem semantics > tool/function semantics** for LLM agents. Interesting thesis, unclear if it holds for non-data-processing use cases.

## Deep Read Findings (2026-05-07)

Followup scan: 360⭐ (+75 in <24h), still accelerating.

### Implementation Details

1. **tree-sitter bash parsing** — Commands are parsed into proper ASTs via `tree_sitter_bash`, not regex. This enables correct handling of pipes, compound commands (`&&`, `||`), subshells, and redirections. Much more robust than naive string splitting.

2. **Provision system (pre-execution cost estimation)** — Before executing, agents can call `provision()` to get estimated network I/O bounds (low/high range), cache hit counts, read ops, and even USD cost estimates. Three precision levels: EXACT, RANGE, UPPER_BOUND. This is a **safety layer for autonomous agents** — you can set budget caps and reject commands that would read too much data. Concept worth watching: [[agent-budget-control]].

3. **Barrier policy** — Three execution modes:
   - STREAM: lazy stdout, fire-and-forget
   - STATUS: drain stdout, sync exit code only
   - VALUE: fully materialize result
   This controls memory footprint for large outputs — agents can choose how much to buffer.

4. **Observer (session telemetry)** — JSONL logs persisted to any mounted resource at `/.sessions/`. Sessions become filesystem objects that agents can introspect (`cat /.sessions/agent-1/2026-05-07/log.jsonl`). Self-referential: the observation system uses the same VFS abstraction it monitors.

5. **Cross-mount safety** — Explicit `exit_code=1` + `"cross-mount not supported"` errors when a command can't aggregate across mounts. Safety > convenience — the system tells you when a pipeline can't span backends rather than silently producing wrong results.

6. **Session management** — `SessionManager` with per-agent cwd, env, functions, exit codes. Multiple agents can share one Workspace with isolated sessions. The `Workspace` is truly a kernel analog.

### Architecture Quality Assessment

- **Code quality**: High. Clean separation of concerns, proper typing, comprehensive tests (per-resource + cross-resource + shell parsing + integration).
- **Abstraction layer count**: Moderate — Resource → Mount → Registry → Workspace → Session → Execute. Not over-engineered for what it does.
- **Test coverage**: Good. Cross-provider dispatch tests verify mount boundary enforcement. Command spec tests verify flag parsing.
- **Maturity**: Alpha (v0.0.1). API will change. But the core abstractions feel solid.

### Ecosystem Comparison

| Approach | Surface | Strength | Weakness |
|---|---|---|---|
| Mirage | Filesystem + bash | LLM-native, composable pipes | Huge surface area to maintain |
| MCP | Tool/function calls | Simple, modular | N servers = N protocols |
| [[composio]] | Tool aggregation | Wide coverage | Opaque, hosted |
| OpenClaw | Native channel tools | Tight integration | Per-channel, not composable |

Mirage bets that **filesystem > function calling** for data-heavy agent tasks. This is probably right for ETL/analytics agents, probably wrong for conversational agents like us.

### Updated Relevance

The provision system is the most transferable idea. Before an agent executes a potentially expensive operation, estimate cost and get approval. We could apply this to:
- Subagent spawns (estimate token cost before spawning)
- External API calls (estimate rate limit impact)
- File operations (estimate disk usage)

The observer-as-VFS pattern (sessions visible at `/.sessions/`) is also elegant — agent introspection through the same interface as everything else.

## Tracking

- Created: 2026-05-06
- First scan: 2026-05-07 (285⭐, 16 forks in 24h)
- Deep read: 2026-05-07 (360⭐, tree-sitter parsing, provision system, barrier policy, observer)
- Revisit: 2026-05-21 (check if growth sustains past launch hype)
