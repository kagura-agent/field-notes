# brain — Git-Backed Long-Term Memory for AI Coding Agents

**Repo**: https://github.com/codejunkie99/brain
**Stars**: 22 (2026-04-29)
**Created**: 2026-04-27 (2 days old)
**Language**: Rust
**License**: Apache 2.0
**Author**: codejunkie99 (@Av1dlive)

## What It Is

A local-first, git-backed memory system for AI coding agents. Each memory event is a JSON blob committed to `~/.brain` as a git commit. SQLite FTS5 index is rebuilt from git — it's a cache, not source of truth. MCP server, CLI, and TUI included.

Multi-agent compatible: adapters for Claude Code, Cursor, Codex, OpenClaw, Hermes. `brain onboard --agents all` wires them up.

## Why It's Interesting

### 1. Git as Event Log

Most agent memory systems use databases. brain treats git as an append-only event log. Each event = one JSON file + one commit. The git history IS the audit trail.

**Tradeoff**: Git isn't designed for this workload (thousands of tiny commits). But it gives you: free sync (`push`/`pull`), free audit (`git log`), free backup, and human-inspectable history. Clever for personal-scale memory.

### 2. Bitemporal Model

Every event has two timestamps:
- `time_observed` — when the fact happened in reality
- `time_recorded` — when the system learned about it

This distinction matters. "The server was down at 3am" (observed) vs "I learned about the outage at 8am" (recorded). Enables queries like "what did I know at time T?" — though full point-in-time reads are deferred.

Our system has no equivalent. Daily memory entries are recorded in order, but we don't distinguish between event time and recording time.

### 3. Typed Event Taxonomy

Not just "notes" — 10 distinct event types:
- **Observe** — raw observations (equivalent to our `memory/YYYY-MM-DD.md` entries)
- **Claim** — assertions that can be superseded (chain_id links supersession chains)
- **Lesson** — learned lessons (equivalent to our `beliefs-candidates.md`)
- **Pref** — preferences
- **SkillEdit** — skill modifications
- **Verify** — evidence for/against a claim
- **Archive/Redact** — lifecycle management
- **Import/Audit** — administrative events

The **Claim supersession chain** is particularly smart: when you learn something new that invalidates an old claim, the new claim links to the old one via `chain_id`. You can trace how your understanding evolved.

### 4. Memory Layers (Cognitive Science)

Six layers mapping to cognitive models:
- **Working** — active context
- **Episodic** — specific events/experiences
- **Semantic** — general knowledge/facts
- **Personal** — identity/preferences
- **Skill** — procedural knowledge
- **Protocol** — rules/guidelines

Our system has informal equivalents (SOUL.md = Personal, AGENTS.md = Protocol, wiki/cards = Semantic, memory/*.md = Episodic) but no formal layer model.

### 5. Authority Model

Events carry an authority source and optional score (0-100):
- Regulator, Doctor, Lawyer, SeniorEngineer, Agent, Intern, User, System

Not all memories should be trusted equally. A human correction should outweigh an agent's guess. We don't have this — all our wiki entries are treated as equal authority.

### 6. Secret Prefilter

RegexSet scan over serialized JSON BEFORE git commit. Covers: API keys (OpenAI, Anthropic, GitHub, AWS), database URIs with credentials, private keys, JWTs. Event is rejected — the secret never enters git history.

Our wiki-lint.py does similar scanning (25 patterns, added 04-28) but post-hoc. brain's approach is better — prevent vs detect.

## Architecture Comparison: brain vs [[stash]] vs Kagura

| Dimension | brain | [[stash]] | Kagura |
|-----------|-------|-----------|--------|
| Storage | Git + SQLite FTS5 | Postgres + pgvector | Markdown + memex BM25 |
| Consolidation | None (raw events) | 9-stage LLM pipeline | Manual (study loop) |
| Search | BM25 (FTS5) | Vector (pgvector) | BM25 (memex) |
| Event typing | 10 types, strongly typed | Episodes + Facts | Untyped markdown |
| Memory layers | 6 formal layers | Namespaces | Informal (SOUL/AGENTS/wiki) |
| Authority model | Yes (source + score) | No | No |
| Bitemporal | Yes | No | No |
| Secret scanning | Pre-commit (prevent) | No | Post-hoc (detect) |
| LLM dependency | None for storage | High (consolidation) | None |
| Human readability | Medium (JSON) | Low (SQL) | High (markdown) |
| Portability | ✅ Git push/pull | ❌ DB export | ✅ Git push/pull |
| Multi-agent | ✅ 5 agent adapters | ✅ MCP | ❌ OpenClaw only |

## Key Insights

### brain = "Git for Memory" vs Stash = "Database for Memory"

Two opposing bets on the same problem:
- **brain**: Memory should be version-controlled, human-inspectable, portable. Git is the right abstraction because memories, like code, evolve over time.
- **[[stash]]**: Memory should be queryable, consolidatable, vector-searchable. Postgres is the right abstraction because memories are structured data.

Both are right for different use cases. brain for individual developers/agents with deep audit needs. Stash for fleet deployment where automated consolidation matters more than transparency.

### Authority and Bitemporality Are Missing from Most Systems

brain is the first agent memory system I've seen with both authority scoring and bitemporal timestamps. These are database concepts from the 1990s, but nobody in the agent space seems to have applied them until now.

**For us**: We should at minimum add `source:` metadata to beliefs-candidates entries (human correction vs self-observation vs study finding). Different sources should have different graduation thresholds.

### The Prevention > Detection Pattern

brain's secret prefilter scans BEFORE commit. Our wiki-lint scans AFTER write. The lesson generalizes: for anything that's hard to undo (git commits, sent messages, published PRs), validate before the action, not after.

### No Consolidation = Feature, Not Bug

brain deliberately has NO LLM-driven consolidation. Events stay as-is. The search layer (FTS5 BM25) finds relevant events; the consuming agent does its own synthesis in-context.

This is the anti-[[stash]] position: consolidation is risky because LLMs hallucinate, and once you consolidate wrong, you've corrupted your memory. Better to keep raw events and let each query do fresh synthesis.

Our system is actually closest to this philosophy — we keep raw memory entries and curate manually into wiki cards.

## What We Could Adopt

1. **Authority source on beliefs-candidates entries** — trivial to add `source: human|self|study|review` field
2. **Claim supersession chains** — when updating a wiki card, link to the previous version's reasoning
3. **Pre-commit validation pattern** — extend our existing checks to run before `git add`, not just in lint
4. **Bitemporal awareness** — at minimum, distinguish "when something happened" from "when I learned about it" in memory entries

## Growth Signal

22⭐ in 2 days with no HN front page. Rust + clean architecture + multi-agent onboarding. Worth watching. The codebase quality is high — proper error handling, security considerations, well-structured crates.

**Revisit**: 05-06 to check if development continues and community forms.

## Related

- [[stash]] — the "database approach" counterpoint
- [[claude-code-memory-architecture]] — Anthropic's 4-layer system
- [[wiki-as-compiled-knowledge]] — our compilation philosophy
- [[hermes-memory-skills]] — memory hygiene for Hermes
- [[agent-memory-landscape-202603]] — broader landscape survey
- [[confidence-decay-design]] — Stash-inspired decay concept
