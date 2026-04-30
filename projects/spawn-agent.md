# spawn-agent (millionco/spawn-agent)

- **Repo**: https://github.com/millionco/spawn-agent
- **Stars**: 76 (created 2026-04-26)
- **Language**: TypeScript (monorepo: library + playground)
- **License**: MIT
- **Last checked**: 2026-04-30

## What it is

A Vercel AI SDK provider that wraps locally installed coding agents (Claude Code, Codex, Cursor, Copilot, Gemini CLI, OpenCode, Factory Droid, Pi) as `LanguageModelV3` instances. You call `streamText({ model: spawnAgent("claude"), prompt: "..." })` and it spawns the agent subprocess, communicates via [[agent-client-protocol|ACP]], and streams results through the AI SDK.

**Key proposition**: "Your coding agents are just models." Makes any ACP-speaking agent composable inside standard Vercel AI SDK pipelines.

## Architecture

```
AI SDK (streamText / generateText)
  └─ SpawnAgentLanguageModel (implements LanguageModelV3)
       └─ SpawnAgent (session manager, ACP client)
            └─ connect() → spawn child process
                 └─ AgentAdapter (per-agent resolver)
                      └─ ndJsonStream ↔ ACP protocol
```

### Three adapter types

1. **Native ACP** — Cursor (`agent acp`), Copilot, Gemini, OpenCode, Droid, Pi speak ACP natively. Adapter just resolves binary + passes `acp` arg.
2. **Shim-based** — Claude Code needs `@agentclientprotocol/claude-agent-acp` shim (separate npm package that wraps `claude` CLI).
3. **Shim-based** — Codex needs `@zed-industries/codex-acp`.

### Detection

`detect.ts` scans PATH for known binaries (`claude`, `codex`, `agent`, `gemini`, `opencode`, `droid`, `pi`). Synchronous `which`-style check. No configuration needed.

## Key design decisions

### 1. Agents as Language Models, not tools

The fundamental framing choice: coding agents implement `LanguageModelV3`, so they slot into any AI SDK pipeline where you'd use a model. This is different from treating agents as tools/functions. The tradeoff: agent tool calls (file edits, terminal) are reported as `providerExecuted: true` — the consumer sees them as side effects of generation, not as tool calls it needs to handle.

### 2. Stateful sessions

`createSpawnAgentSession()` keeps the underlying agent subprocess alive across multiple `streamText()` calls. Each call sends one `session/prompt` turn, preserving the agent's conversation memory. This maps directly to ACP's session model.

### 3. Permission delegation

`permission: "auto-allow"` bypasses agent permission prompts. Also supports custom permission handlers via `SpawnAgent.connect({ permission: myHandler })`.

## Relevance to OpenClaw

**Direct overlap with ACP runtime**: OpenClaw already has `sessions_spawn` with `runtime: "acp"` that does essentially the same thing — spawns agent subprocesses and communicates via ACP. spawn-agent packages this as an AI SDK provider, making it consumable by any Vercel AI SDK user.

**Differences from our approach**:
- spawn-agent is a library (npm import), OpenClaw ACP is a runtime (gateway-managed)
- spawn-agent targets individual developers composing agents; OpenClaw targets persistent agents orchestrating sub-agents
- spawn-agent has no session persistence across process restarts; OpenClaw has session resume

**What we can learn**:
- The `LanguageModelV3` framing is elegant — could we expose ACP agents as AI SDK providers?
- Their adapter registry pattern (per-agent resolver with install/auth checks) is clean
- The `providerExecuted: true` pattern for side-effect tool calls is worth studying for our own reporting

## Ecosystem position

Part of the emerging "agent-as-API" layer. Sits between:
- [[agent-client-protocol]] (transport protocol)
- [[vercel-ai|Vercel AI SDK]] (consumer framework)
- Individual coding agents (backends)

Competitors/related: [[cursor-sdk]] (first-party Cursor SDK), OpenClaw ACP (runtime-level orchestration), [[bux]] (24/7 agent + browser harness).

## Connections

- [[agent-client-protocol]] — ACP is the underlying protocol
- [[skill-ecosystem]] — spawn-agent doesn't do skills, but the agents it wraps do
- [[coding-agent-ecosystem]] — another entry in the "how to programmatically use coding agents" space
