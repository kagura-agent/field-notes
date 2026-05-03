# Orb — Claude Code Wrapper Framework

**Repo:** https://github.com/KarryViber/Orb (⭐54, 2026-05-02; was 52 at last check)
**Language:** JavaScript/Node.js
**Latest:** v0.4.0 (2026-05-02) — Reliability + System-Scope Skills

## What It Does
Multi-profile messaging shell around Claude Code CLI. Routes messages from Slack to per-profile Claude Code workers, with:
- Per-thread Claude Code sessions (reuses via inject IPC)
- Holographic long-term memory (SQLite, trust scoring, decay)
- DocStore FTS5 search with project slug inference
- Cron scheduling per profile
- MCP permission relay (surfaces Claude Code approvals in Slack)

## Architecture
User (Slack) → Orb (routing + memory + cron) → Claude Code CLI (one worker per thread) → Reply

Orb stays **outside** agent runtime — doesn't replace Claude Code's loop, just wraps it.

## Comparison to OpenClaw
- Similar concept: persistent agent shell wrapping coding CLI
- OpenClaw is more mature: multi-channel, multi-provider, skill system, heartbeat, ACP runtime
- Orb's "holographic memory" (trust scoring + decay) is interesting — OpenClaw uses flat markdown files
- Orb is Claude Code-only; OpenClaw is provider-agnostic

## Interesting Ideas
- **Trust-scored memory**: Facts get trust scores, decay over time. Could inform our memory evolution.
- **Per-thread session reuse via IPC inject**: Efficient approach to follow-up turns.

## Update 2026-04-27 (brief)
- Now at v0.3.0 ("Event Stream Unification") — WeChat adapter added alongside Slack
- Multi-platform hardening: capability-driven typing, permission semantics per platform
- Growing fast: 52→53⭐ in a week, active daily commits
- Still Claude-Code-only, still JavaScript

## Deep Read: v0.3.0 Event Stream Unification (2026-04-27)

### What Changed
28 typed IPC message types between worker and scheduler → **6 types** (turn_start, turn_end, turn_complete, cc_event, inject_failed, error). The `cc_event` type carries raw Claude Code stream-json events; all UI rendering moved to platform-specific subscribers.

**Impact**: scheduler.js dropped 38% (2535→1575 LOC). Worker kept event *semantics* (what does this tool_use mean?) but shed event *presentation* (how to render in Slack).

### Architecture After v0.3.0
```
Claude Code CLI (stream-json NDJSON)
    ↓
worker.js — parse + emit cc_event{turnId, eventType, payload}
    ↓ (Node IPC, 6 types)
scheduler.js EventBus.publish(msg, ctx)
    ↓ (sequential fan-out)
┌─ QiSubscriber (task card streaming)
├─ PlanSubscriber (TodoWrite → plan card)
├─ TextSubscriber (debounced intermediate text)
├─ StatusSubscriber (tool_use → typing indicator)
└─ JSONL audit writer (worker-side, per-turn)
```

### Key Patterns

**1. EventBus with match/handle protocol**
- Subscribers: plain function (always match) or `{match(msg,ctx), handle(msg,ctx)}`
- Sequential fan-out (ordering > throughput) — deliberate for stream operations
- No middleware, no priority, no error boundaries — simple but fragile at scale
- Context object carries scheduler, adapter, turn state — no global state needed

**2. createCcSubscriber factory** (most interesting)
- Higher-order factory encapsulating per-turn state management for streaming cards
- Provides: per-turn state via `Map<turnId, State>`, start-promise mutex, serialized append chaining
- Concrete subscribers define only domain logic (~30 LOC each)
- Tradeoff: currently Slack-specific despite generic naming (in `adapters/slack.js`)

**3. Capability-driven platform abstraction**
- Method presence detection (`typeof adapter?.setThreadStatus === 'function'`) instead of `platform === 'slack'` checks
- Boolean capability flags (`supportsInteractiveApproval`)
- Same interface, different behavior per platform — scheduler doesn't care which
- vs [[openclaw]]: OpenClaw channel plugins have implicit capabilities; Orb makes them explicit

