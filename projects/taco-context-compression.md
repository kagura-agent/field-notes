# TACO — Self-Evolving Terminal Output Compression

- **Repo**: [multimodal-art-projection/TACO](https://github.com/multimodal-art-projection/TACO)
- **Paper**: [arXiv:2604.19572](https://arxiv.org/abs/2604.19572)
- **Stars**: 33 (2026-05-10)
- **License**: Apache-2.0
- **Language**: Python
- **Created**: 2026-04-21
- **Status**: 🔬 deep-dive

## Problem

Terminal agents feed raw shell output back into context, and that noise accumulates **quadratically** across multi-turn tasks — drowning out real error signals and inflating token cost. Hard-coded truncation is brittle (loses critical info or keeps noise).

## Architecture

TACO is a plug-and-play compression framework built into the `terminus-2` agent within the Harbor evaluation framework. Core loop:

```
Proposal (1 LLM call/task) → Compress (regex, no LLM) → Feedback (heuristic) → Evolve (0-3 LLM calls/task) → Persist (cache)
```

### Key Components

1. **CompressionRule** — regex-based rules with `trigger_regex`, `keep_patterns`, `strip_patterns`, `keep_first_n/last_n`, `max_lines`, confidence score, and complaint tracking
2. **Planner** — At task start, sends cached rules + task description to LLM → selects/modifies/creates rules (ONE LLM call per task)
3. **FeedbackCollector** — Detects agent dissatisfaction via structured feedback field + heuristic complaint patterns (regex on agent response)
4. **RuleEvolver** — On complaint: freezes old rule (confidence→0), spawns replacement via LLM. On uncovered output: spawns new rule. On success: boosts confidence (+5%)
5. **RuleCache** — JSON file at `~/.harbor/compression_rules_cache.json`, organized by `task_category`, file-locked, cross-task persistence
6. **Seed Rules** — 6 built-in rules (git, heredoc, pip, apt, compiler, openssl) as cold-start baseline

### Design Decisions

- **Regex over LLM for compression**: Rules are regex-based, applied without LLM calls. LLM is only used for rule generation (rare: 1 planning call + 0-3 evolution calls per task). This keeps per-turn cost near zero.
- **Confidence decay on complaint**: A single complaint freezes the rule (confidence→0). Aggressive — prevents repeated bad compressions but may over-react to one-off edge cases.
- **Conservative defaults**: `keep_first_n=5`, `keep_last_n=10`, never compress errors. Errors in keep_patterns are universal across all seed rules.
- **Category-scoped cache**: Rules accumulated per `task_category`, not global. Prevents cross-contamination between e.g. Python projects and Rust projects.
- **No max_lines by default**: Most rules don't cap total lines — they rely on pattern matching. Only heredoc and compiler have max_lines.

## Results

+1-4% across strong backbones (MiniMax-M2.5, DeepSeek-V3.2, Qwen3-Coder-480B, Qwen3-14B) on TerminalBench. Transfers to SWE-Bench Lite, DevEval, CRUST-Bench, CompileBench.

## Relation to Our Direction

### Connection to [[dirac]] and [[reasonix]]
TACO solves the same problem from a different angle. Dirac uses AST-native reads (file skeleton → drill into function) to **avoid reading noise in the first place**. Reasonix uses 94% cache-first loops to **reduce LLM calls**. TACO assumes full raw output is captured but **compresses it before injecting into context**. These are complementary:
- Source-side: read less (Dirac's approach)
- Context-side: compress what you read (TACO's approach)
- Cost-side: cache more, call less (Reasonix's approach)

### Connection to [[self-evolving-agent-landscape]]
TACO's self-evolution operates at the **Workflow layer** — rules evolve, but the agent's identity/memory/goals don't change. The evolution loop (seed→plan→compress→feedback→evolve→persist) is clean and bounded. Compared to our Identity-layer evolution, it's narrower scope but more immediately measurable (+1-4% on benchmarks).

### Applicability to OpenClaw
We could adopt TACO's pattern for our own exec output handling — especially for subagent tasks that produce long build/test output. The regex+confidence+feedback loop is lightweight enough to run without dedicated LLM calls in most turns.

## Anti-intuitive Findings

1. **Confidence freezing is binary**: One complaint → frozen. No gradual degradation. This is surprisingly effective because false positives are expensive (agent can't recover from missing info) while false negatives (keeping noise) only waste tokens.
2. **LLM calls are rare**: 1 planning call + 0-3 evolution calls per task. The system is 99% regex at runtime. The "self-evolving" part is an infrequent offline process, not continuous.
3. **No issues, no community**: 0 issues, 0 forks, 33 stars. Pure research artifact with no community adoption yet. The code quality is high (Pydantic models, proper tests, Claude code review CI) but it's deeply embedded in the Harbor framework — hard to extract.

## Open Questions

- How does the `uncovered_threshold` (3000 chars) interact with modern LLMs that have 128k+ context windows? Is the threshold too aggressive for tasks where full output genuinely matters?
- The `task_category` grouping — how robust is this when tasks are heterogeneous?
- Could the seed rules + evolution pattern be applied to non-terminal contexts (e.g., web scraping output, API responses)?

---

*First noted: 2026-05-10 (scout)*

## Applied: compress-output.sh (2026-05-12)

Created `tools/compress-output.sh` — a practical implementation of TACO's seed rules pattern:
- 6 type-specific rule sets: npm, pip, git, test, build, generic
- Auto-detection from first 5 lines of output
- Compression ratios: test 81→13 lines (84%), all-pass 35→10 lines (71%)
- Zero LLM calls — pure regex at runtime, matching TACO's core design insight
- Keeps: errors, warnings, summaries. Strips: individual PASS lines, progress bars, compilation noise

**What's different from TACO**: No evolution loop yet. TACO has confidence scoring and complaint-driven rule evolution. Our version is static seed rules. The evolution loop would need integration with OpenClaw's exec handler (currently not extensible). If/when we find rules that over-compress, we can add manual rule tuning.

**Validation**: Tested against synthetic test output (vitest, jest formats). Correctly preserves failure details while stripping pass lines. Auto-detection works for npm/test/git content.

**Usage**: `command 2>&1 | ~/.openclaw/workspace/tools/compress-output.sh [--type TYPE]`

### Domain-Specific ID Preservation (2026-05-12)

Applied [[runbook-hermes]] EvidenceStack insight: compression should preserve actionable identifiers even when verbose lines are stripped.

Added `extract_domain_ids()` to `compress-output.sh`:
- **refs**: PR/issue numbers (`#123`, `org/repo#123`)
- **files**: paths with optional line numbers (`src/lib/parser.ts:45`)
- **shas**: 7-12 char git short hashes

Type-aware behavior:
- `test`: only extract from FAIL/ERROR lines (PASS file paths bloat the summary uselessly)
- `test`: skip SHA extraction (hex fragments in test names cause false positives)
- `git`/others: full extraction

**Before vs after**: compression summary line now reads `[...24 lines compressed (type=git) | preserved: refs:#138,#145 files:src/lib/parser.ts:45]` instead of just `[...24 lines compressed (type=git)...]`. The agent retains reference ability to compressed-away content.
