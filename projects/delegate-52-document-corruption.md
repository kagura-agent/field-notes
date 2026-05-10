# DELEGATE-52: LLMs Corrupt Your Documents When You Delegate

- **Source**: [arXiv:2604.15597](https://arxiv.org/abs/2604.15597) (Microsoft Research, April 2026)
- **Authors**: Philippe Laban, Tobias Schnabel, Jennifer Neville
- **Found**: HN front page (350pts), 2026-05-10
- **Category**: Agent Trust / Delegation Reliability

## What It Is

A benchmark testing 19 LLMs on document editing fidelity across 52 professional domains (coding, crystallography, music notation, accounting, etc.). Uses **backtranslation round-trips**: edit forward → edit backward → measure drift from original. No human annotation needed — perfect model = zero drift.

310 work environments, each with real documents (~15k tokens), 5-10 complex editing tasks, and distractor files.

## Key Findings

1. **Frontier models corrupt 25% of content** after 20 delegated interactions (Claude 4.6 Opus, GPT 5.4, Gemini 3.1 Pro). Average across all models: **50% degradation**.
2. **Python is the only "ready" domain** (≥98% fidelity after 20 interactions). 51 of 52 domains fail.
3. Errors are **sparse but severe** — silently compound over long interactions. This is worse than frequent-but-obvious errors.
4. **Agentic harnesses don't fix it** — wrapping LLMs in agent frameworks doesn't improve fidelity.
5. **Distractor context worsens it** — realistic noise increases corruption.
6. **Short evals underestimate** the problem — 2-interaction performance doesn't predict 20-interaction performance.
7. Domain gap: programmatic formats (Python, Database) >> natural language and niche domains (music notation, earning statements).

## Architecture Insight: Backtranslation as Eval

The round-trip relay method is clever:
- Define reversible edit pairs (forward + backward instruction)
- Chain N round-trips sequentially
- Measure reconstruction score RS@k = sim(original, result_after_k_interactions)
- Domain-specific similarity functions (not generic text similarity — these are custom parsers per domain)

This is a **general-purpose fidelity evaluation pattern** — could be adapted to test any agent's edit quality without reference solutions.

## Connection to Our Direction

### Validates Our Verification Discipline
Our AGENTS.md "验证纪律" principle ("不验证不声称") isn't paranoia — it's engineering necessity. Every agent edit silently degrades the target. The finding that agentic harnesses don't help means you can't solve this at the framework level; verification must be **per-edit**.

### Diff-Based Editing as Mitigation
The paper tests whole-file editing. Tools like `edit` (exact text replacement) have smaller corruption surface area than "rewrite the whole file." [[mechanism-vs-evolution]] — the mechanism (diff-based edit) matters more than the evolution (better prompting).

### Long-Horizon Agent Work Is the Danger Zone
20 interactions = 25% corruption. Our workloops, PRs, and multi-step workflows are exactly this. Every `flowforge` run, every `gogetajob` contribution cycle is a long-horizon delegation.

### Compounding Degradation = [[self-improving]] Blocker
If an agent edits its own skill files or DNA and introduces silent corruption, the compounding effect means the agent *gets worse over time while thinking it's improving*. This is the most dangerous implication for [[self-evolving-agent-landscape]].

### "Python Is Ready, Nothing Else Is"
Why? Because code has structure, tests, and tooling that provide external verification loops. This is exactly why our "打工 PR 必须测试" rule works — tests catch corruption that humans miss. Domains without test infrastructure are flying blind.

## Unanswered Questions

- Does Chain-of-Thought / step-by-step reasoning help?
- Does providing the diff format (instead of full file rewrite) reduce corruption?
- How does checkpoint/rollback architecture (like [[re_gent]] VCS for agents) change the degradation curve?
- Would a "verify before commit" agent loop (edit → verify → retry if corrupted) flatten the curve?

## Related

- [[agent-brain-portability]] — corruption risk when migrating agent state
- [[existence-encoding]] — Photo-agents' "no execution no memory" might be a response to corruption risk
- [[self-evolving-agent-landscape]] — self-edit is the highest-risk delegation
- [[mechanism-vs-evolution]] — structured editing mechanisms beat evolutionary prompting for fidelity