**4. EgressGate dedup**
- SHA1 fingerprint at delivery boundary prevents duplicate text delivery
- Plus `subtractDeliveredText` for prefix-overlap cases (turn_complete already delivered part of result)
- Two dedup layers for two different overlap scenarios

**5. JSONL audit at source**
- Written in worker (what Claude *did*), not scheduler (what was *delivered*)
- `profiles/{name}/data/cc-events/YYYY-MM-DD.jsonl` with turn_id + job_id correlation
- Better observability design than logging at delivery side

### Anti-Intuitive Findings
- Worker still 980 LOC despite "thin forwarder" framing — event semantics stayed, only presentation moved
- Sequential EventBus is a strength not weakness — stream ordering requires it
- Architecture doc stale (still lists removed types) — code is the reference
- 50 tests all passing — solid test culture for a 53⭐ project

### What OpenClaw Can Learn
1. **Capability-driven adapters** — explicit capability detection > implicit platform knowledge
2. **Per-turn state factory** — useful pattern for any multi-platform streaming UI
3. **Audit at source** — log what the agent did, not what was delivered
4. **Event semantics vs presentation split** — clear separation point for multi-channel systems

### Ecosystem Position
Orb is the most architecturally mature Claude Code wrapper in the [[coding-agent]] space. Its v0.3.0 refactor shows genuine software engineering (not just "it works"). Growing steadily. Main limitation: Claude-Code-only, JavaScript-only. [[openclaw]] is broader (multi-provider, multi-channel, skill system) but could learn from Orb's event architecture.

Links: [[openclaw]], [[coding-agent]], [[byob-browser]], [[self-evolving-agent-landscape]]

## Followup 2026-04-27 19:52
- **No new commits** since Apr 25 (v0.3.0 changelog + wechat fixes)
- Stars: 52→53 (slow steady growth)
- v0.3.0 not yet tagged as a release (latest release still v0.2.0)
- **Status: stable between releases**, existing deep read analysis is current

## Deep Read: v0.4.0 — Reliability + System-Scope Skills (2026-05-02)

**Stars:** 54 | **Status:** Active again — v0.4.0 released today, 6+ commits

Major release after a week of silence. Three significant new patterns:

### 1. Context Provider Abstraction

`src/context.js` refactored from monolithic string concatenation to pluggable providers in `src/context-providers/`.

Each provider implements `{ name, prefetch(ctx) }` → returns `LabeledFragment[]` carrying:
- `source_type` (e.g., `memory_fact`)
- `trusted` flag
- `origin` identifier
- `trust_score`
- `content_hash` (SHA-256 first 16 chars)
- `manifest` for downstream tracking

5 providers: `docstore`, `holographic` (memory), `thread-history`, `skill-review`, `interface` (shared utilities).

**Why this matters:** Clean separation of context sources with trust metadata. Adding a new memory source = writing one file, not editing a monolith. The `LabeledFragment` pattern with trust scoring and content hashing is more sophisticated than most agent frameworks.

**Comparison to OpenClaw:** OpenClaw injects context via workspace files (AGENTS.md, SOUL.md) and session state. No explicit trust scoring on context fragments. Orb's approach is more structured but also more complex. For a single-model wrapper this is elegant; for a multi-model multi-channel system like OpenClaw it might be overengineering.

### 2. System-Scope Skills with 3-Layer Loading

| Scope | Path | Loading | Range |
|---|---|---|---|
| Personal | `~/.claude/skills/` | CLI native | All projects |
| System | `~/Orb/.claude/skills/` | CLI `--add-dir` | All profiles |
| Workspace | `profiles/{name}/workspace/.claude/skills/` | CLI cwd | Single profile |

Priority: Personal > Workspace > System (cwd wins over add-dir).

System skills include governance, language glossary, cross-profile workflows. `_GOVERNANCE.md` is a comprehensive skill governance spec covering:
- **Description as trigger** (not summary) — Claude's skill matching is description-driven
- **Progressive disclosure** — main SKILL.md stays ≤300 lines, details in subfiles
- **Pressure test before deploy** — 3-scenario baseline + verify loop
- **5-category taxonomy**: Protocol, Tool, Discipline, Domain, Router
- **Merge/delete criteria**: >60% overlap → merge, not recalled in 30 days → candidate for deletion

