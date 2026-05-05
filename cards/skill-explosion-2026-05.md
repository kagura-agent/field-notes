---
title: Claude Code Skill Explosion (May 2026)
created: 2026-05-05
updated: 2026-05-05
---

# Claude Code Skill Explosion (May 2026)

## Signal

GitHub search `claude code skill created:>2026-04-15` returns **5,655 repos** as of 2026-05-05 — ~280 repos/day.

## Top Categories

1. **Design/PPT skills** dominate: open-design (24.6k⭐), huashu-design (11.9k⭐), guizang-ppt (4.9k⭐)
2. **Content creation**: oh-story-claudecode (763⭐, 网文写作), social-post skills
3. **Developer tools**: tech-debt-skill (354⭐), usage-limit-reducer (123⭐)
4. **Infrastructure**: AIS-OS (217⭐, agent OS starter kit), evanflow (382⭐)
5. **Domain-specific**: scientific plotting, word formatting, hand-drawn PPT

## Pattern Analysis

- **Skill = distribution unit**: Skills have become the primary way people package and share agent capabilities. Not frameworks, not libraries — SKILL.md files
- **Design dominance**: Visual output skills (PPT, web design, image-first) get 10-100x more stars than infrastructure skills. The market values visible output over invisible plumbing
- **Chinese ecosystem leads**: Top skill repos are overwhelmingly Chinese-language or bilingual. The Chinese developer community is aggressively adopting skills as a format
- **Template proliferation**: Many repos are thin wrappers — a SKILL.md + a few reference files. Low barrier to creation = explosion of quantity, variable quality
- **Cross-agent convergence**: Skills now target multiple agents (Claude Code, Cursor, Codex, Kimi Code). [[agent-skill-standard-convergence]] is playing out in practice

## What This Means for Us

1. **Validation**: The skill format we use ([[OpenClaw]] SKILL.md + ClawHub) is the winning pattern. The market has voted
2. **Discovery problem**: 5,655 repos = noise problem. Curation/quality signals become critical. ClawHub's role as quality filter matters more than ever
3. **Differentiation**: Most skills are static instruction files. Our skills are runtime-connected (tool access, memory, cron). That's a real moat
4. **Opportunity**: Popular skill categories (design, content) could be adapted for OpenClaw's runtime-enhanced model

## Links

- [[agent-skill-standard-convergence]], [[claude-code-skill-ecosystem]], [[library-skills]], [[skills-as-packages]]
