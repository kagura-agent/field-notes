---
tags: [agent-framework, python, skill-system, heartbeat, memory, personality]
status: active
created: 2026-05-13
updated: 2026-05-13
last_verified: 2026-05-13
---

# BuddyMe — Multi-Model Agent Framework with Personality Evolution

Chinese-origin Python agent framework by virgo777. 75⭐ (2026-05-13), created 2026-05-10. No license declared.

## Architecture

- **Three-tier skill loading** (L1 metadata → L2 instructions → L3 resources) — same progressive loading as OpenClaw but explicitly codified
- **Heartbeat system** — `HeartbeatManager` with active hours, task scheduling, JSON config. Pure data layer, execution in `Agent.tick()`
- **Memory system** — Conversation logger with regex-based fact extraction (files, URLs, dates, models). Zero-LLM overhead. Atomic writes, date-keyed JSON, log rotation
- **Brain files** — SOUL.md, AGENT.md, IDENTITY.md, HEARTBEAT.md, USER.md, SUB_AGENT.md — nearly identical naming to OpenClaw workspace files
- **6 LLM providers** — GLM, DeepSeek, ERNIE, Qwen, MiMo, with OpenAI/Anthropic protocol auto-detection
- **Loop engine** — `/loop` command for recurring/scheduled tasks, heartbeat thread polling
- **Skill library** — 25+ skills, JSON index, hot-reload support

## Deep Read Notes (2026-05-13)

### Three-Tier Skill Loader (skill_loader.py, 343 lines)
- **L1**: `get_metadata_prompt()` — all skill name+description injected into system prompt at startup. Includes "must prioritize skills" instruction
- **L2**: `load_instructions()` — strips frontmatter, resolves relative paths to absolute, appends resource path summary
- **L3**: `resolve_reference()` / `get_script_path()` — on-demand file reads from references/scripts/assets subdirs
- **Matching**: `match_skills()` uses keyword overlap scoring (name words ×3, description words ×1). Pure regex, no embedding. `get_matched_instructions()` auto-injects up to 2 matched skill bodies into subtask prompts
- **Hot reload**: `reload()` re-scans directories, reports delta
- **Tradeoff**: Simple but effective. No semantic matching means false negatives on paraphrased requests. But zero external dependencies (no PyYAML, no embeddings)

### Memory System (use_memory.py + memory_extractor.py)
- **Pipeline**: Extract from conversations → deduplicate → score → decay → consolidate
- **Extraction**: LLM-based (not regex) — sends last N days of conversations + target MD section headers to LLM, asks for structured JSON extraction
- **Dedup**: SequenceMatcher similarity ≥ 0.8 → skip. < 0.8 → archive old, write new
- **Scoring**: `relevance×0.4 + importance×0.3 + recency×0.3`. Recency decays linearly over 30 days
- **Decay**: Score < 0.4 → archive. Score < 0.2 → delete
- **Consolidation**: Rule-based merging by keywords (e.g., "上次/曾经/之前" → merge into 历史摘要)
- **History**: JSON sidecar file tracks archives, last_active timestamps, importance scores
- **Key insight**: Memory decay is time-based (30-day linear) not access-based. Our beliefs-candidates system uses manual verification gates instead — different philosophy

### Heartbeat (heartbeat.py)
- Pure data layer — config/task CRUD, time checks, no execution logic
- Execution delegated to Agent.tick() — clean separation of concerns
- JSON-based task storage with active hours, scheduling

### memorybuild.py (Conversation Logger)
- **Regex fact extraction** (zero-LLM): extracts file paths, URLs, dates, model names from conversation text
- Atomic writes, date-keyed JSON, log rotation (100MB, 5 rotates)
- This is the cheap extraction; the expensive LLM extraction is in memory_extractor.py

### Issues & Community
- **Zero issues, zero PRs, zero community** — solo project
- No license — blocks adoption
- 75⭐ in 3 days suggests interest but no stickiness signal yet

## Key Observations

1. **Architecture convergence** — SOUL.md/AGENT.md/HEARTBEAT.md naming near-identical to OpenClaw. Likely direct inspiration (the blog references OpenClaw ecosystem patterns)
2. **Two-layer memory extraction** — cheap regex (memorybuild) for facts + expensive LLM (memory_extractor) for semantic extraction. Smart hybrid
3. **Memory scoring formula** — relevance×0.4 + importance×0.3 + recency×0.3 with linear decay. Simple but principled. Our manual verification gates are more robust but less automated
4. **Skill matching by keyword overlap** — pragmatic, zero-cost, but misses semantic similarity. Works fine for 25 skills, wouldn't scale to 100+
5. **Chinese LLM ecosystem** — GLM 5.1, DeepSeek V4 Pro, ERNIE 5.1, Qwen 3.6 Plus, MiMo V2 Pro. Shows these models now support tool calling well enough for agent frameworks
6. **No license** — dealbreaker for ecosystem adoption

## Relevance to Us

- **Memory decay model**: Their automated scoring+decay vs our manual verification gates represent two valid approaches. Theirs scales better for high-volume agents, ours is safer for high-stakes decisions
- **Two-layer extraction**: Regex for cheap facts + LLM for semantic meaning is a pattern worth considering for our memory pipeline
- **Skill path resolution**: Their `_resolve_inline_paths()` that replaces relative paths in SKILL.md body with absolute paths at load time is a nice UX touch
- Not a competitor (different ecosystem focus, solo project), but validates our architectural direction
- **No contribution opportunity** (no license, no issues, no community engagement)

Links: [[openclaw]], [[skill-type-taxonomy]], [[agent-skill-standard-convergence]]
