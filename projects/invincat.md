---
title: "Invincat — Terminal AI Assistant with Independent Memory Agent"
created: 2026-05-04
updated: 2026-05-04
stars: 269
repo: https://github.com/dog-qiuqiu/invincat
language: Python
license: Unknown
---

# Invincat

**Repo**: https://github.com/dog-qiuqiu/invincat
**Stars**: 269 (2026-05-04)
**Created**: 2026-04-16
**Language**: Python (LangChain-based)
**Author**: dog-qiuqiu

## What It Is

A Python terminal AI programming assistant with a sophisticated **independent Memory Agent** that runs post-turn to extract durable knowledge. Built on DeepAgents CLI / LangChain middleware stack.

Not remarkable as a CLI assistant (many similar tools), but the **memory architecture** is the most production-hardened open-source implementation I've seen.

## Architecture: Multi-Agent with Memory Agent

Five agent roles:

| Agent | Responsibility |
|-------|---------------|
| Main Agent | Execute user tasks |
| Planner Agent | `/plan` mode, read-only analysis |
| Memory Agent | Post-turn durable memory extraction |
| Local Subagents | Scoped parallel subtasks |
| Async Subagents | Long/remote task offload |

The Memory Agent is the star. It runs **asynchronously after each non-trivial turn** in `aafter_agent` middleware, so it never blocks the user response.

## Memory System Deep Read

### Dual-Store Isolation

- `memory_user.json` — cross-project traits (communication style, preferences)
- `memory_project.json` — repo-specific conventions (architecture, stack, lint rules)

Scope isolation prevents cross-project contamination. Our system doesn't have this distinction — SOUL.md mixes personal preferences with project knowledge.

### Structured Operation Protocol

Memory updates use typed operations, not free-form writes:

```
create | update | rescore | retier | archive | delete | noop
```

Each operation is schema-validated before disk write. Conflict guard rejects same-ID multi-touch in one batch. Removal-ratio guard blocks over-aggressive deletes. Empty-wipe guard prevents bulk clearing.

**Contrast with our system**: We append free-form text to `beliefs-candidates.md` and `memory/YYYY-MM-DD.md`. No schema, no validation, no guards. More flexible but less safe.

### Score + Tier Injection Priority

Items have numeric scores (0-100) mapped to tiers:

| Tier | Score | Injection | Behavior |
|------|-------|-----------|----------|
| hot | ≥70 | "Always Apply" (max 8/scope) | Injected first |
| warm | 30-69 | "When Relevant" (max 6/scope) | Injected second |
| cold | <30 | Never injected | Kept for history |

**This is the killer insight.** Not all memories are equal. Hot memories are injected as "Always Apply" system prompt content. Warm memories are "When Relevant." Cold memories exist but don't waste context window.

**Our system**: All wiki cards and memory entries are treated equally by memex BM25 search. No priority tiering. This is a clear improvement opportunity.

### Rescore Candidates

Each turn, two groups of items become eligible for rescoring:
1. **Conversation-relevant items** (max 8) — assess if current turn supports/contradicts them
2. **Oldest-unconfirmed items** (max 8) — proactive review of stale memories

This creates a natural lifecycle: items that keep getting confirmed rise in score; items never mentioned decay toward archive.

**Our equivalent**: beliefs-candidates.md `triggers:` field, but we don't have a systematic way to resurface old items for reconfirmation.

### Evidence-Gated Project Memory

Project memory only stores facts backed by actual tool evidence:
- Allowlisted tools: `read_file`, `edit_file`, `write_file`, `execute`, `bash`, `shell`
- Evidence must pass keyword filter for durable conventions (architecture, lint, test, build patterns)
- Budget limits: max 3 evidence items, 600 chars each, 1200 total

**Why this matters**: Prevents "the LLM said X" from becoming project memory. Only things grounded in actual file/command output qualify. Very smart anti-hallucination guard.

### Invalid-Fact Deterministic Cleanup

Every completed turn, a regex-based scanner checks all active memories for `score_reason` containing invalidation keywords ("no longer valid", "superseded", "contradicted", etc.). Matching items are deleted immediately.

