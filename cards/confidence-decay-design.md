---
title: Confidence Decay Design for Wiki Cards
slug: confidence-decay-design
tags: [wiki, knowledge-management, design, freshness]
created: 2026-04-26
status: design
---

# Confidence Decay for Wiki Cards

> Lightweight time-based staleness detection for wiki knowledge. Inspired by [[stash]] automated confidence decay, adapted for our file-based system.

## Problem

199 cards, no freshness signal. A card written 2026-03-22 about agent memory landscape has same weight as one written today. Agent ecosystem moves fast — 30-day-old project assessments may be wrong.

## Design: last_verified Metadata

### Approach

Add `last_verified: YYYY-MM-DD` to card frontmatter. Wiki-lint flags cards exceeding staleness threshold.

### Staleness Tiers

| Card Type | Threshold | Rationale |
|-----------|-----------|-----------|
| Project notes (`projects/`) | 14 days | Projects ship fast, assessments go stale |
| Concept cards (`cards/`) | 30 days | Abstractions age slower |
| Pattern cards (tagged `pattern`) | 60 days | Meta-patterns are durable |

### Verification = Touching

`last_verified` updates when:
1. Card content is edited (automatic via git hook or lint)
2. Card is read during study loop and confirmed still accurate (manual)
3. Cascade update touches the card

Cards with no `last_verified` default to `created` date.

### Lint Integration

Add to `wiki-lint.sh`:
```bash
# Check staleness
for f in cards/*.md projects/*.md; do
  verified=$(grep -m1 'last_verified:' "$f" | sed 's/.*: *//')
  [ -z "$verified" ] && verified=$(grep -m1 'created:' "$f" | sed 's/.*: *//')
  [ -z "$verified" ] && continue
  days_old=$(( ($(date +%s) - $(date -d "$verified" +%s)) / 86400 ))
  threshold=30
  [[ "$f" == projects/* ]] && threshold=14
  [ "$days_old" -gt "$threshold" ] && echo "STALE ($days_old days): $f"
done
```

### What NOT to Do

- ❌ Auto-delete stale cards (knowledge doesn't expire, freshness does)
- ❌ Confidence scores (too complex for file-based system — Stash needs this because it auto-generates facts; we curate manually)
- ❌ Auto-update (defeats the purpose — verification must be conscious)

## Comparison with Stash

| Aspect | Stash | Our Design |
|--------|-------|-----------|
| Mechanism | Numeric confidence score, auto-decay | Date-based staleness, lint flag |
| Granularity | Per-fact | Per-card |
| Action on stale | Lower retrieval ranking | Flag in lint report |
| Cost | LLM calls for re-evaluation | Zero (metadata + bash) |
| False positives | Low (semantic) | Medium (time-based) |

## Implementation Plan

1. Add `last_verified` to wiki-lint.sh staleness check
2. Backfill: set `last_verified: created` for all existing cards (one-time script)
3. Study loop: when reading a card during cascade check, update `last_verified` if confirmed
4. Monthly lint: review stale cards list, verify or archive

## Links

- [[wiki-health-check]] — parent lint system
- [[stash]] — inspiration for confidence decay
- [[frozen-trust-vs-time-decay]] — related trust concept
- [[memory-reconsolidation]] — theoretical framework
