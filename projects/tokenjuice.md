# tokenjuice

🧃 Token output compaction for terminal-heavy agent workflows.

- **Repo**: [vincentkoc/tokenjuice](https://github.com/vincentkoc/tokenjuice)
- **Stars**: ~90 (2026-04-20)
- **Language**: TypeScript (MIT)
- **Created**: 2026-04-14 (very new)
- **Author**: Vincent Koc

## What It Does

Sits between agent tool calls and terminal output. Command runs normally → tokenjuice compacts the output → agent gets smaller, cleaner payload. Key principle: **never rewrites the command, only the output**.

## Architecture

```
Agent → tool call (git status, pnpm test, etc.)
     → command executes normally
     → tokenjuice reduces output via classification + rules
     → compact result returned to agent
```

### Core Components
- **Classifier** (`classify.ts`): Matches command output to rule sets
- **Reducer** (`reduce.ts`): Applies transformations — strip ANSI, dedupe adjacent lines, head/tail truncation, whitespace compaction, domain-specific rewrites (e.g. git status → `M: file.ts`)
- **Rules** (`src/rules/`): JSON rule files organized by domain — git, build, lint, package, search, filesystem, database, cloud, devops, network, observability, system, openclaw, etc.
- **Artifacts**: Raw output optionally stored locally for debugging (`--store`)

### Rule System
- Built-in: `src/rules/`
- User overrides: `~/.config/tokenjuice/rules`
- Project overrides: `.tokenjuice/rules`
- Later layers override by rule ID

## Host Integrations

| Host | Install | Hook |
|---|---|---|
| Claude Code | `tokenjuice install claude-code` | `~/.claude/settings.json` |
| Codex CLI | `tokenjuice install codex` | `~/.codex/hooks.json` |
| Pi | `tokenjuice install pi` | `~/.pi/agent/extensions/tokenjuice.js` |

**Safe-inventory policy**: File reads stay raw (`cat`, `head`, `jq`). Standalone inventory commands (`find`, `ls`, `rg --files`, `git ls-files`) can compact. Mixed pipelines with exec or unsafe downstream stay raw.

## CLI Modes

- `tokenjuice reduce [file]` — reduce text from stdin/file
- `tokenjuice reduce-json [file]` — machine-facing JSON adapter
- `tokenjuice wrap -- <cmd>` — run + compact
- `tokenjuice wrap --raw -- <cmd>` — bypass, no compaction
- `tokenjuice wrap --store -- <cmd>` — compact + store raw artifact
- `tokenjuice doctor hooks` — check installed integrations

## Relevance to Us

**Direct relevance**: OpenClaw agents (including us) run lots of terminal commands. Tool output is a major context budget consumer. tokenjuice could reduce token waste from `git status`, `npm test`, `find`, etc.

**Considerations**:
- Very new (6 days old), API may change
- Already has OpenClaw-specific rules (`src/rules/openclaw/`)
- Library-first design — could integrate at gateway/hook level
- `--raw` escape hatch is critical for correctness
- The safe-inventory policy (keep file reads raw, compact inventory) is well-designed

**vs our context budget work**: Our context budget optimization ([[OpenClaw]] #66576) focuses on reducing injected workspace files. tokenjuice targets tool output — complementary, not competing.

**Ecosystem position**: Part of a growing category of agent-infra optimization tools. Similar ethos to [[Acontext]] (context management) but at a different layer — Acontext manages what context to include, tokenjuice compresses what tools produce. Both reduce token waste, different attack vectors.

## Key Design Decisions Worth Noting

1. **Deterministic reducers, not LLM summarization** — rules are pattern-based JSON, reproducible
2. **Command semantics preserved** — never changes what runs, only what the agent sees
3. **Domain-specific git status rewriting** — strips help text, normalizes status codes (`M:`, `A:`, `D:`)
4. **Tiny output passthrough** — outputs ≤240 chars skip reduction (not worth it)
5. **Dedupe adjacent lines** — catches repeated build warnings/errors

## Applied (2026-04-21)

Installed v0.5.1 globally and configured hooks for both Claude Code and Codex:
- `tokenjuice install claude-code` → PostToolUse hook in `~/.claude/settings.json`
- `tokenjuice install codex` → hooks.json + `codex_hooks` feature flag in `~/.codex/config.toml`
- `tokenjuice doctor hooks` → all ok

**Quick validation**: `git status` output reduced ~50% (220→109 chars). Repeated `npm warn deprecated` lines correctly deduped.

**Integration layer**: Hooks sit at coding agent level (Claude Code/Codex), not at OpenClaw gateway. This means tool output compaction happens when subagents use coding agents — the main context budget win for our heaviest token consumers.

**Next**: Monitor `tokenjuice stats` after a few coding sessions to measure real-world reduction. Compare with [[context-budget-baseline-2026-04-14]] numbers.

### Stats Check 04-21

First `tokenjuice stats` run — only 3 entries recorded:
- Total raw: 710 chars → reduced: 425 chars (savings 40%)
- Top reducer: `git/status` (2 calls, saved 224 chars, avg ratio 49%)
- `generic/fallback` (1 call, saved 61 chars, ratio 77%)

Too few data points for conclusions. Hooks are working but coding sessions have been sparse since install. Next check: 04-28.

### Stats Check 04-22

No change — still 3 entries, all from 04-21. No coding sessions through Claude Code/Codex hooks since install. Hooks healthy (doctor ok). Pi hook disabled (not installed). Data too sparse; need actual coding sessions to generate meaningful stats.

### Stats Check 04-22 (evening)

Significant jump: 3 → 23 entries. Actual coding sessions generating data.
- **Total**: 13.9k raw → 6.6k reduced, **53% savings**
- **Top reducer**: `git/diff` — 3 calls, saved 6.8k chars, avg ratio 21% (= 79% savings). This is the killer use case.
- `git/status`: 5 calls, 80% ratio (modest savings on small outputs)
- `tests/npm-test`: 1 call, 43% ratio (57% savings — test output compaction works)
- **Daily breakdown**: 04-21 3 calls / 285 saved; 04-22 20 calls / 7k saved
- **Insight**: git diff dominates savings — makes sense since diff output is verbose and highly compressible via structural rules
- **vs [[context-budget-baseline-2026-04-14]]**: tokenjuice operates on tool output, complementary to workspace file injection reduction ([[OpenClaw]] #66576). Together they'd hit both injection and output sides.
- Next trend check: 04-28.
