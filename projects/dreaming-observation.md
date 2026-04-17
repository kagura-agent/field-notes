# Dreaming Observation Log

## Setup
- Enabled: 2026-04-13
- Cron: 3:30 AM daily
- Config: light 3d lookback, REM 7d, deep minScore 0.8 / minRecallCount 3 / minUniqueQueries 2

## Stats

### 2026-04-16 (Day 3)
- Recall store: 1,947 entries, 70 with recalls (3.6%), 98 total recall hits
- Hot entries (≥3 recalls): 6
- Events: 114 (104 recall.recorded, 9 dream.completed, 1 promotion.applied)
- Dream files: 2 days (04-15, 04-16) in light/deep/rem
- Deep sleep promoted 1 candidate to MEMORY.md
- Session corpus: 9 days (04-08 to 04-16)

### Memory Search Eval Trend
| Date | Hit Rate | MRR | nDCG@5 | Notes |
|------|----------|-----|--------|-------|
| 04-14 | 80% | 0.775 | 0.854 | Baseline (v0.1) |
| 04-15 | 85% | 0.775 | — | +5% hit rate |
| 04-16 | 75% | 0.725 | 0.755 | ⬇ regression |
| 04-17 | 70% | 0.700 | 0.757 | ⬇ continued decline; 5 zero-result queries |

### 04-17 Failed Queries (0 hits)
1. "dreaming system how does it work" — **qrel staleness**: search returns dreaming.md + dreaming-observation.md which ARE relevant but not in qrels. Need to update qrels.
2. "agent credential security pool" — file exists but not indexed/chunked by memory_search
3. "chat first product design" — **query sensitivity**: "chat first product" (no "design") returns score 0.574. Single word addition kills retrieval.
4. "what did kagura do yesterday" — temporal query, expected weakness (semantic search can't resolve relative time)
5. "PR merge rate work statistics" — operational/computed fact, not a document topic
6. "llm wiki karpathy document knowledge base" — cross-reference query, file exists but not indexed

### Analysis
- 70% hit rate = 3rd consecutive decline (85→75→70). Two root causes:
  1. **Qrel staleness** (query 1): wiki evolved but qrels didn't. dreaming.md card was created after eval set. Fix: update qrels.
  2. **Indexing gaps**: 3 files exist in wiki but return zero results (agent-credential-security, chat-first-product with "design", llm-wiki). Suggests memory_search corpus doesn't cover all wiki files, or minScore threshold is filtering them out.
  3. **Query sensitivity**: adding a single common word ("design") to a good query kills retrieval. Fragile.
- Temporal and operational queries remain expected weaknesses
- If we fix qrel staleness (query 1 → hit), adjusted hit rate would be 75% (matching 04-16)

## Action Items
- [ ] Update eval qrels: add dreaming.md, dreaming-observation.md as relevant for query 1
- [ ] Investigate why 3 wiki files return zero results — check if they're in the indexed corpus
- [ ] Consider query robustness test: same intent, slightly different wording

## Next
- 04-21: Re-run eval with updated qrels; investigate indexing gaps
- 04-28: Final evaluation, decide whether to tune deep sleep thresholds
