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
