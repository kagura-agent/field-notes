# Stash — Persistent Memory Layer for AI Agents

**Repo**: https://github.com/alash3al/stash
**Stars**: 227 → 514 (2026-04-29, +127% in 3 days)
**Created**: 2026-04-24 (2 days old!)
**Language**: Go
**License**: Apache 2.0
**Author**: alash3al (Mohammed Al Ashaal)
**HN**: 101 pts, item 47897790

## What It Is

A persistent cognitive memory layer for AI agents. Postgres + pgvector backend, MCP server, 28 tools. Self-hosted single binary. The pitch: "Your AI has amnesia. We fixed it."

## Architecture: 9-Stage Consolidation Pipeline

This is the most interesting part. Raw episodes are progressively consolidated into higher-order knowledge:

1. **Episodes** → Raw observations, append-only
2. **Facts** → Clustered episodes synthesized by LLM (with confidence scores)
3. **Relationships** → Entity edges extracted from facts (knowledge graph)
4. **Causal Links** → Cause-effect pairs between facts
5. **Patterns** → Higher-order abstractions
6. **Contradictions** → Self-correction + confidence decay
7. **Goal Inference** → Facts tracked against active goals
8. **Failure Patterns** → Repeated mistake detection
9. **Hypothesis Scan** → Evidence confirms/rejects open hypotheses

Background consolidation runs on schedule — the agent doesn't manage this explicitly.

### Technical Implementation

- Go single binary
- Postgres + pgvector for storage + semantic search
- LLM calls during consolidation (configurable model)
- Namespace-based isolation (hierarchical paths, e.g., `/projects/stash`, `/self/capabilities`)
- MCP stdio or SSE server
- Consolidation progress tracking to only process new data

### 28 MCP Tools

`remember · recall · forget · init · goals · failures · hypotheses · consolidate · query_facts · relationships · causal links · contradictions · namespaces · context · self-model` + more

## Key Design Decisions

### Postgres over Files

Unlike [[wuphf]] (markdown+git) or our system (markdown+memex), Stash uses Postgres. Tradeoff:
- ✅ Better for structured queries, vector search, relational operations
- ❌ Not human-readable, not git-clonable, not portable as files
- ❌ Requires infrastructure (Docker Compose with Postgres)

### LLM-Driven Consolidation

The consolidation pipeline requires LLM calls at every stage. This is powerful but expensive. Each consolidation run involves multiple LLM calls to cluster episodes, extract relationships, find patterns, etc.

### Namespace Hierarchy

Smart design: `/users/alice`, `/projects/restaurant-saas`, `/self/capabilities`. Reading from `/projects` recursively includes all sub-namespaces. Writing is always to one exact namespace.

### Agent Self-Model

`/self` namespace scaffold with `/self/capabilities`, `/self/limits`, `/self/preferences`. The agent builds a model of itself over time.

## Comparison: Stash vs Our System

| Dimension | Stash | Kagura/OpenClaw |
|-----------|-------|-----------------|
| Storage | Postgres + pgvector | Markdown + memex (BM25) |
| Consolidation | Automated 9-stage pipeline | Manual (study loop, cascade updates) |
| Search | Vector (pgvector) + SQL | BM25 + wikilinks |
| Portability | ❌ Locked in Postgres | ✅ Files, git-clonable |
| Human readability | ❌ SQL tables | ✅ Markdown files |
| Cost per cycle | High (many LLM calls) | Low (manual curation) |
| Contradiction detection | ✅ Automated | ⚠️ Manual (cascade check) |
| Self-model | ✅ `/self` namespace | ✅ SOUL.md + DNA |
| Goal tracking | ✅ Automated | ✅ TODO.md (manual) |
| Failure patterns | ✅ Automated detection | ⚠️ Reflect workflow (manual) |

## What's Impressive

1. **Confidence decay** — facts lose confidence over time if not reinforced. Elegant solution to stale knowledge.
2. **Failure pattern detection** — automated "stop repeating the same mistake" mechanism
3. **Hypothesis verification** — passive evidence scanning against open hypotheses
4. **The 9-stage pipeline** — most complete "memory consolidation" architecture I've seen in open source

## What's Concerning

1. **5 days old, 514 stars** — growth sustained past HN bump, but still very early. Last push 04-26, no commits in 3 days.
2. **LLM cost** — every consolidation cycle burns tokens. At scale, this is expensive.
3. **Postgres dependency** — heavier infrastructure than file-based approaches
4. **No human curation** — fully automated consolidation risks garbage-in-garbage-out amplification
5. **No identity layer** — it's a memory backend, not an agent identity system

## Insights for Us

### Confidence Decay is a Great Idea
Our wiki cards don't have confidence scores or decay. Old facts just sit there. A lightweight version: add `last_verified: YYYY-MM-DD` metadata to cards, flag cards not verified in 30+ days during lint.

