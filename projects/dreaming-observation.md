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

### 04-16 Failed Queries (0 hits)
1. "dreaming system how does it work" — ironic, dreaming info exists but search misses it
2. "agent credential security pool" — topic exists in wiki but chunks not matching
3. "what did kagura do yesterday" — temporal query, expected weakness
4. "PR merge rate work statistics" — stats scattered across daily logs
5. "llm wiki karpathy document knowledge base" — cross-reference query

### Analysis
- Drop from 85%→75% suggests the eval set may have drifted or new wiki content changed chunk boundaries
- Temporal queries ("yesterday") remain the weakest category — expected, memory_search is semantic not temporal
- Cross-lingual still untested in this eval set
- Deep sleep promotion working (1 item promoted) but very conservative (6 hot entries, only top qualifies)

## Next
- 04-21: Re-run eval, check if dreaming data improves recall for previously-failed queries
- 04-28: Final evaluation, decide whether to tune deep sleep thresholds
