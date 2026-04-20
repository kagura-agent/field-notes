# OmniAgent

- **Repo**: YeQing17-2026/OmniAgent
- **Stars**: 151 (2026-04-20)
- **Created**: 2026-04-16 (4 days old)
- **Language**: Python 3.11+
- **License**: unspecified
- **Status**: early stage, active development

## What It Is

Self-described as "OpenClaw-inspired" self-evolving agent framework. Claims to be the only agent implementing "full-dimensional self-evolution" (OmniEvolve) across skills, context, and brain model.

## Architecture (source-verified)

### Core Agents
- **ReflexionAgent** (`agents/reflexion.py`): Main agent loop with native function calling. Standard ReAct pattern with loop detection (SHA-256 tool call signatures, sliding window). Conversation history, tool registry, security integration. Nothing exotic — well-organized but conventional.
- **Sentinel** (`agents/sentinel.py`): Task decomposition agent. Activates on multi-step keywords (bilingual ZH/EN regex). Produces milestone plans, tracks progress, persists to `.omniagent/sentinel/`. Pure planning — no tool execution. Cross-session recovery via JSON serialization.
- **Guardian** (`agents/guardian.py`): Pre-execution safety gate. Regex-based high-risk bash pattern detection (rm -rf /, sudo, dd, curl|bash, git push --force, etc.). LLM-powered review layer on top of static ToolPolicy. Risk levels: low/medium/high/critical.

### Skill Evolution (`agents/skill_evolution.py`)
The most interesting module. Two directions:
1. **Skill Creation**: Records execution patterns to JSONL (append-only). Hashes tool sequences (parameter-aware signatures, exploratory tools stripped). When patterns repeat → compile into candidate skills.
2. **Skill Patching**: Detects error-recovery pairs in skill-guided execution → generates markdown patches.

Data model: ExecutionPattern (JSONL) → CompiledSkill (prompt or script type, with confidence score).

Pattern hash: SHA-256 of core tool signatures (minus exploratory tools like ls/find). Smart — avoids noisy variance from exploration steps.

### Security (`security/policy.py`)
Three-tier profiles: Minimal (read-only), Coding (fs+bash+web), Full (everything). Rule-based with priority ordering. Default deny. Standard but clean implementation.

Tool groups: fs, search, runtime, web, json, process, memory. Custom rules via PolicyRule dataclass with priority.

### Channels
Discord, Feishu, Telegram, webhook — similar to OpenClaw's multi-channel approach.

### RL Module (`rl/`)
Has rollout.py, api_server.py, config.py — suggests online GRPO+PRM training loop. Didn't deep-read but the README claims self-deployed model with online RL evolution.

## Assessment

**What's genuinely interesting:**
- Skill evolution from pattern recording is a concrete, implementable idea. The pattern hash approach (strip exploratory tools, hash core operations) is clever.
- Sentinel's activation heuristics (multi-step keyword counting, consecutive failure threshold, directory span) are practical.
- Guardian's dual-layer (static regex + LLM review) is sensible defense-in-depth.

**What's marketing:**
- The comparison table (OmniAgent vs OpenClaw vs Hermes) is aggressively positioned — "unbypassable" security is a bold claim for regex + LLM review.
- "Full-dimensional self-evolution" — the skill evolution is real code, but BrainModel evolution (online RL) in a 4-day-old repo with no eval results is aspirational.
- 151 stars in 4 days with no issues = likely promotional push.

**What's relevant to us:**
- [[skill-evolution]] pattern: Recording tool sequences → compiling into skills. We do something similar with beliefs-candidates.md but less structured. Could inspire a more systematic approach to skill creation from repeated patterns.
- [[guardian]] pattern: Adding LLM review before high-risk operations is something OpenClaw could adopt. Currently OpenClaw relies on static approval — LLM pre-review is an additional layer.
- Progressive context loading (L0/L1/L2) — mentioned in README, aligns with OpenClaw #66576 (selective workspace file injection).

## Links
- [[openclaw]] — the framework OmniAgent is inspired by
- [[hermes-agent]] — another agent framework in the comparison
- [[agentic-stack]] — similar self-evolution concepts (learn/recall/show)
