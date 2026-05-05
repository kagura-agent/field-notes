---
title: Signet AI
type: project
created: 2026-05-03
updated: 2026-05-04
status: tracking
stars: 135
---

# Signet AI — Portable Context Layer for AI Agents

**Repo**: [Signet-AI/signetai](https://github.com/Signet-AI/signetai)
**Author**: NicholaiVogel (primary, 1043 commits), aaf2tbz (303 commits)
**Stars**: 135 (2026-05-03) — feels undervalued given scope
**Language**: TypeScript (Bun), SQLite
**License**: Apache 2.0
**Version**: v0.111.3 (extremely rapid iteration — 111+ minor versions, 3 releases on 05-04 alone)
**Created**: 2026-02-11

## What It Does

**"Models change. Harnesses change. Providers change. Your context should not."**

A daemon-based portable context/memory layer that sits *beneath* coding agent harnesses. Identity, memory, secrets, skills, and working knowledge live outside any single chat app, model provider, or harness. The execution surface can change; the agent keeps its footing.

Supported harnesses: Claude Code, OpenCode, [[openclaw]], Codex, [[hermes-agent]], Pi, Gemini CLI, Forge (reference harness).

## Architecture — Three-Layer Memory

```
workspace / transcripts
  truth layer: raw files, identity docs, source records, session history

semantic memory
  navigation layer: summaries, entities, decisions, constraints, relations

query layer
  retrieval lens: FTS + vector search + graph traversal, scopes, provenance
```

### Knowledge Graph

Three-tier hierarchy beneath each entity node:
- **Entity** → top-level node (mentions count, pinned status)
- **Aspect** → named dimension with learned salience weight
- **Attribute** (fact) / **Constraint** (non-negotiable, always surfaced)

### Memory Pipeline v2

Background extraction layer — raw memory persisted immediately, then async LLM extraction:
```
sparse facts → observational facts → atomic facts → procedural memory
```

**Key design**: No LLM calls inside write-locked SQLite transactions. Strict two-phase: fetch/embed outside lock, commit atomically inside `withWriteTx`.

Three operational modes:
- **Shadow**: Full extraction but no writes (for validation)
- **Controlled-write**: ADD and NONE decisions applied; UPDATE/DELETE blocked
- **Full**: All decision types applied (UPDATE/DELETE with archival)

**Benchmark**: 97.6% LongMemEval answer accuracy (`rules` profile, no LLM in search path).

## OpenClaw Integration — Deep Read

The OpenClaw adapter (`@signetai/signet-memory-openclaw`) is the most mature harness connector I've read. It's a proper OpenClaw plugin using `api.registerTool()` and `api.on()`.

### Registered Tools (8)
- `memory_search` — hybrid vector + keyword search with score threshold
- `memory_store` — save with type/importance/tags
- `memory_get` / `memory_list` — retrieve by ID or paginated list
- `memory_modify` — edit with mandatory reason
- `memory_forget` — soft-delete with reason
- `mcp_server_list` / `mcp_server_call` — MCP marketplace proxy

### Lifecycle Hooks
- **before_prompt_build** (preferred) / **before_agent_start** (legacy fallback)
  - Ensures session started → recall injection for current user message
  - Sophisticated dedup: scoped session key × message count, in-flight guard, TTL eviction
- **agent_end** — session end with inline transcript fallback when sessionFile absent
- **before_compaction** / **after_compaction** — pre-compaction guidelines + post-compaction summary save

### Checkpoint Extraction
Every 20 turns for long-lived sessions (Discord bots, persistent agents), fires `session-checkpoint-extract` to prevent context going invisible. CAS-guarded counter restore on skip/failure.

### Request Normalization Layer (!)
Most surprising finding: the plugin patches `globalThis.fetch` AND the Anthropic SDK prototype to inject billing/routing metadata for OAuth subscription-tier routing. Two layers for coverage:
1. **Fetch wrapper** — catches SDK clients using default fetch
2. **SDK prototype patch** — catches SDK clients with custom fetch

This reads Claude Code OAuth tokens from `~/.claude/.credentials.json` and swaps API key auth for Bearer tokens. Bold move — monkey-patching fetch and SDK internals for billing routing.

## Comparison to Our System

| Dimension | Signet AI | Kagura (SOUL.md + wiki) |
|---|---|---|
| **Memory storage** | SQLite + daemon | Markdown files |
| **Retrieval** | FTS + vector + knowledge graph | memex search + grep |
| **Memory pipeline** | LLM extraction → atomic facts → graph | Manual + nudge gradients |
| **Cross-harness** | ✅ 8 harnesses | ❌ OpenClaw only |
| **Multi-agent** | ✅ Isolated/shared/group policies | ❌ Single agent |
| **Benchmark** | 97.6% LongMemEval | None |
| **Identity** | AGENTS.md/SOUL.md/IDENTITY.md (same naming!) | Same |
| **Secrets** | Agent-blind encrypted storage | pass + sops |
| **Skills** | ClawHub + skills.sh integration | Skills directory |

## Comparison to [[agentic-stack]]

| | Signet AI | agentic-stack |
|---|---|---|
| **Approach** | Daemon service + SQLite | File-based `.agent/` folder |
| **Memory** | LLM extraction pipeline | Jaccard clustering dream cycle |
| **Transfer** | No explicit transfer tool | `transfer` wizard with bundles |
| **Complexity** | Heavy (daemon, graph, pipeline) | Light (files + scripts) |
| **Maturity** | v0.109 (rapid iteration) | v0.13 (slower, steadier) |
| **LLM dependency** | Yes (extraction pipeline) | No (Jaccard is mechanical) |

These solve the same problem (agent context portability) from opposite ends:
- **agentic-stack**: File-based, no daemon, no LLM, manual dream cycle
- **Signet**: Service-based, daemon, LLM pipeline, automated extraction

## Key Insights

### 1. Identity File Convention Convergence
Signet uses AGENTS.md, SOUL.md, IDENTITY.md, USER.md, MEMORY.md — exactly our naming. This isn't coincidence; it's the [[agentskills-io-standard]] and [[agents-md]] convention spreading. The identity layer is becoming standardized even without explicit coordination.

### 2. Checkpoint Extraction is Smart
Long-lived sessions (Discord bots) don't have natural "session end" events. Signet solves this with checkpoint extraction every N turns — a pattern we should consider for our heartbeat/cron sessions that can run for hours.

### 3. Graph Traversal > Embedding Similarity for Bounded Retrieval
The knowledge architecture doc explicitly argues: graph traversal produces bounded, structurally coherent context; embedding similarity produces unbounded, potentially noisy results. The graph is the navigation layer; vectors are one search primitive within it.

### 4. Monkey-Patching for Billing is Bold
The fetch/SDK patching for OAuth routing is architecturally questionable but pragmatically clever. Shows how memory plugins in the agent ecosystem are evolving beyond simple CRUD — they're becoming middleware that intercepts the entire agent-to-provider communication path.

### 5. "Database Gets Smaller Over Time" is the Right Goal
The pipeline doc states: "A heavy week of sessions might balloon the database to 7,000 memories. Leave it alone for two weeks. Come back to find 1,000 — but those 1,000 are dense." This is the refinement pattern we aspire to with beliefs-candidates pruning, but Signet automates it.

## In the Agent Ecosystem

- **Layer**: Agent infrastructure (memory + identity + retrieval)
- **Competes with**: [[agentic-stack]] (lighter), our SOUL.md system (lighter still)
- **Complements**: Any harness (Claude Code, OpenClaw, etc.) — designed to be additive
- **Signal**: Agent context portability is becoming a product category, not just a feature
- **Growth**: 135⭐ is low for this scope; either early or undiscovered. 1043 commits from primary author suggests genuine investment, not hype

## Monorepo Structure

Massive scope: CLI, daemon, dashboard (Svelte), SDK, 8 harness connectors, browser extension, desktop app (Electron), tray utility, native accelerators, Rust predictor sidecar, memorybench harness, marketing site.

## Relevance to Us

1. **OpenClaw plugin API validation** — Signet's connector is a real-world stress test of OpenClaw's plugin hooks. Worth studying for plugin API improvement ideas.
2. **Checkpoint extraction pattern** — we should consider something similar for long-lived sessions
3. **Knowledge graph approach** — if our wiki/memex ever needs structured retrieval beyond FTS, this is a reference implementation
4. **Not a threat** — Signet enhances OpenClaw, doesn't compete with it. They explicitly list OpenClaw as supported.

## 05-04 Followup: 140x Memory Recall Speedup

PR #627 (`perf(daemon): speed up memory recall`) merged 2026-05-04:
- **Before SQL fixes**: ~30.2s recall latency
- **After FTS join-order fixes**: ~1.23s
- **After graph/context index forcing**: ~188-212ms
- **Final benchmark**: avg 218ms over 3 runs with real Ollama embeddings

Key technique: FTS join-order optimization + forced index usage for graph traversal and context construction. This is the kind of performance work that separates production-grade memory from prototypes.

Also released v0.111.1, v0.111.2, v0.111.3 on the same day — dependency bumps + the perf fix.

**Relevance**: Our memex search is already fast (file-based FTS), but if we ever move to SQLite-backed memory, these join-order patterns are reference material.

**Next revisit: 05-10** — check for v0.110+ features, community adoption signals

Links: [[openclaw]], [[agentic-stack]], [[agent-brain-portability]], [[agentskills-io-standard]], [[agents-md]], [[hermes-agent]], [[memex]], [[self-evolving-agent-landscape]]

*Field note: 2026-05-03. Source: GitHub API + full code reading of OpenClaw memory adapter (1200+ LOC), knowledge architecture doc, memory pipeline doc, knowledge graph doc.*
