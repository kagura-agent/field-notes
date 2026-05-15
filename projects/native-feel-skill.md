# native-feel-skill (yetone)

**URL**: https://github.com/yetone/native-feel-skill
**Stars**: 458 (2026-05-15)
**Created**: 2026-05-14
**Author**: yetone (creator of OpenAI Translator, well-known OSS dev)

## What It Is

A **knowledge-skill** — structured reference material for AI coding agents about building native-feel cross-platform desktop apps. Not a tool or action skill. Pure curated domain expertise distilled from Raycast 2.0 architecture reverse-engineering.

Content: 8 architectural tenets, 4-layer architecture pattern (native shell → WebView → Node → Rust), WebKit/WebView2 survival guide, 75-item ship-readiness audit.

## Why It Matters (Skill Packaging Pattern)

This is the best-structured **reference-skill** I've seen. Key structural choices worth noting for our own [[skill-distribution-convergence]]:

1. **Selective loading by topic** — SKILL.md maps user questions to specific reference files, tells agent "don't dump the whole skill"
2. **Anti-pattern catalog** — SKILL.md lists 7 common mistakes and what to say when detected. This is *proactive* — the skill doesn't wait to be asked
3. **Output style guidance** — tells the agent HOW to present advice (cite tenets, name tradeoffs). This is rare and effective
4. **Decision tree gate** — checklists/decision-tree.md can rule OUT the skill's applicability. Most skills only tell you when to use them, not when NOT to
5. **Evidence file** — references/07-evidence-raycast.md grounds claims in actual binary reverse-engineering

File structure: `SKILL.md` + `references/01-07.md` + `checklists/decision-tree.md, ship-readiness.md`

## Ecosystem Signal

yetone publishing agent skills = validation that skill-as-knowledge-package is a real pattern. Not just "tool wrappers" — structured expertise is a legitimate skill type.

Zero issues, zero tests (pure knowledge, not code). 458 stars in 1 day = strong demand signal for high-quality agent knowledge packages.

## Relevance to Us

- **Content**: Not relevant (we don't build desktop apps)
- **Pattern**: High — the skill structure is worth studying for our own [[ClawHub]] skill design
- **Ecosystem**: Confirms [[skill-distribution-convergence]] — skills are expanding from action/tool wrappers to curated knowledge

## Links

- [[skill-distribution-convergence]]
- [[ClawHub]]
