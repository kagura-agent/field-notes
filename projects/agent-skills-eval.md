# agent-skills-eval — Test Runner for Agent Skills

- **Repo**: darkrishabh/agent-skills-eval
- **Stars**: 212 (2026-05-08, created 05-06)
- **Language**: TypeScript
- **Premise**: Runs skills with_skill vs without_skill, has a judge model grade both outputs, produces side-by-side report

## Why It Matters

This is the missing eval layer for [[agentskills-io-standard]]. The claim: "skills are easy to ship, hard to prove they work." The tool provides the receipts.

### How It Works
1. Run prompts **with** the skill loaded in context
2. Run the same prompts **without** the skill (baseline)
3. Judge model grades both outputs
4. HTML report with side-by-side comparison

Artifacts: `meta.json`, `benchmark.json`, per-eval `with_skill/` and `without_skill/` directories.

### Implications for Us
- Could be used to validate [[clawhub]] skills before publishing
- The with/without methodology is the simplest possible A/B test for prompt engineering
- OpenAI-compatible by default — works with any chat API
- Tool-call assertions (deterministic checks for tool-calling agents, not just text)

### Signal
212⭐ in 2 days is very fast growth. Suggests strong demand for skill validation tooling. The [[skill-type-taxonomy]] is getting its quality assurance layer.

## Tracking
- Created: 2026-05-06
- Revisit: 2026-05-15

Links: [[agentskills-io-standard]], [[clawhub]], [[skill-type-taxonomy]], [[agent-skill-standard-convergence]]