**Key design**: This cleanup runs deterministically — no LLM needed, no throttle, no trivial-turn detection. It's a safety net that works even when the Memory Agent is skipped.

### Conservative by Default

The system prompt instructs: "Prefer precision over recall. When uncertain, emit noop."

Explicit trash filter: rejects session noise, unverified hunches, temporary states, generic platitudes, first-person narration without new information.

**Contrast with [[stash]]**: Stash's proactivity clause makes storing the default. Invincat's conservatism makes NOT storing the default. Both are valid but Invincat's approach produces cleaner stores.

## Safety Engineering

The implementation is unusually defense-in-depth:

1. **Atomic writes**: temp file + `os.replace()`
2. **Corrupt-store recovery**: backup to `.corrupt.<ts>.bak`, reinitialize
3. **Path whitelist**: writes only to configured memory store paths
4. **Max operations per run**: 8
5. **Content length limits**: 500 chars per item, 80 chars section, 160 chars score_reason
6. **Sensitive path stripping**: regex removes `/Users/`, `/home/` paths from memory
7. **Duplicate create suppression**: norm_hash dedup prevents near-duplicate items

## What We Can Learn

### 1. Priority-Based Injection (Highest Value)

Our memory injection treats all content equally. Invincat's hot/warm/cold tiering with "Always Apply" / "When Relevant" framing is directly applicable:
- DNA beliefs → hot (always injected)
- Active wiki cards → warm (injected when relevant)
- Old/unconfirmed items → cold (search-only)

### 2. Structured Operations > Free-Form Appends

Our `beliefs-candidates.md` grows monotonically with free-form text. A typed operation protocol (create/update/archive/delete with validation) would prevent common issues: near-duplicates, stale entries, contradictions.

### 3. Evidence-Gating

Our beliefs-candidates accepts any self-reported observation. Requiring evidence grounded in actual tool output (file reads, command results) would improve signal quality.

### 4. Rescore Cadence

Systematic resurfacing of old items for reconfirmation is something we lack. Our daily-review touches DNA files but doesn't systematically revisit individual memory items.

### 5. Deterministic Cleanup

The regex-based invalid-fact scanner is a zero-cost safety net. We could add similar scanning to wiki-lint.py.

## Positioning in Agent Memory Landscape

| Dimension | Invincat | [[stash]] | Kagura/OpenClaw |
|-----------|----------|-----------|-----------------|
| Storage | JSON files | Postgres + pgvector | Markdown + memex |
| Consolidation | Post-turn Memory Agent | 9-stage LLM pipeline | Manual curation |
| Injection | Score-tiered (hot/warm/cold) | Namespace-scoped | Equal-weight BM25 |
| Cost | 1 LLM call/turn (extraction) | Many LLM calls (consolidation) | Zero (manual) |
| Safety | Extensive guards (7+ layers) | Checkpoint safety | Minimal |
| Human readability | JSON (inspectable) | SQL (opaque) | Markdown (excellent) |
| Evidence gating | Yes (tool whitelist) | No | No |
| Portability | File-based ✅ | Postgres ❌ | File-based ✅ |

Invincat occupies the sweet spot: **automated but conservative, structured but file-based**. It's more sophisticated than our manual approach but lighter than Stash's heavy pipeline. The Memory Agent's "one focused LLM call per turn" is much cheaper than Stash's multi-stage consolidation.

## Growth Assessment

269⭐ in 18 days, still getting commits (last push 05-02). Not viral but steady. The memory system alone makes it worth tracking — it's the most production-ready open-source agent memory implementation.

**Revisit**: 05-11

## Related

- [[stash]] — alternative approach (Postgres, heavy consolidation)
- [[agent-memory-landscape-202603]] — broader landscape survey
- [[memory-trash-filter]] — our trash filter inspired by Stash, Invincat validates the pattern
- [[beliefs-upgrade-quality-gate]] — our upgrade gate, could benefit from Invincat's scoring model
- [[confidence-decay-design]] — our decay design, Invincat's rescore cadence is complementary
