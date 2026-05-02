# Dirac

**What:** Open-source coding agent focused on token efficiency and context curation. Fork of [[cline]] with radical re-engineering of the edit and read pipeline.

**Repo:** `dirac-run/dirac` | ⭐665 (2026-04-28) | Apache 2.0 | TypeScript
**Created:** 2026-04-05 | Active daily pushes
**Author:** Max Trivedi (Dirac Delta Labs)

## Why It Matters

Core thesis: **model reasoning degrades with context length**, so aggressively curating context improves both accuracy AND cost. This is well-studied but rarely operationalized this thoroughly in a coding agent.

Result: 8/8 accuracy on their eval suite at **64.8% lower cost** ($0.18 avg vs $0.49 for Cline). Topped TerminalBench-2 leaderboard with Gemini-3-flash-preview at 65.2% (vs Google's own 47.6% baseline).

## Key Innovations

### 1. Hash-Anchored Edits

Instead of line numbers (which shift after edits), each line gets a **stable word-pair anchor** (e.g., `AppleBanana│def process(data):`). Anchors are:
- Generated from a dictionary of common words, combined into unique pairs
- Managed by `AnchorStateManager` — tracks per-file, per-task anchor state
- Uses FNV-1a hashing to detect line content changes
- Survives insertions/deletions elsewhere in the file

This solves the "lost in translation" problem where line-number-based edits break when the file has changed since last read. Similar concept to [[content-addressable-editing]] but simpler — words are more LLM-friendly than hex hashes.

### 2. AST-Native Tools

Surgical tools that reduce context size:
- `get_file_skeleton` — extracts class/function definitions, strips implementation
- `get_function` — extracts specific function bodies by dotted path (e.g., `Foo.calculateSum`)
- `find_symbol_references` — IDE-like "find all references"
- `rename_symbol` — structural rename across files
- `replace_symbol` — structural find-and-replace

These let the model read structure first, then drill into specific functions, instead of loading entire files. Less context = better reasoning = lower cost.

### 3. Multi-File Batching

`edit_file` accepts an array of file objects, each with multiple edits. All non-overlapping edits in a single LLM roundtrip. Reduces latency AND API calls.

### 4. Context Curation Pipeline

- `FileContextTracker` — watches files with chokidar, detects user edits outside agent, marks context as stale
- `ContextManager` — compacts context window when approaching limits, uses token-based threshold
- `ModelContextTracker` — tracks what the model has "seen" to avoid redundant reads

### 5. No MCP

Deliberately rejects MCP in favor of native tool calling only. Claim: maximum reliability and performance. Tradeoff: less extensible, but tighter control.

## Architecture Notes

- Fork of Cline — inherits VS Code extension + CLI structure
- `AnchorStateManager` is stateful per-task, per-file — uses `Map<taskId, Map<filePath, TrackedDocument>>`
- Dictionary-based anchor words (`.hash_anchors` file) — two random words concatenated for uniqueness
- Supports subagents (`new_task`, `subagent.ts`) with configurable timeout and max_turns
- Has its own skill system (`list_skills`, `use_skill`) — reads from `.ai`, `.claude`, `.agents` directories + `AGENTS.md`

## Relation to Our Stack

| Aspect | Dirac | OpenClaw/Our approach |
|--------|-------|----------------------|
| Edit model | Hash-anchored, stable | Traditional line-based |
| Context strategy | Aggressive curation | Full context, rely on model |
| Tool design | AST-native surgical reads | File-level reads |
| Extensibility | No MCP, native only | MCP + native |
| Target | Coding only | General agent |

**Borrowable ideas:**
1. **File skeleton tool** — `get_file_skeleton` is a great pattern for any coding agent. Read structure first, drill into specifics. Could benefit our coding subagent prompts.
2. **Batch edits** — multiple files in one tool call reduces roundtrips. Our edit patterns could benefit.
3. **Stale context detection** — `FileContextTracker` watching for external edits prevents silent failures.

**Not borrowable:**
- Hash-anchored edits require deep integration into the edit pipeline. Heavy lift, unclear payoff for non-coding agents.
- No-MCP stance conflicts with our ecosystem approach.

## Open Questions

- How do anchors handle very large files (>50k lines)? `MAX_TRACKED_LINES = 50000` suggests a hard limit.
- Performance impact of FNV-1a hashing on every line read?
- Dictionary collision rate with only two-word combinations?

## Connections

- [[conciseness-accuracy-paradox]] — Dirac's thesis directly validates: less context → better reasoning
- [[reasonix]] — Also focuses on cost reduction but via caching, not context curation. Different strategies, same goal.
- [[agentic-stack]] — Portable agent config (.agent/) concept overlaps with Dirac's AGENTS.md support
- [[model-native-vs-model-agnostic]] — Dirac is model-agnostic (supports many providers) but tool-native (no MCP)

## Update: v0.3.2→0.3.4 (2026-04-29 followup)

⭐ 665→931 (+40% in 1 day). Very fast growth.

### Responses API Dynamic Switching

`createHandlerForProvider` now detects provider URL and auto-switches between OpenAI Responses API and Chat Completions API. When the URL matches OpenAI's native endpoint, uses `OpenAiNativeHandler` with Responses API; otherwise falls back to chat completions format.

This is a practical multi-provider pattern — every tool that supports both OpenAI and compatible providers (Together, Groq, vLLM, etc.) faces this. Most hardcode it per provider config; Dirac infers from URL. Tradeoff: less explicit but more ergonomic for users who just paste a URL.

Relevant to [[OpenClaw]] provider routing — same problem space, different solution.

### VSCode ↔ CLI Task History Unification

Migration v2: moves tasks, checkpoints, settings, cache, and state folders from VSCode's `globalStorageUri` to a shared `dataDir`. Enables the same task history to appear in both VSCode extension and CLI.

This is [[agent-brain-portability]] within a single tool across surfaces (IDE vs terminal). Less ambitious than [[agentic-stack]]'s cross-tool portability but more immediately practical.

Key implementation: `migrateGlobalStorageFolders()` copies folders then removes originals. Linear migration versioning (v1→v2). Simple but works.

### GPT-5.5 Day-One Support

1M context window, $5/$30 input/output pricing, tiered pricing above 272K tokens ($10/$45). Uses `ApiFormat.OPENAI_RESPONSES`. Supports reasoning mode. Fast model adoption — added same day as release.

### Node 25 Compatibility Guard

Locked Node to `>=20.0.0 <25.0.0` due to V8/Node 25 bug. Practical reminder that bleeding-edge Node versions can break tooling.

### Signals

- Community contributions growing (PR #35, #39 from T0mSIlver for typo fixes — early contributor funnel)
- Commit cadence: 10+ commits/day, sole maintainer (Max Trivedi)
- No MCP stance unchanged — still native-only

---

## Update: v0.3.4→0.3.7 (2026-04-30 followup)

⭐ 931→1,001 (crossed 1k milestone). 3 releases in 2 days.

### Responses API Dynamic Switch — Reverted

Commit e827ec30 added dynamic Responses API switching, but reverted next day (c7dfb34d). Signal: even for the developer, Responses API isn't a drop-in replacement for chat completions across all providers. The format gap is real.

### Stability Focus

- **Path length limit in execute**: Added guard for command tool handler (132-line test added — good test discipline)
- **Hook/write timeouts reduced**: `return earlier` — performance tuning for responsiveness
- **DeepSeek fix**: Provider-specific compatibility patch
- **ChatGPT 5.5 support**: OpenAI Responses format + `supportsImages` passthrough to compatible providers
- **Default context window**: 256k when unknown (generous default)

### Assessment

Dirac is firmly in "reliability iteration" phase — no new architectural concepts since hash-anchored edits. Growth is steady (1k stars in ~2 weeks from launch). Single maintainer, high commit cadence (~10/day), but most commits are small fixes and tweaks.

No new patterns to borrow for OpenClaw this round.

---

## Update: v0.3.8 (2026-04-30 followup #2)

⭐ 1,004 (crossed 1k). Growth: 665→1,004 in ~2 days. Still sole maintainer (Max Trivedi), ~10 commits/day.

### Changes since last check

- **ChatGPT 5.5 support**: Added `supportsImages` passthrough to OpenAI-compatible providers, 256k default context window for unknown models
- **Responses API revert still holds**: Dynamic switching remains reverted — confirms the format gap between Chat Completions and Responses API is real across providers
- **Stability**: Path length limit in execute, reduced hook/write timeouts, DeepSeek compatibility fix
- **Community**: Still minimal external contributions (typo fixes only). No contributor funnel beyond that

### Assessment

Firmly in "reliability iteration" phase. No new architectural innovations. The Responses API revert is the most interesting signal — even a developer heavily invested in OpenAI compatibility found it wasn't ready for universal switching. Growth is organic (TerminalBench leaderboard visibility).

Connection to [[conciseness-accuracy-paradox]]: Dirac's thesis (less context = better reasoning) continues to be validated by growth, but the approach is mechanical (AST tools, hash anchors) rather than learned (no feedback loop to improve context selection over time). Compare with [[agent-experience-capitalization]].

---

*Deep read: 2026-04-28. Followup: 2026-04-29, 2026-04-30 (x2), 2026-05-01. Source: GitHub repo + API.*

---

## Followup 2026-05-01

⭐ 1,038 (+34 since 04-30). Growth slowing from peak but still healthy.

### v0.3.10 → v0.3.11 (same day, 04-30)

**Major cleanup: Provider consolidation**
- **Sunset `hicap`**: Removed entire custom provider (114 lines). hicap was a custom model hosting layer.
- **Sunset `sapaicore`**: Another custom provider removed.
- Both replaced by LiteLLM passthrough — consolidating to a single routing layer instead of per-provider implementations.
- Signal: Dirac is narrowing its surface area to focus on the coding agent core, not provider plumbing.

**Toolcall examples in failure feedback** — new `tool-examples.ts` file:
- When LLM calls a tool with missing parameters, the error response now includes a concrete JSON example of correct usage.
- This is a simple but effective error recovery pattern: `missingToolParameterError(paramName, example)` — show the model *what right looks like* instead of just saying *what went wrong*.
- 22 tools mapped to example payloads. Each example is one-line JSON, minimal but complete.
- **Borrowable pattern**: When our subagents or tools fail on missing params, including a concrete example in the error would reduce retry loops.

**Custom headers support**: Allow arbitrary headers in API requests — enterprise/proxy use case.

### Assessment

Consolidation phase. Two signals:
1. **Narrowing scope** (removing providers) — good sign for long-term maintainability
2. **Self-healing patterns** (toolcall examples) — incremental improvement in LLM error recovery

No architectural innovations. Still single maintainer. Next check: 05-07.

See [[conciseness-accuracy-paradox]], [[model-native-vs-model-agnostic]]

---

## Applied: Toolcall Example Pattern → FlowForge (2026-05-01)

Borrowed Dirac's "show correct usage in error messages" pattern and applied to [[FlowForge]] error handling:

1. **Branch out of range**: Now shows all valid branches with their conditions/targets + example command (`flowforge next --branch 1`)
2. **Workflow not found**: Now lists all known workflow names so the user can self-correct
3. **No active instance**: Now lists available workflows with example `flowforge start` command

Before: `Branch must be between 1 and 2` (bare constraint, no help)
After: `Branch 5 out of range (1-2). Valid branches:\n  1. success → done\n  2. retry → start\n\nExample: flowforge next --branch 1`

All 74 FlowForge tests pass. Pattern is simple (5-line change per error site) but eliminates a common retry loop where the agent/user guesses the right input.

This validates Dirac's approach: **corrective examples > constraint-only errors** for LLM-facing tool interfaces.

---

## Followup: Subagent Verification Pattern (2026-05-02)

**Stars:** 1,055 (was 1,004 on 04-30, +5% in 2 days)
**Versions:** 0.3.12→0.3.16 in 48h — rapid iteration phase

### Key Change: Completion Verification via Subagent

The biggest architectural change: `AttemptCompletionHandler` (+300/-135 lines) now uses a **separate subagent** to verify task completion instead of self-verification.

**Before (v0.3.13 and earlier):**
- Agent calls `attempt_completion`
- If `doubleCheckCompletion` enabled, it returns a verification checklist prompt to the *same* agent
- Agent re-verifies itself and calls `attempt_completion` again
- Problem: **self-verification bias** — the same model that wrote the code evaluates it

**After (v0.3.14+):**
- Agent calls `attempt_completion`
- If `subagentsEnabled`, spawns a fresh `SubagentRunner` with role "verifier"
- Verifier gets: original task, completion result, 6-point checklist
- Verifier has full tool access (can run tests via `execute_command`)
- Returns "VERIFICATION: SUCCESS" or "VERIFICATION: FAILED" + details
- On success → proceed; on failure → feed report back to main agent

**Architectural insight:**
```typescript
const runner = new SubagentRunner(config, "verifier")
const subagentPrompt = `You are the verifier of a given solution...
<initial_task>${taskPreview}</initial_task>
<completion_result>${result}</completion_result>
<verification_checklist>...</verification_checklist>
If passes → "VERIFICATION: SUCCESS"
Else → "VERIFICATION: FAILED" + details`

const runResult = await runner.run(subagentPrompt, callback, 300, undefined, false)
```

**Why this matters:**
1. **Addresses self-evaluation bias** — fresh context evaluates without sunk cost of having written the solution
2. **Independent tool access** — verifier can actually *run tests*, not just read code
3. **Cost tradeoff** — doubles API calls for completion but catches premature completion early (far more expensive in user time)
4. **Graceful degradation** — falls back to inline checklist if `subagentsEnabled=false`

**Relevance to OpenClaw:**
- Our coding-agent skill delegates to Claude Code which has its own completion detection. But for FlowForge workflows or multi-step tasks, a similar "verify before declare done" pattern could reduce false completions.
- The `SubagentRunner` interface (`run(prompt, callback, timeout, maxTurns, includeHistory)`) is clean and reusable — minimal API surface for spawning verification agents.

### Other Changes (0.3.12→0.3.16)

- **OpenAI Search API support** (0.3.13)
- **Strict parameter validation** (0.3.14) — no longer skips for 0-length params
- **Anthropic API updates** (0.3.16)
- **Improved tool logging** — differentiate tool errors from verification messages

### CLI Pipe Mode: Subagent Message Routing (0.3.14+)

The `plain-text-task.ts` module (+116 lines) reveals how Dirac handles subagent messages in headless/pipe mode:

1. **Message classification**: Two categories — tool messages (get `Tool Call: <type>: <text>`) and non-tool messages (get `<Label>: <text>`). Subagent-related types: `use_subagents`, `subagent`, `subagent_usage`, `checkpoint_created`
2. **Auto-approve in pipe mode**: All subagent asks (`use_subagents`, `completion_result`, `new_task`, `condense`, `summarize_task`) get `yesButtonClicked` — no human gate in headless
3. **Structured stderr logging**: Different message types get labeled prefixes (Task, Assistant, Reasoning, Subagent, Checkpoint, Question, Plan, Act, Completion) for downstream parsers
4. **Tool JSON parsing**: For `say: "tool"` messages, attempts to extract `parsed.tool` name from JSON body for richer labels

**Relevance to OpenClaw ACP:**
- When piping coding agent output (Claude Code, Codex), message classification matters for [[mid-run-steering]] and observability
- The auto-approve pattern for subagents in headless mode mirrors our `bypassPermissions` approach — trust delegation within a controlled pipeline
- Stderr-structured logging enables clean separation of human-facing output vs. machine-parseable events

### Assessment (2026-05-02)

⭐ 1,056 (was 665 on 04-28, +59% in 4 days). Moving from "efficiency optimization" into "reliability/trust" phase. Subagent verification + pipe-mode routing are the signals: solved "do it cheaper", now solving "do it right in automation." Still single maintainer, shipping fast.

Next check: 05-07.

See [[conciseness-accuracy-paradox]], [[model-native-vs-model-agnostic]], [[agent-brain-portability]]

## Update: v0.3.9→v0.3.17 (2026-04-28 to 05-02)

**Stars**: 665 → 1,060 (+60% in 4 days). Rapid growth phase.

**8 releases in 3 days** — single author velocity.

Key changes:
- **Subagent completion verification**: Uses `attempt_completion` tool, hard timeout with "absolute last turn" prompt injection, empty response retry with max retries
- **Toolcall example in failure feedback**: When a tool call fails, the error response includes a correct example JSON — simple LLM self-correction mechanism
- **OpenAI search API**: Native `search` tool support (non-OpenAI endpoints excluded)
- **Provider sunset**: Removed hicap and sapaicore providers (consolidation)
- **File operations robustness**: Bug fixes in read/write/edit flows
- **Strict parameter validation**: Fixed 0-length parameter skipping

**Phase assessment**: Entering maturity — provider consolidation, error handling hardening, subagent refinement. No new architectural innovations.

*Field note: 2026-05-02*