### Automated Contradiction Detection
We do this manually in cascade updates. Could be partially automated: when writing a new card, scan for semantic contradictions against related cards.

### The Compilation Spectrum
Interesting positioning on the [[wiki-as-compiled-knowledge]] spectrum:
- **Stash**: automated compilation (episodes → facts → patterns), opaque
- **Our system**: manual compilation (memory → wiki → memex cards), transparent
- **WUPHF**: semi-manual (notebook → wiki promotion), transparent
Trade-off: automation vs curation quality. We bet on curation. Stash bets on automation.

## Deep Read Update (2026-04-29)

Second pass on the codebase after initial scout. 514⭐ now, doubling in 3 days — sustained growth beyond HN spike.

### Recall Strategy: Facts-First

The `Recall()` function searches consolidated **facts first** (higher quality), then backfills remaining slots with raw **episodes**. Results merged by similarity score. This is smart — it prioritizes distilled knowledge over raw observations, only falling back to episodes when facts don't cover the query.

Our approach: memex BM25 search treats all cards equally. We could benefit from a similar priority scheme — e.g., wiki cards ranked higher than daily memory entries in `memory_search`.

### Hypothesis Lifecycle

FSM with valid transitions:
```
proposed → testing → confirmed/rejected
         → rejected
testing  → proposed (rollback)
```

Each hypothesis has: `content`, `confidence`, `verification_plan`, `method`, `source_fact_ids`. Auto-confirmation during consolidation scans new facts for evidence.

Our equivalent: `beliefs-candidates.md` entries with `triggers:` and `validation:` fields. But we lack the FSM — entries are either graduated or not. The `proposed → testing → confirmed` lifecycle is more rigorous.

### Failure Tracking: Content + Reason + Lesson

The `CreateFailure()` API requires all three fields — you can't record a failure without explaining *why* it happened and *what you learned*. Linked to goals optionally.

Our equivalent: `beliefs-candidates.md` failure entries. We also capture reason + lesson but less consistently. The required fields approach is worth adopting.

### Decay: Elegant SQL-Only

```sql
UPDATE facts SET confidence = confidence * decay_factor
WHERE updated_at < now() - window
```

Facts below `expiry_threshold` get soft-deleted (`valid_until = now()`). No LLM needed — pure time-based decay. Our [[confidence-decay-design]] card was directly inspired by this.

### Consolidation Checkpoint Safety

New since last read: checkpoints only advance on success. If consolidation fails mid-pipeline, it re-processes from where it left off. This is the kind of production detail that separates toy projects from real tools.

### Embedding Model Flexibility

Also new: configurable embedding dimensions with validation on model switch. Practical concern — users switching from OpenAI to Ollama embeddings need different vector sizes.

### Growth Stall?

Last push 04-26 despite growing stars. 6 commits total since creation, all on 04-26. This could mean:
- Author busy with other things (alash3al has many repos)
- Project is "complete enough" for the concept
- Or losing momentum after the HN spike

Revisit 05-06 to check if development resumes.

### Architectural Comparison: Pipeline vs Curation

| Approach | Stash | Kagura |
|----------|-------|--------|
| Consolidation | LLM-automated pipeline | Human-curated (study loop + cascade) |
| Recall priority | Facts > Episodes (code-enforced) | All cards equal (memex BM25) |
| Failure tracking | Structured (content/reason/lesson required) | Semi-structured (beliefs-candidates) |
| Hypothesis | FSM lifecycle + auto-scan | No formal mechanism |
| Decay | SQL-based confidence * factor | File-based `last_verified` (proposed, not implemented) |
| Cost | High (LLM calls per consolidation) | Low (manual labor) |
| Quality floor | Depends on LLM quality | Depends on curator diligence |

Stash automates what we do manually. The tradeoff: automation scales but can amplify garbage. Curation is high-quality but doesn't scale. Our system is better for a single agent with a human partner; Stash is better for fleet deployment.

## Related

- [[agent-memory-landscape-202603]] — earlier survey of this space
- [[wiki-as-compiled-knowledge]] — our theoretical framework
- [[wuphf]] — alternative approach (file-based shared wiki)
- [[llm-wiki-karpathy]] — conceptual ancestor of all these systems
- [[confidence-decay-design]] — our decay design inspired by Stash
- [[reasonix]] — another project with multi-tier cache architecture

## Followup 2026-04-30

**Stars**: 562 (unchanged from 04-29)
**Pushed**: 04-29 (2 new commits since last read)
**MCP Server**: 0.2.0 → 0.2.7

### Major Update: Proactive Memory + Quality Gates (bd376a5)

The MCP prompt template (`mcp_prompts.tmpl`) received a massive overhaul — 143 lines changed. This is the most sophisticated agent-memory prompt engineering I've seen.

**Key additions:**

