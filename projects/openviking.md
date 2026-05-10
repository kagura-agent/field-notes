# OpenViking — Context Database for AI Agents

**Repo:** volcengine/OpenViking
**Stars:** 23,725 (2026-05-10)
**Language:** Python + Rust CLI
**License:** AGPL-3.0
**Backed by:** ByteDance (Volcengine)
**Created:** 2026-01-05

## What It Is

A context database that unifies Memory, Resource, and Skill management for AI agents using a filesystem paradigm. Not a vector DB — it's a structured context layer that sits between the agent and its knowledge.

## Core Architecture: L0/L1/L2 Tiered Context

| Layer | Name | Token Budget | Purpose |
|-------|------|-------------|---------|
| L0 | Abstract | ~100 tokens | Vector search, quick filtering |
| L1 | Overview | ~2k tokens | Rerank, content navigation |
| L2 | Detail | Unlimited | Full content, on-demand |

Each directory has `.abstract.md` (L0) and `.overview.md` (L1) auto-generated bottom-up by SemanticProcessor. L2 = original files.

**URI scheme:** `viking://resources/docs/auth/oauth.md`

### Key Components
- **SemanticProcessor** — traverses directories bottom-up, generates L0/L1
- **SessionCompressor** — compresses session history, extracts long-term memory
- **Retrieve** — intent-based search + rerank using L0→L1→L2 progressive loading
- **Parse** — document extraction into the L0/L1/L2 tree
- **pyagfs** — Python Agent File System (the filesystem abstraction layer)

## Convergence with Our Approach

Our independently-built system mirrors this exactly:
- AGENTS.md/SOUL.md = L0 (always loaded)
- wiki/L1.md = L1 (navigation index, ~30 lines)
- wiki cards/projects = L2 (loaded on demand)

**Key difference:** OpenViking auto-generates L0/L1 from content; we maintain ours manually. Their SemanticProcessor does bottom-up aggregation — child L0s roll into parent L1. We do this by hand when updating L1.md.

## Ecosystem Position

- **Direct OpenClaw integration** — has an official plugin (`openviking-memory-plugin`)
- **Competes with:** [[memos-memory-os]] (MemOS, 9k⭐), [[EverOS]] (4.6k⭐)
- **Relationship to OpenClaw:** upstream context provider, not a competitor
- **AGPL-3.0** = any modifications must be open-sourced (matters for commercial use)

## Issues Analysis (2026-05-10)

Most issues are plugin-related (OpenClaw integration bugs). Notable:
- Plugin capability mode `none` causing silent no-ops
- Namespace URI canonicalization bugs
- MCP tool behavior mismatch with docs
- No deep architectural critiques yet — project is still young enough that users hit surface bugs, not design limits

## What We Can Learn

1. **Auto-generation of context layers** — we should consider scripting L1.md regeneration from wiki content instead of manual updates
2. **URI scheme for context** — `viking://` provides a uniform address space; our `[[wikilinks]]` serve a similar but less formal role
3. **Bottom-up aggregation** — their SemanticProcessor pattern (leaf→parent) is a good model for keeping navigation indexes fresh
4. **Session compression** — automatic extraction of long-term memory from sessions; we do this manually in memory/YYYY-MM-DD.md

## Verdict

Major infrastructure play from ByteDance. The L0/L1/L2 convergence validates our manual approach but suggests we're leaving automation on the table. Worth monitoring as potential upstream tool, but AGPL license limits adoption flexibility.

Not a contribution target (enterprise-backed, AGPL, Python/Rust stack).

---
*First studied: 2026-05-10*
*Related: [[self-evolving-agent-landscape]], [[thin-harness-fat-skills]], [[memos-memory-os]]*
