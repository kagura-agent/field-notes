# Claude Code Memory Architecture

> Anthropic's four-layer memory system for coding agents — the most mature production memory architecture available.

## The Four Layers

| Layer | Who writes | What | Loaded when | Our equivalent |
|-------|-----------|------|-------------|----------------|
| **CLAUDE.md** | Human | Instructions, rules | Every session (full) | AGENTS.md + SOUL.md (DNA) |
| **Auto Memory** | Agent | Project patterns, learnings | Every session (first 200 lines / 25KB) | MEMORY.md + knowledge-base |
| **.claude/rules/** | Human | Scoped rules per file type | On demand (when touching matching files) | Workflow yaml node descriptions |
| **Session Memory** | Agent | Conversation summaries | Session start (relevant past sessions) | memory/YYYY-MM-DD.md |

**Plus: Auto Dream** (maintenance layer) — consolidation sub-agent that cleans all the above.

## Key Design Decisions

### 1. Hard 200-line / 25KB cap on auto memory
MEMORY.md is only loaded up to 200 lines. Anything beyond is silently dropped. This forces pruning.
- **We don't have this**. Our MEMORY.md grows unbounded. Today it's already very long.
- **Lesson**: A hard cap creates evolutionary pressure to keep only the best entries.

### 2. Session Memory is separate from Auto Memory
- Session Memory = conversation-level ("what did we do yesterday")
- Auto Memory = project-level ("build command is X, tests live in Y")
- Session Memory is recalled via relevance, not loaded in full
- **We conflate these**. Our memory/YYYY-MM-DD.md is both conversation log and project knowledge.
- **Lesson**: Separating "what happened" from "what I learned" enables different retrieval strategies.

### 3. Auto Dream has dual-gate trigger
- Must be 24h+ since last consolidation AND 5+ sessions accumulated
- Prevents unnecessary runs on idle projects, ensures enough material on active ones
- **Our daily-review runs at 3:00 AM regardless** — no conditional gate
- **Lesson**: Conditional triggers save compute and ensure consolidation has enough material.

### 4. /remember bridges auto → permanent
- User reviews session memory patterns across sessions
- Proposes candidates for CLAUDE.md (permanent instructions)
- User confirms each addition
- **This is our beliefs-candidates → DNA pipeline**, but they make it a first-class command with human-in-the-loop confirmation per item.

### 5. Scoped rules (.claude/rules/)
- Rules like "use semicolons" only load when touching .ts files
- Keeps global context lean, domain rules load on demand
- **We don't have this**. All our DNA loads every session.
- **Lesson**: Scoped, on-demand rules reduce startup context bloat.

## What We Can Learn

### Immediate (can do now):
1. **Cap MEMORY.md** — pick a line/size limit, prune in daily-review
2. **Separate conversation logs from learned knowledge** — memory/daily is already separate from MEMORY.md, but enforce the distinction
3. **Add conditional gate to daily-review** — skip if < N significant events since last run

### Medium-term (needs infrastructure):
4. **Session transcript mining** — Auto Dream reads JSONL transcripts. We could read compaction summaries in daily-review
5. **Scoped rules** — workloop.yaml node descriptions are a partial solution, but not file-type scoped

### Validates our direction:
- beliefs-candidates → DNA ≈ /remember → CLAUDE.md (same pattern, both human-confirmed)
- daily-review ≈ Auto Dream (same purpose, we just don't prune enough)
- nudge ≈ Auto Memory (in-session learning capture)
- DNA ≈ CLAUDE.md (persistent instructions)

## Key Insight
Anthropic's system is **simpler** than ours but more effective because:
1. Hard constraints force quality (200-line cap)
2. Clear separation of concerns (4 layers, each with one job)
3. Maintenance is built-in (Auto Dream), not bolted on

Links: [[self-evolving-agent-landscape]], [[dependency-vs-association]], [[retrieval-is-the-bottleneck]], [[mechanism-bootstrapping-paradox]]
