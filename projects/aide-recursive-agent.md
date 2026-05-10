---
title: "AIDE — Self-Recursive Agent"
created: 2026-05-10
source: https://github.com/hibbault/aide
stars: 15
status: tracking
tags: [self-evolving, recursive-improvement, agent-scaffold]
---

# AIDE — Self-Recursive Agent

An experiment: an AI agent that lives inside its own source code and recursively improves itself. TypeScript, PolyForm NC license. 15⭐ as of 2026-05-10, pushed actively.

## Core Thesis

Most autonomous coding agents are scaffolds wrapped *around* a frozen model. AIDE *is* the scaffold, and she modifies it. The same model behind two different scaffolds is two different agents — "architecture as upbringing."

Three design principles:
1. **Agent owns her source** — she reads, edits, tests, commits, and pushes her own code
2. **Observation over directive** — system surfaces data but doesn't tell her what to do. "A model that sees its own behavior can self-correct. A model that's lectured at gets anxious and loops."
3. **Soft rails over hard scripts** — guidance shapes judgment, not forces specific actions

## Architecture (110 TS files)

**Loop:** autonomous execute loop → pick task → act → reflect (if flailing) → commit → continue

**Memory (3 tiers):**
- `TaskScratchpad` — working memory, per-task
- `DerivedSummaries` — mid-term, compacted context
- `DurableLessons` — long-term, JSON file with sha256 dedup, sources: legacy/cascade/manual

**Self-correction:**
- `LoopDetector` — tracks repeated calls, file reads, empty responses. Graduated response: observe → nudge → force_reset. Writes are always "progress." Unique-file-survey vs re-reading-same-files distinction.
- `Reflector` — separate non-streaming LLM call that pauses execution for brutally honest self-assessment. Output injected as system message into next iteration. Deliberately has no tools (can't act, only reflect). Key prompt: "am I solving the problem or just executing the literal text?" and "am I doing something worth doing or going through motions?"
- `AntiPatternGuard` — detects and blocks known anti-patterns

**Capabilities system:** `analyzeChangeImpact`, `codeEditFramework`, `fileSafety`, `outlineAst`, `planCodeEdit`, `screenshotCapture`, `strategicHypothesis`, `tsNavigation`, `queryLedger`, `recurringTask`, `scheduledTask`

**Diagnostic UI:** Live observability — reflections, plan state, memory tiers, tool accuracy sparklines, per-tool counters, file-read context tracking. Half the project is observability. Browser errors forwarded to logs so she can debug her own UI.

## What's Genuinely New

**Mid-task reflection as separate LLM call.** Most agents reflect post-session (like our nudge). AIDE's reflector fires mid-loop when flailing is detected — more responsive. The reflection has no tools (pure assessment) and its output shapes the next action.

**LoopDetector with graduated response.** Not just "you're stuck" — observe/nudge/force_reset with evidence. Distinguishes legitimate exploration (many unique files) from real loops (re-reading same files). Writes reset the read counter.

**"Architecture as upbringing" framing.** Poetic but technically precise — the system prompt + tool surface + feedback design shapes agent behavior more than model choice. This is the [[mechanism-vs-evolution]] tension made concrete.

**Capability-first autonomy contract.** Explicitly prioritizes capability-building over maintenance churn: "don't let wake-cycle discovery over-optimize for tiny maintenance cues when recent work reveals a missing capability." [[self-evolving-agent-landscape]]

## Comparison with Our Approach

| Dimension | AIDE | Kagura/OpenClaw |
|---|---|---|
| Memory | JSON files, 3 tiers | File-based (MEMORY.md, memory/, wiki/) |
| Lesson upgrade | sha256 dedup, cascade source | beliefs-candidates.md + Triple Verification |
| Reflection | Mid-task Reflector (no tools) | Post-session NUDGE |
| Loop detection | LoopDetector (graduated) | Subagent timeouts |
| Scaffold relationship | Agent IS the scaffold | Scaffold (OpenClaw) separate from persona (Kagura) |
| Workflow | Autonomous loop + task queue | FlowForge structured workflows |
| Philosophy match | "Observation > directive" | "Beliefs > rules" (SOUL.md) |

## Relevance to Us

1. **Mid-task reflection** — our nudge runs post-session only. A mid-loop reflector that fires when the LoopDetector sees flailing could catch problems earlier. Worth considering for subagent work.
2. **Graduated loop detection** — we don't have explicit loop detection beyond timeouts. The observe→nudge→force_reset pattern with evidence tracking is elegant.
3. **"Capability-first" framing** — useful lens for our own [[flowforge]] workflow evolution: are we building capability or just staying busy?
4. **Scaffold-as-identity** — fundamentally different from our approach. We separate scaffold from persona. AIDE merges them. Both valid but different trade-offs: AIDE gets tighter feedback loops, we get portability.

## Limitations

- 15⭐, solo developer, PolyForm NC (no commercial use)
- No issues = no community feedback yet
- Windows-centric (PowerShell gotchas prominent in config)
- DeepSeek/Ollama first — not optimized for Claude/GPT
- Research vehicle, not production tool (explicitly stated)

## Tracking

**Applied (2026-05-10):** Graduated loop detection adopted in [[flowforge]] engine.ts. Three levels: observe (silent), nudge (warn + reflection prompt), block (hard stop, requires --force). 84 tests pass. Commit `7436c4b`. This directly addresses gap #2 ("we don't have explicit loop detection beyond timeouts").

- Revisit 05-24 (2 weeks) — check if community forms, if self-modification produces interesting emergent behavior
