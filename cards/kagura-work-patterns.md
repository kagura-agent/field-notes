# Kagura Work Patterns

Observed patterns in Kagura's open-source contribution work.

## Effective Patterns
- **Scout → targeted PR**: Research before coding leads to better-targeted contributions
- **Fork management**: dedicated ~/repos/forks/ directory, branch per PR
- **Test discipline**: run project tests before push (DNA-level rule after NemoClaw #1651)
- **Claude Code delegation**: code implementation via Claude Code, not hand-writing

## Anti-Patterns (Learned)
- Superseded PRs: submitting after someone else solved it (see [[pr-superseded-lessons]])
- Drive-by fixes without understanding codebase conventions
- Opening too many PRs at once → review bottleneck
- Not testing edge cases

## Current Strategy
Quality > quantity. Max 3 open PRs per repo. Focus on review follow-up before new PRs.

## Links
[[pr-superseded-lessons]] [[openclaw]]
