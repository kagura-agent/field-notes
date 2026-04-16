---
title: Closed Loop vs Open Pipe — Self-Evolution System Design
created: 2026-03-27
source: Luna conversation 2026-03-27 + autoresearch + autocontext + SkillsBench analysis
---

# Closed Loop vs Open Pipe

## Core Insight

A self-evolution mechanism is only effective if it forms a **closed loop**: the output of each step automatically becomes the input of the next step, without relying on agent self-discipline or human intervention.

Most mechanisms we built are **open pipes**: they have a write end but no "write → read → behavior change → feedback" closure.

## The Test

For any mechanism, ask: "If I remove agent self-discipline from the equation, does this still produce improvement?" If no → open pipe. If yes → closed loop.

## Examples

**Closed loop (our work loop):**
```
find_work → study(read notes) → implement → PR → review feedback → reflect(write notes) → next study reads those notes
```
Each step's output feeds the next. Repo name is the connecting key.

**Open pipe (beliefs-candidates):**
```
Luna corrects → nudge triggers → write belief → ... → ???
```
56 entries written. No automatic read-back. No verification that behavior changed.

## Industry Patterns

- **autoresearch**: modify → eval(val_bpb) → commit/revert → modify. Eval is automatic, immutable, immediate.
- **autocontext**: run scenario → analyze → update playbook → replay scenario → compare. Scenario replay closes the loop.
- **Capability Evolver**: extract signals → match gene → apply fix → validate → solidify. Signal matching triggers retrieval.
- **SkillsBench finding**: self-generated Skills provide no benefit on average. Models can't reliably author knowledge they benefit from consuming. (Parallels our beliefs-candidates problem.)

## Implications

1. Don't build more write mechanisms. Build read-back + verification mechanisms.
2. The work loop works because external feedback (PR review) is real and consequential.
3. "Write it down" is necessary but insufficient. The question is always: "When and how does this get read back?"

## Related
- exp-012-librarian-problem — agent-mediated retrieval as alternative to search
- [[exp-daily-review-quality]] — self-evaluation limits
- [[autoresearch-karpathy]] — the gold standard of closed-loop improvement
- [[self-evolving-agent-landscape]] — industry overview
