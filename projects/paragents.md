---
title: Paragents — Parallel Agent Sessions with Conflict Detection
repo: FrankHui/paragents
stars: 112
created: 2026-04-29
last_push: 2026-04-30
language: Python
license: none (unlicensed)
scouted: 2026-05-07
---

## What It Is

TUI-first parallel agent runtime. Run up to 4 agent sessions simultaneously with **preflight conflict checks** to prevent output collisions. Inspired by claude-code, hermes-agent, mercury-agent, nanobot.

## Architecture

```
UserInput → Scheduler → SessionPromptQueue → SessionWorker → AgentInstance → Tools+Permissions
                                                                    ↓
                                                          SessionRuntimeState
```

### Key Design Patterns

1. **Preflight Intent Inference** (`preflight_intent.py`)
   - Before executing a prompt, infers what resources it will touch (capabilities, actions, output paths)
   - Uses both regex heuristics AND LLM-assisted inference (`infer_preflight_intent_with_llm`)
   - Each intent has a confidence score (default 0.35)
   - Outputs a resource key set: `perm:git`, `git:commit`, `out:/path/to/file`

2. **Output Path Locking** (`scheduler.py`)
   - Sessions declare output paths via preflight
   - `_output_locks: dict[str, str]` — maps path → session_id
   - Conflict = two sessions want to write same path → approval required
   - `_session_declared_outputs` vs `_session_observed_outputs` — intent vs reality

3. **Permission Tiering** (`permissions.py`)
   - Capabilities: filesystem/shell/python/git/github/web/mcp — each on/off
   - Shell policy: blocked / auto_approved / needs_approval
   - Git policy: status/diff/log auto-approved, add/commit/push needs approval
   - FS scopes: path + read/write granularity

4. **Session State Persistence**
   - JSONL-based state store
   - Checkpoint recovery + compaction engine
   - Session survives prompt boundaries

5. **Hook Runtime** — `.paragents/hooks.json` for lifecycle hooks

## Relevance to OpenClaw

OpenClaw's subagent model already runs parallel sessions, but lacks:
- **Preflight conflict detection** — subagents can step on each other's files
- **Output locking** — no mechanism to prevent two subagents editing same file
- **LLM-assisted intent inference** — could predict what a spawned task will touch

The permission system is simpler than OpenClaw's (which has native approvals + allowlists), but the **conflict prevention** angle is genuinely novel for multi-agent coordinators.

## Deep Read (2026-05-07)

### 3-Layer Conflict Prevention

1. **Intent Layer** (`preflight_intent.py`)
   - Regex heuristics detect git/github/shell/python/filesystem intent from natural language
   - LLM call (`infer_preflight_intent_with_llm`) merges structured JSON output with rule-based detection
   - Confidence scoring: 1 signal → 0.48, 2+ → 0.62, 4+ → 0.82
   - Output paths extracted from `>`, `tee`, `cp`, `mv`, `mkdir` patterns

2. **Policy Layer** (`permissions.py`)
   - Capabilities: filesystem/shell/python/git/github/web/mcp — binary toggles
   - Per-capability tiering: `blocked` / `auto_approved` / `needs_approval`
   - FS scopes: path + read/write granularity

3. **Runtime Layer** (scheduler output locks)
   - `_output_locks: dict[path, session_id]` — file-level mutual exclusion
   - Conflict detection: session B wants `out:reports/result.json` but session A already holds it → decision = "serialize"
   - Locks released on task completion or failure (cleanup in finally block)
   - Non-output conflicts (shared capabilities like `perm:python`) do NOT trigger serialization — only output path collisions do

### Session State Architecture

- JSONL persistence (`JsonlSessionStateStore`)
- State = recent_turns + compact_notes + memory_items + memory_summary + checkpoint
- `DefaultCompactionEngine` — keeps context bounded across turns
- `DefaultCheckpointRecovery` — resume from last checkpoint on crash
- Agent instance reused across turns within a session (not recreated)

### Test Coverage (notable patterns)

- `test_scheduler_output_conflicts.py` — proves only output paths trigger serialization, not shared capabilities
- `test_session_context_continuity.py` — validates state survives across prompt turns
- One session, one active prompt at a time (rejects concurrent prompts in same session)

## Concerns

- No license file — limits contribution/forking
- Single push (04-30), no activity since — may be abandoned
- 112⭐ but unclear growth trajectory (no follow-up commits)
- Preflight regex is naive (misses dynamic output paths, programmatic file creation)

## Lessons

- **Predict-before-execute** is an underexplored pattern in multi-agent systems
- LLM-assisted resource prediction (before execution) could prevent many coordination bugs
- The "declare intent → check conflicts → execute" pattern maps well to team-lead workflows
- Key design choice: **only output paths trigger serialization** — capability overlaps are fine. This avoids over-serializing independent work that happens to use the same tools
- OpenClaw subagents would benefit from declaring output intents before spawning — could prevent git conflicts when multiple subagents edit overlapping files

## Applicability to OpenClaw

Concrete integration points:
1. `sessions_spawn` could accept `output_paths` hints → scheduler checks for conflicts before starting
2. Team-lead skill could use preflight intent inference to detect when two assigned issues touch same files
3. FlowForge parallel nodes could declare outputs for conflict-free scheduling

Links: [[craft-agents-oss]], [[multi-agent-coordination]], [[openclaw]], [[skill-injection-via-hooks]]
