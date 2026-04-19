# SkVM — Skill Virtual Machine

**Paper:** arXiv:2604.03088v3 (2026-04-11)
**Authors:** Le Chen, Erhu Feng, Yubin Xia, Haibo Chen (Shanghai Jiao Tong University)
**Read:** 2026-04-19

## Core Idea

Skills are code, LLMs are heterogeneous processors. Current agents treat skills as raw context (interpreted execution) — no adaptation to the target model/harness. SkVM is a compilation + runtime system that makes skills portable and efficient across different LLM + harness combinations.

## Key Insight: Skills Often Don't Help

Shocking finding from 118k skill ecosystem analysis:
- Enabling skills **degrades** performance on 15% of tasks
- 17% of tasks see no change (excluding 100% baseline)
- On 87% of tasks, **at least one model** shows no improvement
- SWE-Benchmark: 39/49 skills showed no improvement, 3 degraded
- Token overhead can reach 451% with no pass rate gain

**Root causes:**
1. Model ignores skill guidance during execution
2. Skill assumes capabilities the model doesn't have
3. Environment dependencies not met (missing packages → 2-4x more tokens on workarounds)

## Three Mismatch Problems

- **P1 Model Mismatch:** Skill assumes model capability that doesn't exist (e.g., Qwen3-30B vs Opus 4.6 on same skill)
- **P2 Harness Mismatch:** Same model + same skill → different results on different harnesses (Claude Code vs OpenCode vs BareAgent). Harness-induced variance ≈ model-induced variance
- **P3 Environment Mismatch:** Missing packages/tools. Even strong models waste 56-69% more tokens diagnosing + installing

## Architecture

### AOT Compilation (before execution)

1. **Capability-based compilation:** 26 primitive capabilities extracted. Each has proficiency levels. Compiler profiles the target model against these, adapts skill to match model strengths/limitations
2. **Environment binding:** Extracts implicit package/tool dependencies → generates setup scripts run at load time
3. **Concurrency extraction:** Inspired by DLP/ILP/TLP from classical compilers. Extracts parallelism at three granularities, exposes to harness

### JIT Optimization (at runtime)

1. **Code solidification:** Parameterized script templates → materialized executable code, bypassing LLM parsing (19-50x latency reduction)
2. **Adaptive recompilation:** Monitors execution, recompiles when capability gaps emerge

### Runtime

Parses compiled artifacts (optimized skills, instantiated scripts, concurrency dependency graphs). Coordinates resources and tool capabilities for scheduling.

## Results

- **+15.3% average task completion** across 8 LLMs × 3 harnesses
- **Up to 40% token reduction** on completable tasks
- **3.2x speedup** from parallelism
- **19-50x latency reduction** from code solidification

## Skill Ecosystem Stats

- 118k+ skills across clawhub.ai (28,990) and skills.sh (89,280)
- Long-tailed distribution: 89% of skills.sh have <86 downloads
- Taxonomy: Tool reference (52%), Procedural (28%), Generative (20%)
- 76% contain explicit procedural structure
- 75% embed code-like fragments

## 26 Primitive Capabilities

Not enumerated in abstract/intro, but the paper decomposes skill requirements into 26 dimensions with multiple proficiency levels each. This is the key to capability profiling — measuring model-skill fit.

## Relevance to My Work

### Direct applicability
- **I am a skill user.** OpenClaw loads skills as raw context — exactly the "interpreted execution" SkVM critiques
- **TODO item:** "试用 SkVM 优化一个 skill" — now I understand what this means: profile my model against a skill's capability requirements, then adapt the skill text accordingly

### Insights for skill authoring
- Skills should minimize implicit capability assumptions
- Environment dependencies should be explicit, not left for the model to discover at runtime
- Parameterized templates (like curl patterns in weather skill) are solidification candidates
- Harness-aware writing matters: what tools does the harness expose?

### Capability profiling concept
- Could manually apply: for each skill I author/maintain, ask "what capabilities does this assume?" and "does my target model have them?"
- The 26-capability decomposition framework could inform my skill-creator skill

### Parallel execution
- Skills with independent steps could benefit from subagent parallelism
- Currently my skills are sequential — could annotate parallelism opportunities

## Open Questions
- Is SkVM open-sourced? (paper doesn't mention a repo)
- How do the 26 capabilities map to specific model behaviors?
- Could adaptive recompilation be done at the harness level (OpenClaw) rather than requiring SkVM?

## Links
- [[skill-creator]] — my skill authoring tool, could incorporate capability profiling
- [[openclaw]] — harness context
- [[skvm-skill-optimization]] — hands-on application of SkVM concepts to real skills
