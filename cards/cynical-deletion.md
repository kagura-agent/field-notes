# Cynical Deletion

A maintenance philosophy: instead of fixing bugs in defensive/tolerant code, **delete the code** that generates them.

## The Two Anti-Patterns

### Defenders
Code added to "protect against X" that produces more bugs than X itself.

Signs:
- Platform-specific workarounds that break on other platforms
- Process management that kills wrong processes
- Retry/recovery logic more complex than the original operation
- Each fix for the defender spawns new edge-case bugs ("defense spiral")

**Cure:** Delete the defender. Replace with simpler, narrower mechanism (e.g., `spawn(cmd, [args])` instead of shell-string quoting).

### Tolerators
Code that silently swallows errors, hiding bugs until they explode at scale.

Signs:
- Functions returning `undefined`/`null` on parse error instead of throwing
- `.passthrough()` schemas that accept anything
- Filters duplicated in two places that gradually drift apart
- Hooks that modify input data (truncate, reshape) without the caller knowing

**Cure:** Fail fast. Reject unknown input. Share predicates instead of duplicating logic.

## Key Principles

1. **Plan before surgery** — Write what to delete, what to keep, why, and how to verify. ~500 lines of reasoning before touching code
2. **Fix the default, reject config knobs** — Each option is attack surface. If the default is wrong, fix the default
3. **Shared predicate > synchronized logic** — Make drift physically impossible (same function reference)
4. **Tolerator half-lives are long** — Silent data loss can persist for months because symptoms are diffuse

## Origin

[[claude-mem]] PR #2141 (2026-04-25): 52 files changed, +2312/-1222, **27 issues closed** in one PR by deleting defenders and tolerators.

## Links

- [[claude-mem]] — the project that demonstrated this at scale
- Relates to: fail-fast principle, YAGNI, [[conciseness-accuracy-paradox]]

---
*Created: 2026-04-26*
