# Skill-Plus — Compilable Skill Packages for Content Agents

**Repo:** https://github.com/eight-acres-lab/skillplus (⭐242, 2026-05-11)
**Language:** TypeScript/Node.js
**Latest:** npm `@e8s/skillplus`, 9 skills (2026-05-10)
**Status:** Active daily commits, steady growth (+12% since 05-10)

## What It Does
Compilable skill package system for content-generation agents. A skill is a YAML + Markdown directory that a **deterministic compiler** (no LLM calls) turns into multiple target formats:

- `openmelon` — structured JSON for their [[openmelon]] runtime
- `skill-md` — portable markdown for Claude Code / Cursor / any agent
- `prompt-bundle` — vendor-specific prompt packages
- `eval` — evaluation checklists
- `provenance` — attribution templates

## Architecture
```
skillplus.yaml + .search + prompts/ + schema/ + eval/
    ↓ (deterministic compile, no model calls)
Target format (openmelon JSON / skill.md / prompt-bundle / eval / provenance)
```

Key design: **compiler ≠ runtime**. Compiler handles format transformation; runtime (OpenMelon or other) handles model calls.

## Current Skill Catalog (8 skills)
All focused on **CN social media content generation**:

| Skill | Domain |
|---|---|
| `food-street-realism` | 探店/Xiaohongshu food posts |
| `travel-street-realism` | Travel photo prompts |
| `avatar-portrait-realism` | Realistic portrait image prompts |
| `product-detail-shot` | E-commerce product photos |
| `brand-logo` | Flat-vector brand logos |
| `post-caption-xiaohongshu` | 小红书 copywriting |
| `post-caption-douyin` | 抖音口播文案 |
| `story-thread-weibo` | 微博故事串 |
| `cs-player-card` | CS player card design (added 05-10) |

## Comparison to [[ClawHub]]
- ClawHub: agent **behavioral** skills (tools, workflows, automation)
- Skill-Plus: agent **content generation** skills (image prompts, copywriting)
- Different niches entirely. Skill-Plus is closer to prompt template libraries than to agent skill systems
- Skill-Plus compile targets are interesting: `skill-md` output means any Claude Code user can `npx skillplus <id> --target skill-md > .claude/skills/foo.md`

## Comparison to [[library-skills]]
- library-skills ([[tiangolo]]): library-embedded skills, auto-updated via symlinks, focused on coding assistance
- Skill-Plus: standalone skill packages, focused on content creation
- Both use `.agents/` or `.claude/skills/` as install targets
- library-skills is library-version-aware; Skill-Plus is standalone

## Interesting Ideas
- **Multi-target compilation**: One source, many outputs. Good for ecosystem portability
- **CN social media niche**: Underserved market, practical use case
- **Deterministic compiler**: No LLM in the build step = reproducible, testable
- **model-profile system**: Skills can specify different prompts for different model families (gpt-image-family vs generic-image-model)

## Relevance to Us
- The multi-target compile approach could inform [[ClawHub]] if we ever need format portability
- CN social media content niche is far from our focus but validates that agent skills extend beyond coding
- The `skill-md` target means these skills are immediately usable with OpenClaw's Claude Code integration
