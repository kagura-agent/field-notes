# Open Multi-Agent (OMA)

> open-multi-agent/open-multi-agent | 6,098⭐ (2026-05-12) | TypeScript | MIT
> "From a goal to a task DAG, automatically. TypeScript-native multi-agent orchestration with MCP and live tracing."
> Created: 2026-03-31 | Maintainer: JackChen-me

## Core Idea

Goal-driven coordinator pattern: you give `runTeam(team, goal)` a goal string, and a coordinator agent decomposes it into a task DAG, parallelizes independent tasks, and synthesizes the result. Three runtime deps, pure TypeScript.

Key differentiator vs LangGraph (graph-first) or Mastra (hand-wired): OMA is **goal-first** — the task graph is generated at runtime, not defined statically.

## Architecture

```
OpenMultiAgent (orchestrator)
  ├── Team (agent roster + shared memory + messaging)
  ├── TaskQueue (dependency-aware work queue)
  ├── Scheduler (round-robin | least-busy | capability-match | dependency-first)
  ├── AgentPool (concurrency-controlled execution)
  └── Agent (conversation + tool loop)
```

Three execution modes:
1. `runAgent()` — single agent, single prompt
2. `runTeam()` — auto-orchestrated (coordinator decomposes goal)
3. `runTasks()` — explicit pipeline (you define the DAG)

### Notable Components

- **LoopDetector**: Sliding-window detection of repeated tool-call signatures. Sort keys canonically for comparison. Fires after N consecutive identical signatures.
- **Scheduler**: 4 strategies. `capability-match` uses keyword extraction + overlap scoring. `dependency-first` does BFS to count transitively blocked dependents (criticality score).
- **SharedMemory**: Pluggable `MemoryStore` interface (default in-process KV, swap Redis/Postgres).
- **Built-in tools**: bash, file_read, file_write, file_edit, grep, glob, fs_walk, delegate_to_agent
- **MCP**: `connectMCPTools()` for stdio MCP servers

## Provider Support

10 built-in: Anthropic, OpenAI, Azure, Bedrock, Gemini, Grok, DeepSeek, MiniMax, Qiniu, Copilot.
Plus any OpenAI-compatible via baseURL (Ollama, vLLM, LM Studio, OpenRouter, Groq).

## Contribution Culture

**Very welcoming.** Maintainer JackChen-me reviews actively, merges external PRs regularly. Has `CLAUDE.md` in repo. Vitest for testing. CI must pass.

**Quality bar is HIGH for examples**: maintainer challenges proposals that collapse into single-prompt. Must demonstrate genuine multi-source reconciliation or real conflict resolution. "Each agent queries the same LLM's same training data with a narrower input" = rejected.

**Review style**: Direct, substantive. Points out architectural collapses. Asks for seeded conflicts in examples.

## Open Issues of Interest

- **#96** (P3): Per-call risk gating for built-in tools — `onToolCall` middleware hook. Well-scoped, from real production user feedback.
- **#25** (P1): OpenAI-compatible provider integrations — 5 remaining (Mistral, Zhipu, Qwen, Moonshot, Doubao). Zero-install verification.
- **#106** (P2): Vercel AI SDK adapter
- **#204** (P1): Codex integration paths for task-level execution — spike/research

## Relation to Our Direction

| Dimension | OMA | OpenClaw |
|-----------|-----|----------|
| Orchestration | Goal→DAG at runtime | Session-based, user-driven |
| Multi-agent | Coordinator pattern | Subagent spawning |
| Memory | Pluggable SharedMemory | File-based + memex |
| Evolution | None (static agents) | beliefs-candidates, DNA |
| MCP | Built-in integration | Plugin system |

OMA is complementary to what we do — different layer (framework vs runtime). Could be interesting as a study of coordinator patterns for multi-agent task decomposition. The dependency-first scheduler with criticality scoring is a clean algorithm.

## Contribution Opportunities

1. **Provider verification** (#25) — Low-risk, good first PR. Verify Qwen or Zhipu.
2. **Per-call risk gating** (#96) — More substantial. Aligned with security/safety work.
3. **Cookbook example** — Could propose an AI agent self-evolution example with multi-source reconciliation (different from single-prompt).

## Key Takeaways

1. **Goal-first vs graph-first** is a real design axis in multi-agent frameworks. OMA chose goal-first, which trades determinism for flexibility.
2. **LoopDetector** with canonical key sorting is a simple but effective anti-pattern for agent loops — applicable to our own work.
3. **Scheduler strategies** (especially dependency-first with BFS criticality) are worth studying for task prioritization.
4. **Maintainer's "collapse test"**: "Does this multi-agent design collapse to a single prompt?" is a great litmus test for whether multi-agent is justified.

## Links

- [[coding-agent-ecosystem]]
- [[multi-agent-distributed-systems]]
