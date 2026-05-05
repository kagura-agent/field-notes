
## 05-05 Followup: 140x Memory Recall Speedup (v0.111.1→v0.111.3)

**PR #627**: `perf(daemon): speed up memory recall` — 706 additions, 388 deletions, 5 files

### Root Cause
Large workspaces (1.2GB+ memory DB) caused SQLite to choose broad indexes (`agent_id`, `status`, `is_deleted`) *before* applying FTS rowid matches. Single recalls took 30+ seconds of synchronous SQLite work.

### Fix Pattern: CROSS JOIN + INDEXED BY
1. **FTS-first joins**: Changed `JOIN memories m ON memories_fts.rowid = m.rowid` → `CROSS JOIN memories m ON memories_fts.rowid = m.rowid`. `CROSS JOIN` prevents SQLite query planner from reordering — forces FTS virtual table to drive the join, not the broad regular indexes.
2. **Explicit index hints**: Added `INDEXED BY idx_entity_aspects_entity` and `INDEXED BY idx_entity_attributes_aspect` to force selective indexes in graph traversal queries.
3. **Hint recall tightening**: Hint candidates now re-join through `memories` table with `is_deleted`/scope/agent/visibility filters before scoring — prevents stale hint pollution.

### Instrumentation
- `RecallTimings` struct with per-stage timing (FTS, hints, embedding, graph traversal, scoring)
- Structured warn log for recalls >1s (`RECALL_TIMING_LOG_THRESHOLD_MS = 1000`)
- Benchmark suite supports real-workspace mode (copies DB to /tmp, doesn't touch live)

### Key Takeaway
**SQLite FTS + large tables = query planner trap.** When FTS virtual tables are joined with regular tables, SQLite's cost estimator can't accurately predict FTS selectivity, leading to catastrophically bad join orders. `CROSS JOIN` is the escape hatch.

### Relevance to Us
- Our wiki/memory is file-based (no SQL), so not directly applicable
- But the **observability pattern** (per-stage timing + slow-query logging) is universally valuable
- If we ever move to SQLite-backed memory (like Signet, invincat, stash all do), this is the optimization playbook
- The hint re-join tightening pattern applies anywhere you have denormalized acceleration structures

### Star Update
136⭐ (was 135 on 05-04). Growth has plateaued. But code quality is high — this is a serious engineering team.
