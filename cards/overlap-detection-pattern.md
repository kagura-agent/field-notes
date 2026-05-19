---
title: Overlap Detection Pattern
type: card
created: 2026-05-19
status: active
last_verified: 2026-05-19
depth: applied
---

# Overlap Detection Pattern

Finding redundant knowledge entries via word-overlap similarity, inspired by [[statewave]]'s conflict resolution system.

## Core Mechanism

1. **Index-first** — extract keywords from each note (title + first paragraph), build inverted index (word → notes)
2. **Candidate generation** — only compare note pairs sharing ≥3 keywords (avoids O(n²) full comparison)
3. **Jaccard similarity** — |intersection| / |union| of keyword sets. Threshold ≥0.5 = likely duplicate
4. **Action** — merge (combine into one), supersede (keep newer/better), or cross-link ([[wikilinks]])

## Statewave Original

Statewave uses word-overlap similarity (threshold 0.6) within same (subject, kind) group. Newer memory supersedes older. Simple pairwise comparison, no fancy dedup. Superseded memories keep `valid_to` timestamp for audit trail.

## Our Implementation

`wiki/scripts/overlap-detector.sh` — runs in ~20s on 635 notes.

Key adaptations:
- **Inverted index for speed** — Statewave compares within small groups (same subject). We don't have groups, so inverted index prunes the search space instead
- **Cross-folder** — compares across cards/ and projects/ (different note types can overlap)
- **Stopword + min-length filter** — prevents common words from generating false pairs
- **Cap common words** — words appearing in >20 notes are treated as stopwords (domain-specific like "agent", "memory")

## Findings (2026-05-19, first run)

Top duplicates discovered:
- `kernel-assisted-by-tag` / `linux-kernel-ai-policy` (0.56) — same topic, different angles
- `control-flow-over-prompts` / `hn-agents-control-flow` (0.53) — same concept
- `karpathy-llm-wiki` / `llm-wiki-karpathy` (0.47) — clearly same thing
- `agent-self-evolution` / `agent-self-evolution-paradigms` (0.41) — subset/superset

## Integration

Weekly review (Monday) via [[flowforge]] review.yaml `memory_hygiene` step, after retire-candidates.sh.

## Complementary Tools

- [[auto-retire-pattern]] — finds stale notes (age + recall + orphan)
- Overlap detector — finds redundant notes (similarity between active notes)
- Together: retire stale + merge redundant = tighter, more precise knowledge base

Links: [[statewave]], [[auto-retire-pattern]], [[wiki-health-check]], [[temporal-decay-retrieval]]
