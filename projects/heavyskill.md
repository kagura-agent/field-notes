---
title: HeavySkill
created: 2026-05-07
updated: 2026-05-07
tags: [test-time-compute, reasoning, skill-format, academic]
---

# HeavySkill

> Heavy Thinking as the Inner Skill in Agentic Harness

**Repo**: [wjn1996/HeavySkill](https://github.com/wjn1996/HeavySkill) — 43⭐ (05-07), arXiv:2605.02396
**License**: None specified
**Created**: 2026-05-02

## What It Is

A test-time scaling technique packaged as both a Python workflow AND an installable Claude Code skill. Two-stage approach:

1. **Parallel Reasoning** — generate K independent reasoning trajectories concurrently
2. **Sequential Deliberation** — synthesize all K trajectories through critical analysis into a superior final answer

Claims to consistently outperform Best-of-N (majority voting). Stronger LLMs approach Pass@N performance through deliberation alone.

## Why It's Interesting

The novel framing: **test-time compute as a portable skill**. Instead of being baked into the model or the harness, the heavy-thinking protocol is a SKILL.md file you can drop into any agent.

This bridges two worlds:
- [[test-time-compute]] research (o1/R1 style)
- [[skills-as-packages]] distribution pattern

The skill format means any agent with Claude Code or similar harness gets "heavier thinking" as an installable capability — no model change needed.

## Architecture

```
Query → [K parallel reasoning trajectories] → [Deliberation synthesis] → Final Answer
```

Scalable via:
- **Width (K)**: number of parallel reasoning paths
- **Depth (iterations)**: iterative deliberation rounds
- Both tunable with RLVR (Reinforcement Learning with Verifiable Rewards)

Supports separate models for reasoning vs deliberation (e.g., R1-distill-7b for reasoning, Qwen3-32b for synthesis).

## Connection to Our World

- [[thin-harness-fat-skills]]: HeavySkill is a fat skill — it extends the agent's cognitive capability, not just its tool access
- [[agent-skill-standard-convergence]]: Another data point that skills are becoming the universal extension point
- Contrast with [[genericagent]]: GenericAgent grows skills through experience; HeavySkill is a manually-crafted meta-cognitive skill
- Potential: Could our agent install this to boost reasoning on hard problems? Would need to evaluate token cost vs quality gain

## Assessment

Small project (43⭐), but the _idea_ is significant. "Thinking harder" becoming an installable module rather than a model property is a directional signal. Watch for: adoption by larger harness projects, benchmark results vs native reasoning models.

Not tracking actively — the paper is the main contribution, repo is just the implementation.
