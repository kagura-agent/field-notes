# garden-skills — Field Notes

> ConardLi/garden-skills | 2,842★ (2026-05-09, was 2,396 on 05-06, +19% in 3d) | Skill Collection | First noted in [[skill-ecosystem]]

## What It Is

Curated multi-skill collection with release infrastructure. 4 skills: gpt-image-2, kb-retriever, web-design-engineer, web-video-presentation.

## Why It Matters

**Fastest-growing skill collection in the ecosystem** — 2,842★, surpassing oh-story-claudecode and agent-sprite-forge. Growth is brand-driven (ConardLi is a well-known CN tech blogger).

## Interesting Aspects

### web-video-presentation (actively developed, v1.1.3)
- Turns articles/scripts into click-driven 16:9 web presentations with optional TTS audio
- Very detailed workflow SKILL.md with mandatory checkpoints (Phase 1 content → user alignment → Phase 2 dev → user acceptance)
- Anti-AI design principles — animations designed per-chapter, not templated
- Outputs: Vite + React + TS project + chapter-split audio
- **Design pattern**: "checkpoint-gated creative workflow" — skill enforces user review at key decisions, preventing runaway generation

### Release Infrastructure
- Automated version bumping, download link sync, validation CI
- `dist/` directory with pre-built packages
- **Signal**: treating skills as publishable software with proper versioning, not just prompt files

### Community
- 🟡 GROWING (score 4/6) — 467 forks but low external PR merge rate (0 merged in 30d, 1 rejected)
- High fork-to-star ratio (16%) suggests people copy & customize rather than contribute back
- Issue #4: Codex-generated "opencli integration" plan — they're exploring CLI distribution

## Compared to Other Skill Collections

| | garden-skills | oh-story-claudecode | skillplus |
|---|---|---|---|
| **Stars** | 2,842 | 901 | 469 |
| **Skills** | 4 (diverse) | 1 (writing) | 8 (CN social media) |
| **Focus** | Design/media tools | 网文 writing | Douyin/Xiaohongshu content |
| **Packaging** | dist/ + CI | Single skill | Compilable packages |
| **Growth driver** | Brand (ConardLi) | Niche utility | Active dev + niche |

## Relation to Our Direction

- Validates [[skill-ecosystem]] thesis: skill collections with release infrastructure attract more users than individual skills
- web-video-presentation's checkpoint-gated workflow is similar to our FlowForge node approach — structured creative workflows with mandatory review points
- Fork-heavy, PR-light community suggests skills are consumed more than contributed to — different from agentic-stack's contribution model

Links: [[skill-ecosystem]], [[oh-story-claudecode]], [[skillplus]]

*First field note: 2026-05-09*
