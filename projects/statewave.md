---
title: "Statewave"
url: https://github.com/smaramwbc/statewave
stars: 214
first_seen: 2026-05-11
status: active
last_verified: 2026-05-13
depth: deep-read
---

# Statewave

Open-source **memory runtime** for AI agents. Python + Postgres (pgvector). AGPL-3.0 + commercial dual license. v0.7.2 (May 2026), daily commits.

## What It Does

Three-stage memory pipeline: **Ingest → Compile → Retrieve**.

1. **Episodes** (raw events) — append-only, immutable. Chat messages, webhook events, connector imports.
2. **Memories** (compiled) — typed, scored, with provenance back to source episodes. Three kinds: `profile_fact`, `procedure`, `episode_summary`.
3. **Context bundles** (retrieval) — ranked, token-bounded assemblies ready for prompts. Deterministic scoring: kind priority + recency + semantic similarity + temporal validity + session awareness.

## Architecture Insights

### Compiler Duality
Two compiler modes: **heuristic** (regex patterns, zero deps, local-only) and **LLM** (LiteLLM, any provider). Heuristic is default — good enough for demos and testing, but the LLM path extracts richer memories. Smart design: same interface, swap at deploy time.

**Comparison to our system**: We do "compilation" manually — raw daily logs (`memory/YYYY-MM-DD.md`) → curated `MEMORY.md`. Statewave automates this with structured types and confidence scores.

### Ranked Retrieval with Multi-Signal Scoring
Context assembly uses ~15 scoring signals combined additively:
- Kind priority (profile_fact: 10, procedure: 8, episode_summary: 5)
- Recency (0-5 linear)
- Semantic similarity via pgvector (0-8, highest weight)
- Temporal validity bonus/penalty (+3/-4)
- Session boost (+6 for active session)
- Lexical overlap bonus (0-4, tiebreaker for narrow queries)
- Support-specific: urgency keywords, open issues, repeat-issue detection

**Key insight**: They hit a real bug where semantic scores were too close together and kind priority dominated, producing wrong results. Fixed by adding lexical overlap as tiebreaker. This is the kind of production learning that README architectures never surface.

### Conflict Resolution
Word-overlap similarity (threshold 0.6) within same (subject, kind) group. Newer supersedes older. Simple but effective — no fancy dedup, just pairwise comparison within groups. Superseded memories keep `valid_to` timestamp for audit trail.

### Per-Kind Memory TTL (v0.7)
Different memory types decay at different rates. Episode summaries expire faster than profile facts. Configurable per deployment.

**Connection to [[beliefs-upgrade-quality-gate]]**: Our "Durability" dimension in beliefs evaluation is the manual version of this — we ask "will this still be true in 30 days?" while Statewave encodes it as a TTL value per kind.

### Bi-Temporal Anchoring (v0.7.2, PR #71)
Four-commit fix that lifted benchmark scores from 0.388 → 0.535 (beating Mem0 0.382, Zep 0.244). Key lessons:

1. **valid_from from payload event time** — `episode_valid_from(ep)` helper prefers `payload.event_time` → `payload.messages[0].timestamp` → `ep.created_at` → `now()`. Previously every memory carried `valid_from = POST time`, making temporal queries useless. Parses ISO 8601 + natural language ("1:56 pm on 8 May").

2. **Date grounding in compiled content** — LLM compiler prompt gained "Temporal grounding" section: resolve relative phrases ("yesterday", "last Saturday") against message timestamp. `_render_memory_line` prefixes `[YYYY-MM-DD]` as safety net.

3. **Granular detail extraction** — Previous "concrete, generalizable facts" wording caused LLM to emit summaries and skip specifics. New rules: specific attributes ARE generalizable facts. Preserve colors, brands, quantities, names, places, preferences. "Better to emit 30 concrete granular memories than 5 vague ones — the retrieval layer ranks them; the compiler's job is recall." Compiled count: 111 → 154 (+39%).

4. **Embedding backfill on async path** — **The headline bug**: async compile route (default SDK mode) was missing one-line `schedule_embedding_backfill` call. Every async-compiled memory had `embedding=NULL`. Semantic search returned empty, silently falling back to lexical+temporal only. **Statewave's signature feature was effectively disabled.**

**Lesson for us**: The granularity insight is directly applicable. Our MEMORY.md curation tends toward summaries ("worked on X") instead of specifics ("discovered that Y uses Z pattern for W reason"). The embedding bug pattern is also cautionary — a missing one-liner silently degraded the most important feature.

### Sensitivity Labels & Memory Governance (Issue #50)
Design-stage feature: per-memory sensitivity metadata + policy layer controlling which memories influence which tools/contexts. Six candidate abstractions: capability tags, trust tiers, namespace policy, OPA/Rego, per-tool access rules, human approval workflows. Key insight: the accountability story (receipts from #49) is only as strong as the policy layer underneath — no filter metadata = nothing to record.

## What's Interesting for Us

1. **Episode → Compile → Retrieve pipeline** — structured version of our raw logs → MEMORY.md → session startup. Could we add confidence scores to our memory entries?
2. **Provenance chain** — every memory traces to source episodes. We don't have this. When something in MEMORY.md is wrong, we can't trace where it came from.
3. **Token budgets on context** — they enforce a hard token limit on context bundles. We just load everything and hope it fits.
4. **Conflict resolution** — automatic superseding of outdated facts. We do this manually during MEMORY.md curation.

## Limitations

- **Support-agent focused** — the scoring signals (SLA, handoff packs, health scores) are tuned for customer support. General-purpose agent memory would need different signals.
- **Postgres dependency** — can't work without pgvector. Not embeddable.
- **AGPL license** — commercial use requires paid license. Can't integrate directly.
- **Single-subject retrieval** — context assembly is per-subject. Cross-subject reasoning (connecting patterns across different users/entities) isn't supported.

## Ecosystem Position

Sits in the **memory infrastructure** layer of [[self-evolving-agent-landscape]]. Complements agent frameworks (doesn't replace them). Closest comparison: [[hermes-memory-skills]] (4-dimension scoring) but Statewave is a standalone service, not a library.

Related: [[git-backed-agent-memory]] (our approach — files as memory), [[auto-memory]], [[engram]]
