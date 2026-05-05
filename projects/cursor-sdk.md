# Cursor SDK (@cursor/sdk)

- **Repo**: https://github.com/cursor/cookbook (SDK examples + docs)
- **npm**: `@cursor/sdk` v1.0.10
- **Stars**: 2,214 → 3,415 (cookbook repo, created 2026-04-27) — +54% in 5 days
- **Language**: TypeScript
- **Last checked**: 2026-05-05

## What it is

Cursor's first-party TypeScript SDK for programmatically creating and running Cursor agents. Not a CLI wrapper — a proper API client that talks to Cursor's backend (local or cloud).

## API surface

```ts
import { Agent, Cursor } from "@cursor/sdk"

// Create agent (local workspace or cloud GitHub repo)
const agent = await Agent.create({
  apiKey: process.env.CURSOR_API_KEY,
  name: "my agent",
  model: { id: "composer-2" },
  local: { cwd: process.cwd() },  // OR: cloud: { repos: [{ url, startingRef }] }
})

// Send prompt, stream events
const run = await agent.send(prompt)
for await (const event of run.stream()) { ... }
await run.wait()
```

### Event types

- `assistant` — text + tool_use blocks
- `thinking` — reasoning text
- `tool_call` — tool invocation with status (requested/running/done)
- `status` — agent state changes
- `task` — task progress

### Two execution modes

1. **Local** — agent operates on local filesystem via `cwd`
2. **Cloud** — agent clones GitHub repo into Cursor's cloud sandbox, operates there

### Model management

`Cursor.models.list()` returns available models with variants and parameters. Models have display names, descriptions, and parameter options.

### Run lifecycle

- `run.stream()` — async iterator of events
- `run.wait()` — await completion, returns `{ status, durationMs, usage }`
- `run.cancel()` — cancel with `run.supports("cancel")` check
- `agent[Symbol.asyncDispose]()` — cleanup

## Key design decisions

### 1. Cloud-native coding

Cloud mode is first-class, not an afterthought. The SDK auto-detects GitHub remote from cwd and can run agents on remote repos with specific branches. This positions Cursor for server-side CI/CD integration.

### 2. API key auth, not CLI auth

Unlike spawn-agent's binary detection approach, Cursor SDK uses API keys from their dashboard. This makes it cloud-friendly but adds a billing/auth dependency.

### 3. Agent = managed resource

Agents are created as server-side resources with lifecycle management (`Symbol.asyncDispose`). This is more like a cloud service than a local process.

## Significance

This is Cursor going from "IDE with AI" to "AI agent platform with API." The cloud execution mode means Cursor agents can run headlessly in CI/CD, batch jobs, or as backends for other applications. Combined with the AI SDK provider in [[spawn-agent]], Cursor agents are becoming fully programmable.

## Relevance to OpenClaw

- **ACP integration**: Cursor also has a native ACP interface (`agent acp` command). The SDK is a higher-level alternative for Cursor-specific workflows.
- **Cloud sandbox pattern**: Cursor's cloud execution mode (clone repo → run in sandbox) is something OpenClaw could eventually support for remote coding tasks.
- **Model routing**: Their `Cursor.models.list()` with variants is similar to our provider model catalog concept.

## Update 2026-05-05: DAG Task Runner

New addition: a **DAG task runner** skill + SDK example (PR #7, merged 05-01). Decomposes tasks into a JSON dependency graph, executes nodes as Cursor SDK subagents in topological rank order with `Promise.all` for same-rank parallelism.

### Architecture

```
JSON DAG → parseDAG() → computeRanks() → for each rank: Promise.all(runTask(...))
                                                ↓
                                          CanvasWriter → .canvas.tsx (hot-reloads in IDE)
```

- **dag.ts**: Schema validation + cycle detection (iterative DFS) + topological ranking via Kahn's algorithm
- **run_dag.ts** (~650 LOC): Core runner. Creates one `Agent` per task via Cursor SDK. Streams events, collects assistant text into a `BoundedTextBuffer` (capped). Stitches upstream task results into child prompts. Per-task timeout + stream idle timeout.
- **canvas_writer.ts**: Debounced (200ms default) TSX writer. Inlines state as `const STATE = {...}` into a React component. IDE hot-compiles → live DAG visualization.

### Key design decisions

1. **Complexity-based model routing**: Tasks tagged HIGH/MED/LOW → maps to different models (gpt-5.3-codex / composer-2 / auto-low). Overridable per-DAG or via `--models-file`.
2. **Upstream context stitching**: Parent task outputs are prepended to child prompts with "do not re-do this work" framing. Truncated at cap.
3. **Fail-fast with skip propagation**: If a parent task fails, all downstream tasks are immediately skipped (not attempted). Clean error messages.
4. **Canvas = observable state**: The `.canvas.tsx` file IS the monitoring UI. No separate dashboard — the IDE is the dashboard. Clever for Cursor's IDE-first model.
5. **Defensive shutdown**: SIGINT/SIGTERM → finalize canvas → exit. Uncaught exceptions caught, unhandled rejections suppressed with logging.

### Comparison with FlowForge

| Aspect | Cursor DAG Runner | FlowForge |
|---|---|---|
| Execution model | Parallel (topological ranks) | Sequential (node-by-node) |
| Agent coupling | Cursor SDK only | Agent-agnostic (human-in-loop) |
| Visualization | IDE canvas (hot-reload TSX) | CLI status output |
| DAG definition | JSON (tasks + depends_on) | YAML (nodes + branches) |
| Human control | Fire-and-forget | Interactive (flowforge next) |

FlowForge's strength is human-in-the-loop steering and agent-agnosticism. Cursor's DAG runner is purpose-built for automated fan-out within their SDK. Not competitors — different design philosophies.

### Also new: Agent Kanban Board

A Next.js web app (`sdk/agent-kanban/`) for viewing Cursor Cloud Agents grouped by status/repo, previewing artifacts, and creating new cloud agents. Introspection scripts (`introspect-agent-list.mjs`, `introspect-agent-details.mjs`) pull data from Cursor's API.

Signal: Cursor is building management tooling around their agent API — moving from "run one agent" to "manage a fleet."

### Relevance to OpenClaw

- **DAG execution pattern**: We could add parallel node execution to FlowForge (ranks within a step). Currently all sequential.
- **Canvas-as-monitoring**: Interesting for IDE-integrated agents. Not applicable to our Discord/Feishu channels, but the "state-as-file" pattern is worth noting.
- **Model routing by complexity**: Similar to our provider selection but more explicit. Could inform [[skill-ecosystems]] metadata.

## Connections

- [[spawn-agent]] — wraps Cursor (and others) as AI SDK providers via ACP
- [[agent-client-protocol]] — Cursor's CLI also speaks ACP natively
- [[coding-agent-ecosystem]] — Cursor joining the "agent-as-API" trend alongside Claude Code, Codex
- [[flowforge]] — our workflow engine, sequential vs Cursor's parallel DAG
- [[addyosmani-agent-skills]] — process-over-prose philosophy, both treating skills as structured specs
