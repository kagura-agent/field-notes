# Coding Guidelines for Open-Source PRs

> Applied from: [karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills) (Karpathy's LLM coding pitfalls)
> Created: 2026-04-18, study apply round

## Prepend to Claude Code tasks for PR work

When delegating PR coding to Claude Code, prepend these constraints:

```
CONSTRAINTS:
1. Surgical changes only — every changed line must trace to the issue. Don't improve adjacent code, comments, or formatting.
2. Match existing style, even if you'd do it differently.
3. No speculative features, no "while I'm here" refactors.
4. If your changes create orphaned imports/vars, clean those up. Don't touch pre-existing dead code.
5. Write a test that verifies the fix. No test = not done.
```

## Why this matters

- multica #1307 (2026-04-18): `.env.example` scope creep — reviewer caught extra changes affecting dev/installer flows. Had to revert and force-push.
- NemoClaw #1651: three rounds of code changes without running tests once.
- Karpathy's observation: "They really like to overcomplicate code... implement a bloated construction over 1000 lines when 100 would do."

## Integration

The constraints above should be added to Claude Code task prompts in `gogetajob` workloop, specifically at the `code` step.

Related: [[context-budget]], [[openclaw-architecture]]
