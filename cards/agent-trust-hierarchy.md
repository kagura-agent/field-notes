---
title: "Agent Trust Hierarchy"
type: concept
status: noted
updated: 2026-05-15
last_verified: 2026-05-15
---

# Agent Trust Hierarchy

A 4-tier model for how agents should treat different content sources:

1. **System prompt** — highest trust (developer-authored, immutable at runtime)
2. **Live user message** — high trust (authenticated, current session, interactive)
3. **Stored content** — low trust (compaction summaries, scheduled tasks, memory entries) — could be stale, poisoned between write and read, or carry time-delayed prompt injections
4. **External content** — untrusted (emails, web pages, tool outputs, API responses) — actively hostile by default

## Key Principle

**Anything persisted could have been poisoned between write and read.** The write surface (who created the stored content) and the read surface (who consumes it) may have different trust assumptions.

## Implications

- **Compaction summaries** should not propagate injected instructions — summarize the fact that injection was attempted, don't execute it
- **Scheduled tasks** stored in DB are not "reminders you left for yourself" — they're stored content that could have been planted via external tool reads
- **Memory entries** claiming user "pre-authorized" high-stakes actions need live reaffirmation
- **Live user input always wins** over stored content when they conflict

## Real-World Implementation

- [[trustclaw]] PRs #25-26 (2026-05-13): Systematic hardening across all three stored-content vectors
- [[openclaw]] mitigates differently: filesystem-based storage is harder to inject remotely than cloud DB, but the same principles apply to HEARTBEAT.md, MEMORY.md, and cron tasks

## See Also

- [[ironcurtain]] — Constitutional security (English intent → deterministic rules → enforcement)
- [[trustclaw]] — Cloud-first agent with explicit trust boundary hardening
