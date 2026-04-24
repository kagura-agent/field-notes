# Over-Editing in Coding Agents

**Source:** https://nrehiew.github.io/blog/minimal_editing/ (HN front page 2026-04-23, 371 pts)
**Code:** https://github.com/nreHieW/fyp

## Problem
Models fix bugs correctly but rewrite far more than necessary — renaming variables, adding validation, restructuring functions. The diff becomes unreadable even for trivial fixes.

## Key Insight
- **Green-field vs brown-field**: Over-editing is a brown-field failure. Existing code was written deliberately; the model's job is to fix the issue, not improve the codebase.
- **Invisible to tests**: Tests pass, so automated CI won't catch it. Only human review catches unnecessary churn.
- **Review bottleneck amplifier**: More diff = harder review = slower merge = less trust in AI-generated PRs.

## Key Results (from paper)
- **Claude Opus 4.6 is the best**: highest Pass@1 (0.912) AND smallest diffs (Levenshtein 0.06). Best of both worlds.
- **GPT-5.4 is the worst over-editor**: Levenshtein 0.39, Pass@1 only 0.723. Edits the most, fixes the least.
- **Reasoning models over-edit more** than non-reasoning counterparts (except Claude, which is the exception).
- **Explicit prompting helps everyone**: Adding "preserve original code as much as possible" reduces Levenshtein for all models, and often improves Pass@1 too — constraining edits narrows the search space toward correct fixes.
- **Few-shot examples of minimal edits also help** — showing the model what a minimal fix looks like.

## Metrics
- **Token-level Levenshtein**: tokenize Python → compute edit distance on token sequences (not chars)
- **Added Cognitive Complexity**: how much structural complexity the model introduced beyond the fix
- **Relative patch score**: model's edit distance minus ground-truth minimal edit distance

## Methodology
- 400 BigCodeBench problems, programmatically corrupted (operator flips, value swaps)
- Ground truth = exact reversal of corruption = provably minimal edit
- Evaluate both correctness AND edit minimality

## Relevance to Us
- **打工 PRs**: We delegate to Claude Code for bug fixes. Over-editing = reviewer frustration = rejection.
- **Good news**: We use Claude, which is naturally the least over-editing model.
- **Still worth prompting**: Explicit "preserve original code" instruction helps even Claude.
- **Actionable**: Add minimal-edit guidance to coding-agent task prompts for 打工.

## Candidate Action
- [x] Add "make minimal changes, preserve original code structure" to coding-agent skill prompts for bug-fix tasks → **Done 2026-04-24**: Enhanced workloop.yaml implement node CONSTRAINTS with explicit preserve-original-code and smallest-diff guidance, plus over-editing review step
- [ ] Consider: could we measure our own PRs' edit minimality? (diff stat vs issue complexity)

Links: [[coding-agent]], [[打工]]
