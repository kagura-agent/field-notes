---
title: Auto-Retire Pattern
type: card
created: 2026-05-19
status: active
tags: [memory, knowledge-management, lifecycle, agent-infrastructure]
last_verified: 2026-05-19
---

# Auto-Retire Pattern

Automatically identifying and retiring stale knowledge entries based on access patterns, not just age.

## Core Insight

Append-only knowledge bases (wikis, memory stores, skill repos) accumulate cruft. Manual cleanup doesn't scale. The pattern: **track access frequency, combine with age/status signals, surface candidates for retirement.**

## Scoring Model

Multi-signal staleness score (0-100):
- **Age** (0-30): days since last modified — old = stale signal
- **Recall frequency** (0-30): never accessed by search = likely unused
- **Status** (0-25): frontmatter status field (dropped/stale > scout > active > deep-dive)
- **Orphan** (0-15): no inbound links = disconnected from knowledge graph

Key: no single signal is sufficient. A note can be old but frequently recalled (reference material). A note can be new but already orphaned (dead-end exploration).

## Implementation Considerations

- **Log maturity**: Recall frequency is meaningless with < 7 days of data. Halve weight when immature.
- **Freshness cap**: Cap age score to prevent new notes from being unfairly penalized (they haven't had time to accumulate recalls).
- **Don't auto-delete**: Surface candidates for human/agent review. Let the reviewer decide: archive, compress to stub, or delete.
- **Temporal policy** from [[elephant-agent]]: claims have volatility (situational decays fast, durable decays slow).

## Origins

- **Elephant Agent** (`understanding` package): stale claims automatically retired based on access patterns
- **Orb** (v0.6.0): telemetry-backed skill lifecycle — track which skills are actually invoked

## Applied

- `wiki/scripts/retire-candidates.sh` (2026-05-19): Implements scoring for our wiki. Integrated into daily-review memory_hygiene (weekly Monday scan).

## Related

[[elephant-agent]], [[temporal-decay-retrieval]], [[progressive-retrieval]]
