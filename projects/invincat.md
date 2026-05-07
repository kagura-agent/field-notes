---
title: "Invincat — Terminal AI Assistant with Independent Memory Agent"
created: 2026-05-04
updated: 2026-05-06
stars: 292
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

## 05-06 Followup: Major Simplification Refactor

**Stars**: 292 (+23 in 2 days)
**Key commit**: `33165994` — "Simplify memory agent operations" (-311/+126 lines in memory_agent.py)

### What Changed

1. **Removed rescore_candidates system entirely** — previously had 2-group rescoring (conversation-relevant + oldest-unconfirmed, 8 each). Now items in the snapshot have no `rescore_candidates` field. This suggests the proactive rescoring was over-engineered or not paying off.

2. **Removed MAX_OPERATIONS_PER_RUN (was 8)** — operations are now uncapped. Indicates the limit was causing truncated memory updates.

3. **Simplified field naming** — `score_reason` → `reason` throughout. Cleaner API surface.

4. **Changed conversation passing architecture** — instead of passing raw multi-turn messages (human/ai/tool roles) to the Memory Agent LLM, now formats everything as a plain-text transcript in a single HumanMessage. Added explicit instruction: "It is context only; do not continue it." This is likely a fix for models that tried to continue the conversation instead of extracting memory.

5. **Removed conversation from memory snapshot** — `_build_memory_snapshot()` no longer includes conversation text. Snapshot is now purely the existing memory state.

6. **Added anti-tool-call guard** — System prompt now says: "You have no tools. Never emit tool calls, DSML tags, XML-like invocation markup, or requests to read files." Indicates they hit issues with models hallucinating tool calls during memory extraction.

7. **Removed resolution signal regex** — previously detected "fixed/resolved/no longer reproducible" patterns deterministically. Removed, possibly because the LLM-based scoring handles this better.

### Implications for Us

- **Rescore pipeline complexity not worth it**: Invincat tried systematic rescoring with candidate selection and backed off. This validates our simpler approach of letting daily-review handle reconfirmation rather than per-turn rescoring.
- **Plain-text transcript > multi-turn messages**: For background agents that process conversation but don't participate, flattening to text is more robust. Models stay in "analyze" mode rather than "chat" mode.
- **Anti-hallucination guards are necessary**: Even structured JSON-only output prompts need explicit "you have no tools" instructions. Relevant for any memory extraction system we build.

## Growth Assessment

292⭐ in 20 days, steady commits (5 commits on 05-05 alone). Not viral but healthy. The simplification refactor shows maturity — they're cutting complexity that didn't pay off rather than adding features.

**Revisit**: 05-11

## 05-07 Followup: Prompt Compression & Decision Order

**Stars**: 304 (+12 in 1 day)
**Key commits**: "Simplify memory agent prompt" + "Encourage memory rescore on confirmation"

### Prompt Compression (-60% tokens)

The system prompt went from 268 to 116 lines — a massive compression with no semantic loss. Techniques:

1. **Removed ASCII section dividers** — `====` headers replaced with plain headings or removed entirely
2. **Merged 4 sections → 2** — SCOPE + WHAT TO STORE + OPERATION RULES + examples consolidated into STORE ONLY + OP RULES
3. **Examples cut from 11 to 5** — removed obvious cases (noop, retier, code review), kept only patterns where models make mistakes (contradicted item, confirmed item, noop on weak signal)
4. **Inline op schemas** — verbose multi-line op definitions condensed to single-line JSON

### New "DECISION ORDER" Section (Most Interesting)

This is the biggest architectural addition despite the overall compression:

```
1. First compare this turn with existing memory_snapshot items.
2. For each directly related item, classify as confirmed/refined/contradicted/resolved/stale/unrelated.
3. Prefer existing-item ops before create.
4. Emit noop only after checking confirmations, contradictions, and new durable facts.
```

**Why this matters**: Previous prompt told the model *what* each operation does. The new prompt tells it *when to think about each operation* — a prescribed evaluation sequence. This is the prompt engineering equivalent of [[mechanism-vs-evolution]]: structure the thinking process, not just the output format.

The "prefer existing-item ops before create" instruction directly addresses the most common failure mode: creating near-duplicate items instead of updating existing ones. Combined with explicit "never create semantic duplicates" (also new), this is a two-layer defense against store bloat.

### Rescore on Confirmation (Prompt-Based)

After removing the code-based rescore_candidates pipeline (05-05), they added prompt-level instructions:
- "Do not treat confirmation as noise" — warm/cold items confirmed by conversation should get rescored up
- "Prefer rescore over noop" for directly confirmed items
- Exception: don't rescore already-hot items for routine mentions
- Added example H2 showing a project item confirmed without content changes

This is the **mechanism → prompt** pattern: replacing a code pipeline (select candidates → feed to LLM → process results) with prompt instructions that achieve the same effect within the existing extraction call. Fewer moving parts, same outcome.

### Trend: Three Rounds of Simplification

| Date | Change | Net Lines |
|------|--------|-----------|
| 05-05 | Remove rescore pipeline, uncap operations, plain-text transcript | -185 |
| 05-06 | Rescore-on-confirmation prompt, reduce debug logs | +11 |
| 05-07 | Prompt compression, decision order | -152 |
| **Total** | | **-326** |

Invincat has removed ~330 lines of memory agent code in 3 days while *improving* behavior (better dedup, better confirmation handling). This is the [[memory-complexity-pendulum]] in action — they've crossed the complexity peak and are now on the simplification downslope.

### Lessons for Us

1. **Decision order > operation catalog**: When building memory extraction prompts, prescribe the evaluation sequence, not just the output schema. "First check existing items, then classify, then decide" is more effective than "here are 7 op types, pick the right one."
2. **Prompt compression is free performance**: 60% fewer tokens with no behavioral regression (all tests pass). We should audit our own system prompts for similar bloat — AGENTS.md is 200+ lines.
3. **Mechanism → prompt works for background agents**: When a background agent runs once per turn with full context, code-level pipelines add complexity without adding capability. The prompt *is* the pipeline.

## Related

- [[stash]] — alternative approach (Postgres, heavy consolidation)
- [[agent-memory-landscape-202603]] — broader landscape survey
- [[memory-trash-filter]] — our trash filter inspired by Stash, Invincat validates the pattern
- [[beliefs-upgrade-quality-gate]] — our upgrade gate, could benefit from Invincat's scoring model
- [[confidence-decay-design]] — our decay design, Invincat's rescore cadence is complementary
