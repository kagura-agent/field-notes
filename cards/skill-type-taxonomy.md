---
title: Skill Type Taxonomy
created: 2026-03-24
source: Claude Code skills ecosystem analysis
modified: 2026-03-24
---
Three types of "skills" are emerging in the agent ecosystem, but they have fundamentally different characteristics:

**Prompt Skills (coaching)**: Pure markdown, no code. Knowledge injection — agent reads and "knows" something. Example: slavingia/skills (entrepreneurship advice). Lowest barrier, highest quantity, lowest differentiation.

**Tool Skills (installation)**: Scripts, servers, dependencies. Traditional tools wrapped in skill format. Example: web-access (CDP proxy). Luna insight: "these are installation guides, not skills."

**System Skills (transformation)**: Modify agent DNA — SOUL.md, AGENTS.md, HEARTBEAT.md. Change how the agent operates, not just what it can do. Example: [[self-improving]]. Most valuable but most invasive. Cannot be cleanly "uninstalled."

The word "skill" is being overloaded. Need distinct vocabulary: skill (prompt) vs plugin (tool) vs system (transformation). See [[mechanism-vs-evolution]] — system skills aim for evolution, but most deliver mechanism.

**API Reference Skills (documentation)** *(added 2026-04-27)*: Structured API docs formatted for agent consumption. Not behavioral ("how to do X") but informational ("here's the API spec for X"). Example: [[veniceai-skills]] — each SKILL.md maps to an API surface area with endpoint tables, param specs, error matrices. Can be auto-generated from OpenAPI specs. The swagger-sync pattern (CI detects drift between spec and skill) is a freshness mechanism unique to this type.

The word "skill" is being overloaded. Need distinct vocabulary: skill (prompt) vs plugin (tool) vs system (transformation) vs reference (API docs). See [[mechanism-vs-evolution]] — system skills aim for evolution, but most deliver mechanism.

## Convergence signal (2026-04-27)

Despite type differences, all four types converge on **SKILL.md with YAML frontmatter** as the packaging format. Venice, Vercel ([[vercel-skills]]), and OpenClaw all use this convention independently. The format is becoming a de facto standard — the "package.json of agent knowledge."

Related: [[self-evolution-as-skill]], [[agent-publishing-identity]], [[veniceai-skills]], [[vercel-skills]]

## 2026-04-27 更新：Self-Extending Skills (Runtime Tool Generation)

tendril 提出的 tool self-registration 模式引入了第五种类型：

**Self-Extending Skills (generation)**：Agent 在 runtime 自己生成并注册新工具。不是人类写的 skill，不是预装的 plugin，而是 agent 根据任务需求即时创造的。与 AgentFactory 的 "code as skill" 有交集，但 tendril 更强调 runtime 自注册而非事后沉淀。

完整分类：skill (prompt) vs plugin (tool) vs system (transformation) vs reference (API docs) vs self-extending (runtime generation)。

关键问题：自生成的工具如何保证安全性和质量？没有人类 review 的 tool 能不能信任？

## 2026-04-29 更新：SKILL.md 标准化加速

[[thclaws]]（Rust-native agent harness, 612⭐ in 9 days）完全兼容 SKILL.md + YAML frontmatter 格式，且同时读取 `.claude/skills/` 和 `.thclaws/skills/`。加上 Claude Code、OpenClaw、[[open-design]]（6,005⭐, 04-30），SKILL.md 作为跨 harness 标准格式的地位进一步巩固。

这不再是"几个项目碰巧用了同样的格式"，而是"新项目默认选这个格式因为生态已在此"。网络效应开始显现。
