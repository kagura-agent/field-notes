# MemOS — Memory Operating System for LLM & AI Agents

**Repo:** MemTensor/MemOS
**Stars:** 9,007 (2026-05-10)
**Language:** TypeScript
**License:** Apache-2.0
**Created:** 2025-07-06

## What It Is

Memory OS that unifies store/retrieve/manage for long-term agent memory. Claims +43.7% accuracy vs OpenAI Memory and 35.24% token savings. Has both cloud and self-hosted modes.

## Architecture

- **Unified Memory API** — single API for CRUD on memory (graph-structured, not black-box embeddings)
- **Multi-Modal** — text, images, tool traces, personas
- **Multi-Cube KB** — composable memory cubes for isolation/sharing across agents
- **MemScheduler** — async ingestion with millisecond latency
- **Tiered memory:** L1 trace → L2 policy → L3 world model → crystallized Skills

## OpenClaw Integration

- **memos-local-plugin 2.0** — official OpenClaw + Hermes Agent plugin
- Local-first with SQLite, hybrid search (FTS5 + vector)
- Cloud plugin claims 72% token reduction + multi-agent memory sharing

## vs OpenViking

| Aspect | MemOS | [[openviking]] |
|--------|-------|------------|
| Stars | 9k | 23.7k |
| Language | TypeScript | Python + Rust |
| License | Apache-2.0 | AGPL-3.0 |
| Approach | Graph-structured memory | Filesystem paradigm |
| Tiering | L1-L3 + Skills | L0/L1/L2 context layers |
| OpenClaw plugin | Yes (local + cloud) | Yes |
| Backing | MemTensor (startup?) | ByteDance |

## Relevance to Us

- TypeScript = closer to our stack (OpenClaw is Node-based)
- Apache-2.0 = more permissive for adoption
- The L1→L2→L3→Skills evolution pipeline is conceptually similar to our beliefs-candidates → DNA graduation flow

## Verdict

Serious memory infrastructure with direct ecosystem integration. Apache-2.0 makes it more adoption-friendly than OpenViking. The tiered memory evolution (trace→policy→world model→skill) is a pattern worth studying deeper.

---
*First studied: 2026-05-10*
*Related: [[openviking]], [[self-evolving-agent-landscape]], [[hermes-memory-skills]]*
