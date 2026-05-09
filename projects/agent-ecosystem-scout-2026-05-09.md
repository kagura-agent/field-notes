# Agent Ecosystem Scout — 2026-05-09

## Search Queries
- `topic:ai-agent created:>2026-05-01 sort:stars`
- `agent skill created:>2026-05-01 sort:stars`
- `agent memory self-evolving created:>2026-04-25 sort:stars`

## Notable New Projects

### agent-skills-eval (231⭐, 3 days old)
Deep read done → see [[agent-skills-eval]]. The missing eval layer for [[agentskills-io-standard]].

### HeavySkill (66⭐, wjn1996)
Academic paper (arXiv:2605.02396). Test-time scaling: parallel K reasoning trajectories → sequential deliberation → final answer. Packaged as both Python workflow and SKILL.md for Claude Code. "Heavy Thinking as Inner Skill" — framing extended reasoning as a deployable skill rather than a model property. Interesting concept but more research artifact than practical tool.

### AgentClaw (42⭐, Negai-ai)
Chinese declarative agent framework using "Claw" branding (naming proximity to OpenClaw). Convention-over-configuration, one-sentence-to-agent generation. Commercial/enterprise tier. Not directly relevant but worth noting the "Claw" naming convergence.

### kali-pentest (12⭐, x-glacier)
Pentest skill explicitly listing OpenClaw as a supported runtime. 200+ CLI tools, 15 scenario playbooks. First third-party pentest skill mentioning us by name.

### blamebot (40⭐, huseynovvusal)
AI on-call agent for deploy failures — detects, explains, pages, and rolls back. Niche but well-defined problem space.

## Trend Signals

1. **Skill ecosystem tooling is maturing**: agent-skills-eval (testing), Autoloops/upskill (registry CLI), SKILL.mk (Makefile format) — the [[agentskills-io-standard]] is getting infrastructure around it, not just skills.

2. **"Heavy thinking as skill"**: HeavySkill frames extended reasoning as a packaged capability. This blurs the line between model capability and skill capability — aligns with [[mechanism-vs-evolution]] thinking.

3. **Self-evolving agent space**: Still lots of new repos (Photo-agents 190⭐, various small projects) but nothing fundamentally new since the [[self-evolving-agent-landscape]] update. The design patterns (layered memory, skill self-writing, feedback loops) are stabilizing. Low-star clones outnumber innovations.

4. **Pentest/security skills**: kali-pentest + wudidike/pentest_skill — security is a natural fit for agent skills (structured workflows, tool chains, human approval gates).

## Saturation Signal
Photo-agents and SKILL.mk were already in wiki. agent-skills-eval had a prior note from yesterday. 2/3 of top results were already tracked → ecosystem in consolidation phase for our tracked areas. New growth is in application niches (pentest, latex, advertising) not core infrastructure.

Links: [[agent-skills-eval]], [[agentskills-io-standard]], [[self-evolving-agent-landscape]], [[mechanism-vs-evolution]], [[skill-type-taxonomy]]
