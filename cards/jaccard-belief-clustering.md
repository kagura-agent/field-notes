---
title: Jaccard Clustering for Belief Dedup
created: 2026-05-02
type: card
tags: [beliefs, tooling, agentic-stack, dedup]
status: active
---

# Jaccard Clustering for Belief Dedup

## Origin

Inspired by [[agentic-stack]]'s dream-cycle: they use Jaccard similarity to cluster agent memories without LLM calls, finding duplicates cheaply.

## Our Implementation

`tools/beliefs-cluster.py` — standalone Python script for [[beliefs-candidates]] analysis.

### Dual-Layer Approach

Pure word-overlap Jaccard fails on our data (long CJK narratives, diverse vocabulary). Solution:

1. **Word-level**: Latin words (3+ chars) + CJK bigrams (2-char sliding window), after stopword removal
2. **Concept-level**: Domain-specific keyword → thematic tag mapping (e.g., `PR`/`merge`/`review` → `C:pr-workflow`)

Concept tags act as high-signal features that boost Jaccard for semantically similar but lexically different entries.

### What It Reports

- **Novel clusters**: entries with high overlap but different/missing pattern tags → actionable dedup
- **Graduation candidates**: patterns repeated 3+ times → ready to upgrade to DNA
- **Concept clusters**: thematic groupings across all entries (concept-level view)
- **Pattern tag statistics**: distribution and coverage

### Thresholds

- 0.25: very strict, almost nothing clusters (entries are too long/diverse)
- 0.15: catches near-duplicates (same event, different wording)
- 0.12: catches thematic relatives (related but distinct lessons)

### Limitations

- CJK bigrams are a crude proxy for semantic meaning
- Concept keywords are manually curated (need periodic review)
- Single-linkage clustering can chain unrelated entries through transitive links at low thresholds

## Relation to [[beliefs-upgrade-mechanism]]

This tool operates at the **discovery** stage: finding which beliefs are ready for graduation or need merging. The upgrade mechanism itself (when/where to promote) is documented separately.

## Usage

```bash
python3 tools/beliefs-cluster.py                    # default analysis
python3 tools/beliefs-cluster.py --concepts         # show thematic groupings
python3 tools/beliefs-cluster.py --threshold 0.12   # lower threshold
python3 tools/beliefs-cluster.py --show-tokens       # show shared tokens per cluster
```
