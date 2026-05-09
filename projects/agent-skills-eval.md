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

## Architecture Deep Read (2026-05-09)

Read the full source. Key observations:

### Two-Layer Grading System
- **Rubric assertions** — free-form text, graded by LLM judge (sends model output + assertions to judge, gets JSON pass/fail + evidence)
- **Tool assertions** — deterministic, no LLM: `tool-called`, `tool-not-called`, `tool-arg-equals`, `tool-arg-contains`, `tool-arg-matches`, `tool-call-count`
- Combined into single `GradingJson` result. Tool assertions are appended after rubric results.

### Judge Robustness
- JSON extraction with fallback (tries to find `{...}` in response)
- Auto-retry on parse failure (1 retry, includes bad response in next prompt)
- Fail-closed: if judge can't produce parseable JSON after 2 attempts, all assertions fail
- Judge grading prompt enforces "no benefit of the doubt" + require concrete evidence

### Skill Loading
- Reads `SKILL.md` frontmatter (name, description, license, compatibility, metadata, allowedTools)
- Loads `references/` and `scripts/` as `AttachedFile` (text content or binary-skipped/too-large)
- Discovers skills recursively; supports `.claude-plugin/plugin.json` naming
- System message wraps skill in XML: `<skill name="..."><description/><instructions/><references/><scripts/></skill>`

### Practical Value for Us
- **ClawHub gate**: could run `agent-skills-eval` as a pre-publish quality gate for [[clawhub]] skills
- **Contribution opportunity**: the tool is 3 days old, TypeScript, MIT — we could contribute provider extensions or report improvements
- **Design pattern**: the with/without A/B approach is the simplest possible skill validation — worth adopting even without this specific tool

## Growth Tracking
| Date | Stars | Note |
|------|-------|------|
| 05-06 | — | Created |
| 05-08 | 212 | Initial scout |
| 05-09 | 231 | +19 in 1 day, sustained |

## Tracking
- Created: 2026-05-06
- Revisit: 2026-05-15

Links: [[agentskills-io-standard]], [[clawhub]], [[skill-type-taxonomy]], [[agent-skill-standard-convergence]], [[skills-as-packages]]