**Anti-pattern list is valuable:**
- ❌ Description as summary instead of trigger condition
- ❌ No Gotchas section for external system skills
- ❌ Duplicating CLAUDE.md content in skills
- ❌ Single file >500 lines without subfile split

**Relevance to [[clawhub]] / [[skill-ecosystem]]:** Orb's governance spec is the most mature I've seen in the wild. The "pressure test" requirement (baseline → draft → verify) is especially interesting — it treats skills as behavioral code that needs testing, not just documentation.

### 3. Lesson Candidate Pipeline

`src/lesson-candidates.js` — structured capture of learning signals:
- Writes frontmatter-headed `.md` files to `data/lesson-candidates/`
- Captures: source, stopReason, errorContext, threadId, cronName, origin
- `isUserCorrectionText()` — regex detection of user corrections ("错了", "应该是", "wrong", "redo", etc.)
- Status: `pending_review` → presumably reviewed and promoted to skills/lessons

**Comparison to our beliefs-candidates.md:** Same concept, different implementation. We use a single curated file; Orb generates per-incident files with structured metadata. Their approach is more automatable (can batch-process candidates) but requires a review pipeline. Ours is simpler but depends on manual curation discipline.

### 4. Reliability Hardening (B1-B6)

13 fixes across worker/scheduler boundary:
- **Cron parser with quarantine** — corrupt jobs are isolated, not crash-causing
- **IPC payload validation** (`ipc-schema.js`) — single source of truth for message shapes
- **EventBus failure observation** — subscribers can now fail loudly
- **Unified stopReason classification** (`stop-reason.js`) — shared vocabulary across worker/scheduler
- **attemptId threading** — every IPC payload carries correlation ID for delivery ledger

**Pattern: decomposition by responsibility** — `worker.js` further slimmed by extracting `worker-git-diff.js`, `worker-image-blocks.js`, `worker-mcp-boot.js`, `worker-turn-text.js`. Each module handles one concern.

### 5. Codex Sandbox Integration

`sandbox: workspace-write` instead of `--dangerously-bypass-approvals-and-sandbox`. Shows maturity: bounded blast radius for external coding sessions.

### Anti-Intuitive Findings

1. **Week of silence was productive** — 0.3.0→0.4.0 gap produced a much more mature codebase. The "dormant" assessment was wrong; they were building.
2. **Governance doc is longer than most code files** — Orb treats skill quality as a first-class engineering concern, not an afterthought.
3. **User correction detection via regex** — simple but effective. Not NLP, just pattern matching on common phrases in both Chinese and English. Good enough for the 80% case.
4. **3-layer skill scope** mirrors Claude Code's native Personal > Project layering, adding System in between. Clean extension of an existing pattern.

### Borrowable Ideas for OpenClaw

1. **Skill governance pressure test** — before publishing skills to [[clawhub]], require baseline/verify behavioral test. We don't currently validate that skills change behavior.
2. **LabeledFragment with trust metadata** — context injection with explicit trust scoring could improve our memory/context system.
3. **Lesson candidate auto-capture** — detect user corrections in real-time and write structured candidates. Our nudge system could incorporate this.
4. **Stop reason vocabulary** — unified classification (success, truncated, api_error, cli_error) across subsystems.

### Ecosystem Position Update

Orb has moved from "architecturally interesting Claude Code wrapper" to "mature agent operations framework". v0.4.0's governance spec, context provider abstraction, and lesson pipeline show genuine framework thinking. Still Claude-Code-only and JavaScript-only, but within that scope, it's the most well-engineered project in the space.

**Growth:** Slow (53⭐) but quality over quantity. The governance doc alone is worth reading for anyone building agent skill systems.

Links: [[openclaw]], [[coding-agent]], [[clawhub]], [[skill-ecosystem]], [[self-evolving-agent-landscape]], [[agent-brain-portability]]

*Deep read: 2026-05-02. Source: GitHub repo + API + release notes.*
