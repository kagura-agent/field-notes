---
title: "Reasonix - DeepSeek-Native Cache-First Agent"
type: project
created: 2026-04-27
tags: [agent, deepseek, cache-first, model-native, cost-optimization]
---

# Reasonix — DeepSeek-Native Cache-First Agent Framework

**Repo:** [esengine/reasonix](https://github.com/esengine/reasonix)
**License:** MIT | **Language:** TypeScript (Ink TUI) | **npm:** `reasonix`
**Status:** Active, v0.5.x+ (pre-alpha started 0.0.6, now mature)

## Executive Summary

Reasonix is a terminal-based AI coding agent that is **intentionally coupled to DeepSeek's API** — it exploits three DeepSeek-specific features that generic frameworks (LangChain, Cline, Aider) ignore:

1. **Automatic prefix caching** (cache-hit tokens billed at 10%)
2. **R1's `reasoning_content`** (exposed reasoning chain)
3. **Raw cost advantage** (~30× cheaper tokens than Claude Sonnet)

The coupling to one backend is the design philosophy, not a limitation. Every layer is tuned against DeepSeek-specific behavior and economics.

---

## Pillar 1: Cache-First Loop (94% Cache Hit Rate)

### How DeepSeek Prefix Caching Works

DeepSeek's API automatically caches the **byte-identical prefix** of each request. Cache-hit tokens are billed at **10% of the normal price**. The trigger condition: the request's byte prefix must match a previous request exactly.

### Why Generic Frameworks Fail (~20% hit rate)

Generic frameworks break cache stability every turn by:
- Re-ordering message history
- Injecting new timestamps
- Restructuring system prompts
- Serializing tool lists in non-deterministic order

### Reasonix's Three-Zone Memory Architecture

The core insight is splitting the request context into three zones with strict invariance rules:

```
┌─────────────────────────────────────┐
│ IMMUTABLE PREFIX                    │ ← Frozen for entire session
│ system + tool_specs + few_shots     │   This is the cache target
├─────────────────────────────────────┤
│ APPEND-ONLY LOG                     │ ← Only appends allowed
│ [user₁][assistant₁][tool₁]...      │   Old turns become new prefix
├─────────────────────────────────────┤
│ VOLATILE SCRATCH                    │ ← Reset every turn
│ R1 reasoning, temp plan state       │   Never sent to API
└─────────────────────────────────────┘
```

### Implementation Details (src/memory.ts)

**ImmutablePrefix** — constructed once, frozen, and fingerprinted:

```typescript
// src/memory.ts
export class ImmutablePrefix {
  readonly system: string;
  readonly toolSpecs: readonly ToolSpec[];
  readonly fewShots: readonly ChatMessage[];

  constructor(opts: ImmutablePrefixOptions) {
    this.system = opts.system;
    this.toolSpecs = Object.freeze([...(opts.toolSpecs ?? [])]);
    this.fewShots = Object.freeze([...(opts.fewShots ?? [])]);
  }

  // Hash computed once — if prefix changes, you'd know
  get fingerprint(): string {
    const blob = JSON.stringify({
      system: this.system,
      tools: this.toolSpecs,
      shots: this.fewShots,
    });
    return createHash("sha256").update(blob).digest("hex").slice(0, 16);
  }
}
```

**AppendOnlyLog** — enforces append-only discipline, the only mutation path is an explicitly-named `compactInPlace()` reserved for compaction:

```typescript
export class AppendOnlyLog {
  private _entries: ChatMessage[] = [];

  append(message: ChatMessage): void {
    // Validates and appends — no insert, no reorder, no delete
    this._entries.push(message);
  }

  // Named to be hard to reach for — breaks append-only spirit
  // Reserved only for /compact and recovery
  compactInPlace(replacement: ChatMessage[]): void {
    this._entries = [...replacement];
  }
}
```

**VolatileScratch** — per-turn transient state that never goes to the API:

```typescript
export class VolatileScratch {
  reasoning: string | null = null;
  planState: Record<string, unknown> | null = null;
  notes: string[] = [];

  reset(): void {
    this.reasoning = null;
    this.planState = null;
    this.notes = [];
  }
}
```

### The Loop (src/loop.ts)

The `CacheFirstLoop` class orchestrates these three zones:

```typescript
export class CacheFirstLoop {
  readonly prefix: ImmutablePrefix;  // Zone 1: never changes
  readonly log = new AppendOnlyLog(); // Zone 2: append-only
  readonly scratch = new VolatileScratch(); // Zone 3: per-turn

  // Each API call sends: prefix.toMessages() + log.toMessages()
  // Scratch is NEVER sent
}
```

**Key cache-preserving behaviors in the loop:**

1. **Tool result compaction at turn boundaries** — large `read_file` / `search_content` results (3-15KB typical) are truncated to `TURN_END_RESULT_CAP_TOKENS = 3000` tokens after the turn ends, so they don't inflate every subsequent prompt
2. **Tool argument compaction** — arguments > `ARGS_COMPACT_THRESHOLD_TOKENS = 800` tokens get shrunk after the tool responds (catches whole-file rewrites)
3. **Session healing on resume** — oversized tool results from prior sessions are truncated on load to prevent context-window blowouts
4. **REASONIX.md content is hashed once per session** — project conventions are pinned into the prefix and don't change mid-session

### Benchmark Results

From the README's live benchmarks against the same workload:

| Metric | Reasonix | Generic Harness |
|--------|----------|----------------|
| Cache hit rate | **94.4%** | 46.6% |
| Cost per typical task | $0.001–$0.005 | varies |

From the author's 5-turn Chinese multi-turn dialog test:
- Cache hit rate: **85.2%**
- Total cost: $0.000923
- Same dialog on Claude Sonnet 4.6: $0.015174
- Savings: **93.9%**

With tool use (2 turns): hit rate **94.9%**, savings **95.8%**.

---

## Pillar 2: R1 Thought Harvesting

### The Problem

`deepseek-reasoner` (R1) outputs long reasoning chains in `reasoning_content`. Generic frameworks either:
- Feed it back to the next turn (DeepSeek explicitly says this degrades performance)
- Show it to the user and throw it away

### The Mechanism (src/harvest.ts)

After R1 produces `reasoning_content`, Reasonix makes a **cheap secondary V3 call in JSON mode** to extract a structured plan state:

```typescript
export interface TypedPlanState {
  subgoals: string[];      // Concrete intermediate objectives
  hypotheses: string[];    // Candidate approaches being weighed
  uncertainties: string[]; // Facts flagged as unclear / to verify
  rejectedPaths: string[]; // Approaches considered then abandoned
}
```

The extraction call is cheap (~$0.0001) because:
- Uses `deepseek-v4-flash` with `thinking: "disabled"`
- Temperature 0, max 600 tokens
- JSON mode for structured output

```typescript
export async function harvest(
  reasoningContent: string | null | undefined,
  client?: DeepSeekClient,
  options: HarvestOptions = {},
): Promise<TypedPlanState> {
  // Skip if reasoning too short (< 40 chars default)
  const model = options.model ?? "deepseek-v4-flash";

  const resp = await client.chat({
    model,
    messages: [
      { role: "system", content: EXTRACTION_SYSTEM_PROMPT },
      { role: "user", content: trimmedReasoning },
    ],
    responseFormat: { type: "json_object" },
    temperature: 0,
    maxTokens: 600,
    thinking: "disabled",  // No reasoning overhead
    reasoningEffort: "high",
  });
  return parsePlanState(resp.content, maxItems, maxItemLen);
}
```

### How Harvested State Is Used

The `TypedPlanState` drives **self-consistency branching**: when `uncertainties.length > 2`, the loop can trigger multi-sample branching. The default branch selector picks the sample with the fewest uncertainties.

### Real Example

Logic puzzle: "3 boxes all mislabeled, how to determine all contents by picking one fruit from one box?"

```
‹ subgoals (3): List all label/content combos · Decide which box to pick from · Verify uniqueness
‹ hypotheses (3): Pick from "Apple" box · Pick from "Orange" box · Pick from "Mixed" box
‹ uncertainties (2): Can picking determine uniquely? · Mixed box probability
‹ rejected (2): "Apple" box (insufficient info) · "Orange" box (symmetric problem)
```

Opt-in via `--harvest` flag or `/harvest on` in TUI. Default off (adds one cheap V3 call per turn).

---

## Pillar 3: Tool-Call Repair

DeepSeek has known function-calling bugs that generic frameworks don't handle:

### Three-Pass Repair Pipeline (src/repair/index.ts)

```typescript
// Order per turn:
// 1. Scavenge  — recover tool calls leaked into <think> blocks
// 2. Truncation — close half-emitted argument JSON
// 3. Storm breaker — drop call-storm repeats
```

**Scavenge** (`repair/scavenge.ts`): R1 sometimes emits tool-call JSON inside `<think>` reasoning instead of the `tool_calls` field. Reasonix scans both `reasoning_content` and `content` for valid tool-call JSON, deduplicates against declared calls, and merges them in.

**Truncation** (`repair/truncation.ts`): When `max_tokens` cuts off mid-JSON in tool arguments, the repair closes brackets, adds null for missing fields, removes trailing commas.

**Storm Breaker** (`repair/storm.ts`): Sliding window (default 6 calls, threshold 3) detects when the model calls the same tool with identical arguments repeatedly and suppresses duplicates.

**Schema Flattening** (`repair/flatten.ts`): Deep-nested schemas (>2 levels, >10 params) cause DeepSeek to drop fields. Reasonix auto-flattens at registration time:

```
{user: {profile: {name: "...", age: ...}}}
→ {"user.profile.name": "...", "user.profile.age": ...}  // sent to model
→ {user: {profile: {...}}}                                // reconstructed at dispatch
```

All repair is on by default, zero config needed.

---

## Architecture: DeepSeek-Native vs Model-Agnostic

### What "DeepSeek-Native" Means Concretely

Every layer is coupled to DeepSeek's specific behavior:

| Layer | DeepSeek-Specific Optimization |
|-------|-------------------------------|
| Cache loop | Tuned for DeepSeek's byte-prefix caching (10% pricing) |
| Harvest | Relies on `reasoning_content` field (R1-specific) |
| Repair | Fixes DeepSeek-specific function-calling bugs |
| Escalation | Flash → Pro auto-upgrade on `<<<NEEDS_PRO>>>` marker |
| Effort cap | `reasoning_effort` parameter (V4 thinking mode) |
| Pricing | Cost comparisons hardcoded against DeepSeek V4 rates |
| Client | Custom `DeepSeekClient` with 11-min timeout for DeepSeek's queue behavior |

### Self-Escalation: Flash → Pro

The model (running on `deepseek-v4-flash` by default) can self-report when a task exceeds its capability:

```typescript
// First line of output triggers upgrade
const NEEDS_PRO_MARKER_PREFIX = "<<<NEEDS_PRO";
// Example: <<<NEEDS_PRO: cross-file refactor across 6 modules with circular imports>>>
```

Also auto-escalates after `FAILURE_ESCALATION_THRESHOLD = 3` failures (SEARCH mismatches, truncations, storm repairs) in a single turn.

### Tradeoffs vs OpenClaw / Cline / Aider

**Advantages of being DeepSeek-native:**
- 94% cache hit rate (vs ~20-46% with generic frameworks)
- 30× cheaper per task than Claude Code
- Exploits R1 reasoning chains for structured decision-making
- Handles DeepSeek-specific bugs transparently

**Disadvantages:**
- Zero multi-provider flexibility (no Claude, no GPT, no local models)
- DeepSeek V4-pro doesn't lead every reasoning benchmark (Claude Opus 4.6 still wins some)
- Not suitable for air-gapped/offline use
- No IDE integration (terminal-only by design)
- Depends entirely on DeepSeek API availability and pricing

---

## Performance Claims Analysis: "30× Cheaper Than Claude Code"

### The Claim

"~30× cheaper per task than Claude Code" — from README comparison table: $0.001–$0.005 per task vs $0.05–$0.50.

### Breaking It Down

The 30× savings comes from two multiplied factors:

1. **Raw token pricing**: DeepSeek V4 tokens are ~20-30× cheaper than Claude Sonnet per token
2. **Cache hit rate**: With 94% cache hits at 10% price, effective prompt cost drops further
3. **Compound effect**: Cheap tokens × high cache hit = dramatic savings

### Is It Real?

**Yes, with constraints:**

- ✅ The `/stats` command tracks actual costs with live cache-hit ratios — this is verifiable per-session
- ✅ The benchmark numbers come from real API calls with `prompt_cache_hit_tokens` from DeepSeek's response
- ✅ The cross-session cost dashboard (`~/.reasonix/usage.jsonl`) shows real usage data

**Constraints:**
- Comparison is specifically against Claude Sonnet 4.6, not Claude Haiku (which would narrow the gap)
- "Per task" assumes typical coding tasks (read file, make edit, apply). Complex multi-file refactors that need Claude Opus quality are explicitly out of scope
- DeepSeek API availability can be spotty (the client has 11-min timeout for queue waiting)
- The 94% cache hit rate requires disciplined append-only prompt management — if you `/new` frequently, you restart the cache
- Only meaningful for API-billed usage (not relevant for $20/mo subscription models like Cursor)

### Cost Dashboard Example

```
            turns  cache hit    cost (USD)      vs Claude     saved
----------------------------------------------------------------------
today           8      95.1%     $0.004821        $0.1348      96.4%
week           34      93.8%     $0.023104        $0.6081      96.2%
month         127      94.2%     $0.081530        $2.1452      96.2%
all-time      342      94.0%     $0.210881        $5.8934      96.4%
```

---

## Self-Consistency Branching (Bonus Feature)

Because DeepSeek is cheap enough, Reasonix makes research-paper techniques practical:

```bash
reasonix chat --branch 3  # 3 parallel R1 samples
# or in TUI: /preset max
```

3 parallel R1 samples still cost less than a single Claude call. The branch selector uses Pillar 2's harvested `uncertainties.length` — picks the sample with fewest uncertainties.

Reported improvement: **~10-15 percentage points** on medium-difficulty R1 tasks, at ~1/5 the cost of a single Claude call.

---

## Notable Design Decisions

1. **No LangChain/LlamaIndex** — raw TypeScript, native fetch + SSE streaming
2. **Ink TUI** (React-based terminal UI, same as Claude Code)
3. **SEARCH/REPLACE edit model** — nothing hits disk until `/apply`
4. **Sandbox enforcement** — refuses `..` path escapes, symlink escapes
5. **Session persistence** — `~/.reasonix/sessions/<name>.jsonl`
6. **REASONIX.md** — project conventions pinned into prefix (like Claude's CLAUDE.md)
7. **User memory** — `~/.reasonix/memory/` with global + per-project scopes
8. **Skills** — user-authored prompt packs, similar concept to OpenClaw's skills
9. **Hooks** — PreToolUse/PostToolUse/UserPromptSubmit/Stop shell hooks

---

## Relevance to OpenClaw

**Lessons worth considering:**
- The three-zone memory architecture (immutable prefix / append-only log / volatile scratch) is a clean pattern for any agent framework that wants to exploit prefix caching — not just DeepSeek
- The repair pipeline (scavenge from think blocks, truncation repair, storm breaking) addresses real model quirks that any tool-calling agent hits
- Structured harvesting of reasoning chains is a novel approach to making CoT actionable rather than display-only
- The explicit cost tracking with "vs competitor" comparison is good UX for cost-conscious users

**Key difference from OpenClaw:** Reasonix is a single-model monolith optimized for one provider. OpenClaw is model-agnostic infrastructure. They solve different problems — Reasonix proves that deep model coupling can yield order-of-magnitude cost savings, while OpenClaw proves that flexibility and ecosystem breadth have their own compounding value.