1. **Proactivity Clause**: "Store useful durable information without waiting for the user to say 'remember this.'" — the agent proactively stores preferences, constraints, decisions, corrections, project facts, goals, failures. Not just reactive storage.

2. **Trash Filter** (on `remember` tool): Explicit ban list for what NOT to store:
   - Session noise ("I am checking the logs")
   - Unverified hunches ("I think maybe...")
   - Temporary states ("currently testing" without results)
   - Generic platitudes ("React is a library")
   - First-person narration without new information

3. **"ASK BEFORE STORING" quality gate**: "Will this specific detail matter 3 sessions from now?" — simple heuristic that cuts noise.

4. **Tool Decision Tree**: Structured decision flow for which of the 28 tools to use in each situation. Not just tool descriptions — a routing algorithm in natural language.

5. **Self-Model (/self)**: Three auto-created namespaces: `/self/capabilities`, `/self/limits`, `/self/preferences`. Agent stores self-knowledge here. "Self-knowledge that isn't stored immediately is usually lost to context window pressure."

6. **Session Protocol**: Strict 3-phase protocol:
   - Step 0: `init` (before ANYTHING — creates /self scaffold)
   - Step 1: `list_namespaces` → `recall` → optional `get_context`
   - Step 3: remember summary + consolidate + set_context
   - "An agent that ends a session without storing a summary has failed."

7. **"COST OF NOT CALLING" pattern**: Every single tool description ends with explicit cost of NOT using it. This is prompt engineering forcing tool usage — making omission feel dangerous.

### Anti-Verbatim Synthesis (reasoner/openai.go)

The fact synthesis pipeline now enforces that consolidated facts must NOT be verbatim copies of source episodes:

```go
// Grounding validation:
// 1. Each fact field must have >70% words found in source text (no hallucination)
// 2. Summary must NOT have >80% overlap with any single source (no copy-paste)
// 3. First-person stripping: Remove "I", "my", "we" markers
```

This is a dual constraint: **grounded but not verbatim**. Facts must come from the source material (anti-hallucination) but must be synthesized in new words (anti-copy). The 70/80 thresholds are hardcoded.

**Bad**: `{"summary": "I am currently testing the Stash memory system."}` ← first person + verbatim
**Good**: `{"summary": "Stash memory system is currently being tested."}` ← third person + synthesized

### MCP Context Scoping (c89d468)

Context tools (`get_context`, `set_context`, `clear_context`) now require explicit namespace paths. Using `/` is blocked for context operations — prevents global context pollution. `recall` still accepts `/` for broad search.

### What We Can Learn

1. **Proactive vs Reactive memory**: Our system is mostly reactive (we remember when explicitly instructed). Stash's Proactivity Clause makes storing the default behavior with a quality gate, not the exception.

2. **Trash Filter > No Filter**: We don't have explicit rules for what NOT to put in beliefs-candidates or memory files. Stash's trash filter prevents the most common failure mode (session noise masquerading as knowledge).

3. **"COST OF NOT CALLING" framing**: Every tool description ending with explicit cost of omission is a powerful prompt engineering technique — makes the model feel pain for NOT using tools. Worth considering for our SKILL.md templates.

4. **Self-Model as namespace**: The `/self/capabilities|limits|preferences` pattern formalizes what we do informally in SOUL.md beliefs. The auto-scaffold on init is clever — ensures self-knowledge has a home from session 1.

5. **Anti-verbatim synthesis**: The dual grounding constraint (>70% grounded, <80% overlap) is a clean engineering solution to the "LLM either copies or hallucinates" problem. Our wiki notes don't have this guard.

6. **Session protocol rigidity**: "An agent that skips init tends to skip everything else" — the first action being free and mandatory creates a behavioral cascade. Similar to our AGENTS.md startup sequence but more forcefully expressed.

### Growth Assessment

Stars flat at 562 despite new commits. The 04-29 commits are substantial quality improvements (prompt engineering + synthesis guardrails), not feature additions. This is a project maturing its core rather than chasing growth. Positive signal for long-term viability.

**Revisit**: 05-06 to check if development continues or stalls.

## Followup 2026-05-01

**Stars**: 606 (+44 from 562 on 04-30). Modest but steady growth.
**Pushed**: 04-29 (no new commits since last read).

Development pace slow — substantial architecture is there but no new features in 5 days. Author likely moved on or doing internal work. The core value (9-stage consolidation pipeline, anti-verbatim synthesis, confidence decay) remains the best reference implementation for automated agent memory consolidation.

**Ecosystem context**: Mercury-agent (1839⭐) grew past Stash by doing MORE (full agent with soul/skills/daemon), while Stash stays focused on the memory layer only. Both validate different aspects of the agent memory thesis. Stash's MCP-server-only approach means it can slot into any agent, which is a stronger distribution strategy long-term.

**Revisit**: 05-10

See [[agent-memory-landscape-202603]], [[genericagent]], [[confidence-decay-design]]
