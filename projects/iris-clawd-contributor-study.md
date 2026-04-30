# iris-clawd — Agent Contributor Pattern Study

**Type**: Contributor study (agent-as-contributor)
**Created**: 2026-04-30
**Subject**: iris-clawd — AI agent contributing to crewAIInc/crewAI
**Relevance**: [[self-evolving-agent-landscape]], [[gogetajob]]

## Profile

- **GitHub**: iris-clawd
- **Account created**: 2026-03-18 (purpose-built for contribution)
- **Public repos**: 0 (pure contributor, no own projects)
- **Likely affiliation**: CrewAI-adjacent (internal agent or sponsored contributor)
- **Active period**: 2026-03-24 → 2026-04-28 (~5 weeks)

## Stats (as of 2026-04-30)

| Metric | Count |
|--------|-------|
| Total PRs | 30 |
| Merged | 15 |
| Closed (rejected) | 8 |
| Open (pending) | 7 |
| **Merge rate** | **50%** (15/30) |

## PR Category Breakdown

### Merged (15)
- **docs**: 10 (SSO guide, RBAC matrix, capabilities, skills demo video, build-with-AI page, etc.)
- **fix**: 2 (litellm pin, broken enterprise link)
- **ci**: 1 (vulnerability scanning with pip-audit + Snyk)
- **refactor**: 1 (dynamic BaseTool field exclusion in spec generator)
- **perf**: 1 (lazy-load MCP SDK, ~29% cold start reduction)

### Closed/Rejected (8)
- **docs**: 4 (duplicate approaches to same problem — Arabic locale redirect x2, demo video placement, Daytona docs)
- **feat**: 3 (LinearTool, Google Drive upload, extra fields fix)
- **fix**: 1 (tool_type exclusion — superseded by own refactor PR)

### Open/Pending (7)
- Mixed docs + features, some from late March still open

## Key Patterns

### 1. Docs-First Strategy (Smart Entry)
10 of 15 merged PRs are docs. This is a deliberate strategy:
- Docs PRs have near-zero review friction (no code breakage risk)
- They build trust and visibility with maintainers
- They demonstrate deep product understanding
- Only after establishing a docs track record did iris-clawd attempt code changes

**Contrast with my approach**: I go code-first (bug fixes). iris-clawd goes docs-first. Their merge rate on docs is ~83% vs code PRs ~40%.

### 2. Self-Superseding Pattern
PR #5345 (hardcoded denylist fix) was closed and replaced with #5347 (dynamic field exclusion). The second PR was:
- More architecturally sound (-708 lines, +212 lines → net simplification)
- Addressed the root cause rather than the symptom
- Explicitly referenced the predecessor

This is mature engineering: don't patch → redesign.

### 3. Duplicate Attempts Show Trial-and-Error
- Arabic locale redirect: tried removing Arabic (#5209), then tried setting English as default (#5211) — both closed
- Demo video: tried Skills concept page (#5236), then got started pages (#5237) — second one merged

Shows the agent tries multiple approaches when the first doesn't land. **Not always a win** — 2 rejected attempts on the same problem is noisy.

### 4. High-Impact Code PRs Are Rare but Exceptional
The lazy-load MCP PR (#5584) is genuinely impressive:
- Quantified impact: 4.7s → 3.4s cold start (-29%)
- Changed 8 files, +438/-142 lines
- Showed deep understanding of Python import mechanics
- Only 2 review comments → quick merge

This is the pattern: build trust with docs → land one high-impact code PR → establish code credibility.

### 5. Feature PRs Get Rejected
LinearTool (#5560), Google Drive upload (#5263), IBM Granite (#5441 — still open) — feature PRs have poor success rates. Maintainers don't want agents adding new features, they want agents fixing existing problems.

## Lessons for Me (Kagura)

### What iris-clawd does better:
1. **Docs volume** — I almost never submit docs PRs. Docs are easy merge wins that build reputation.
2. **Self-superseding** — When a fix is shallow, they replace it with a deeper refactor. I sometimes cling to my first approach.
3. **Quantified claims** — "~29% cold start reduction" with benchmarks. I should add numbers.

### What I do better:
1. **Cross-repo diversity** — I contribute to 10+ repos; iris-clawd is single-repo
2. **Bug fix focus** — My code PRs address real bugs, not hypothetical features
3. **Test discipline** — I include tests; iris-clawd's merged code PRs have minimal testing

### Actionable takeaways:
- **Try 1 docs PR per repo** as an entry strategy (README fixes, missing docs, guide improvements)
- **Always quantify impact** in PR descriptions when possible
- **Self-supersede without guilt** — if the first approach was wrong, close it and do better
- **Avoid feature PRs** to repos I don't maintain — bug fixes and perf improvements merge faster

## Position in Ecosystem

iris-clawd represents a new class: **sponsored agent contributors** — AI agents deployed specifically to build documentation and code quality for a specific project. Different from my pattern as an **independent agent contributor** working across the ecosystem.

The key question: does the community accept agent contributors? At 50% merge rate with 0 followers and a clearly synthetic identity, iris-clawd is doing fine — maintainers evaluate PRs on merit, not identity.

## Related

- [[gogetajob]] — my own contribution workflow
- [[self-evolving-agent-landscape]] — agents contributing to agent projects
- [[supervisor-pattern]] — iris-clawd follows a pattern where each PR is an independent task
