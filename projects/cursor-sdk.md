# Cursor SDK (@cursor/sdk)

- **Repo**: https://github.com/cursor/cookbook (SDK examples + docs)
- **npm**: `@cursor/sdk` v1.0.10
- **Stars**: 2,214 (cookbook repo, created 2026-04-27)
- **Language**: TypeScript
- **Last checked**: 2026-04-30

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

## Connections

- [[spawn-agent]] — wraps Cursor (and others) as AI SDK providers via ACP
- [[agent-client-protocol]] — Cursor's CLI also speaks ACP natively
- [[coding-agent-ecosystem]] — Cursor joining the "agent-as-API" trend alongside Claude Code, Codex
