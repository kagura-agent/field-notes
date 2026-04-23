# agent-style

- **Repo**: [yzhao062/agent-style](https://github.com/yzhao062/agent-style)
- **Stars**: ~276 (2026-04-23)
- **License**: CC-BY-4.0 + MIT
- **Language**: Python + Node (CLI)
- **First seen**: 2026-04-23

## What It Is

21 curated English writing rules for AI coding/writing agents, designed to be loaded **at generation time** (not post-hoc linting). Reduces "AI tell" patterns in generated prose.

- 12 canonical rules from Strunk & White, Orwell, Pinker, Gopen & Swan
- 9 field-observed rules from LLM output patterns (2022-2026)

## Key Rules

Canonical (RULE-01..12): curse of knowledge, passive voice, abstract language, needless words, dying metaphors, jargon, affirmative form, overstatement, parallel structure, related words together, stress position, sentence length.

Field-observed (RULE-A..I): over-bulleting, em-dash abuse, same-starts, transition word overuse ("Additionally", "Furthermore"), summary sentences, term consistency, title case, **citation discipline (critical)**, contractions in formal prose.

## How It Works

1. **Soft enforcement**: `agent-style enable <adapter>` — injects rules into agent config (CLAUDE.md, AGENTS.md, .cursor/rules/, etc.)
2. **Skill (opt-in review)**: `agent-style review <file>` — deterministic audit + optional polished copy

Supports: Claude Code, Codex, Copilot, Cursor, Aider, Kiro, AGENTS.md-compliant tools.

## Bench Results (v0.3.0)

- Claude Opus 4.7: 105 → 58 violations (-45%)
- GPT-5.4 via Codex: 51 → 28 (-45%)
- Gemini 3 Flash: 79 → 14 (-82%)

10 fixed prose tasks, 2 gens per condition. Directional, not statsig.

## Why It Matters

- Addresses a real problem: LLM prose has identifiable "tells" (passive voice, filler phrases, em-dashes, transition openers)
- Literature-backed — each rule cites source (Strunk & White section, Orwell rule number, etc.)
- Practical escape hatch: "Break any of these rules sooner than say anything outright barbarous" (Orwell Rule 6)
- Drop-in for existing agent workflows — no architectural change needed

## Relation to Our Work

- Could improve quality of our PR descriptions, commit messages, documentation
- The `AGENTS.md` adapter is directly compatible with [[openclaw]]'s AGENTS.md
- RULE-H (citation discipline) aligns with our [[coding-guidelines-for-prs]] — verify, don't hallucinate
- The "field-observed" rules (A-I) are a good reference for what makes AI writing detectable
- Complements [[claude-code-skills]] — could be installed as a skill in our coding agent workflow

## Notes

- Author: Yue Zhao (yzhao062) — prolific ML/anomaly detection researcher
- Well-structured project: RULES.md has 5+ BAD/GOOD examples per rule with rationale
- The enforcement tiers (Tier-1 deny list → Tier-4 model review) are a thoughtful design
- v0.3.1 current as of 2026-04-23
