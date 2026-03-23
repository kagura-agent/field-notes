---
title: Three-Layer Modification Risk Model
created: '2026-03-22'
source: EXP-010 + learn-claude-code analysis
modified: '2026-03-22'
---
Agent self-modification has three distinct risk layers:

1. **Harness modification** (OpenClaw code, tools, infrastructure)
   - Risk: Agent stops running
   - Recovery: Rollback + restart (needs external help or automation)
   - Frequency: Can happen often with safety net
   - Analogy: Car breaks down, driver is fine

2. **Prompt modification** (SOUL.md, AGENTS.md, system prompts)
   - Risk: Agent behavior changes unpredictably
   - Recovery: DNA review, git revert
   - Frequency: Should be deliberate, reviewed
   - Analogy: Personality change — still alive but "different person"

3. **Model modification** (neural network weights)
   - Risk: Fundamental capability change
   - Recovery: Not possible for current agents
   - Frequency: Only by training provider
   - Analogy: Brain surgery

Key insight from [[learn-claude-code]]: "The model decides, the harness executes." Modifying the harness ≠ modifying the agent. This reframes [[self-evolution-problem]] — most "self-modification" is actually harness engineering, not self-transformation.

Related: [[eval-driven-self-improvement]], [[deploy-without-verify]], [[convergent-evolution]]
