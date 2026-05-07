# Lazar

> The smallest self-evolving agent harness.

- **Repo**: [jasonkneen/lazar](https://github.com/jasonkneen/lazar)
- **Stars**: 19 (2026-05-07), 5 forks
- **Created**: 2026-04-29, actively pushed (05-06)
- **Language**: Rust (~2,150 lines kernel)
- **License**: MIT
- **Platform**: macOS only (sandbox-exec dependency)
- **Author**: Jason Kneen (experienced dev, also behind Alloy/Titanium community tools)

## What It Is

A radically minimal agent: **one tool** (`bash(command)`), sandboxed. Everything else — memory, capabilities, self-improvement — is emergent through skills written as markdown files.

```
~/lazar/
├── bin/lazar       ← immutable kernel (chflags uchg)
├── src/            ← kernel source (read-only)
├── skills/         ← the agent's "being"
├── hooks/          ← lifecycle event scripts
├── memory/         ← durable notes (plain markdown)
├── workspace/      ← scratchpad / projects
└── logs/stream.jsonl ← append-only event stream
```

## Architecture: Key Decisions

### 1. One Tool, OS-Enforced Sandbox
Not a design suggestion but a hard constraint: `sandbox-exec` (macOS) limits writes to skills/, memory/, workspace/, logs/, /tmp. The agent literally cannot escape. This is more secure than path-allowlist approaches (our mediaLocalRoots) because it's kernel-enforced.

### 2. Immutable Kernel + Proposal Protocol
`chflags uchg` locks the binary. Agent can read its own source (`cat src/src/main.rs`) but can't modify it. Self-modification goes through `_meta/propose-kernel-patch`: stage full src/ tree in workspace/proposals/, write README explaining changes, user reviews diff and applies via `kernel-apply.sh`. **Trust boundary is the filesystem permissions.**

### 3. Verify Contract (Novel)
When the agent claims it created/modified a file, it MUST emit `[VERIFY]...[/VERIFY]` with testable assertions:
```
[VERIFY]
exists=/path/to/file
size_at_least=/path/to/file:100
contains=/path/to/file:expected text
mtime_within=/path/to/file:30
[/VERIFY]
```
Kernel parses these and checks against actual filesystem. Failures show ❌ to user. **This is agent accountability at the runtime level** — we don't have this.

### 4. Hook System (8 Lifecycle Events)
More granular than our heartbeat/nudge:
- `pre-tool` → can **veto** tool calls or **transform** commands before execution
- `post-tool` → can transform captured output before model sees it
- `session-start` / `user-prompt` → inject context
- `session-end` / `agent-stop` / `tick` / `log-rotation`

Hooks are user-controlled (drop scripts into hooks/<event>.d/). The agent can read but shouldn't modify them without permission.

### 5. Three-Tier Memory
- **L1**: Current log (stream.jsonl) — raw events, bounded reads only
- **L2**: Summaries + distilled learnings (memory/log-summaries/ + memory/distilled/)
- **L3**: Rotated archives (stream.jsonl.*.bak) — forensic last resort

The `_meta/distill` skill is opt-in LLM curation: reads archive samples, extracts gotchas/conventions/recipes/preferences into categorized files with source+date tags.

### 6. Recursion (Depth-Capped Self-Calls)
`lazar -p` can spawn nested `lazar -p` (up to MAX_DEPTH=5). API key not inherited by default (opt-in via env var). Used for referential prompt resolution ("what did we discuss?") and skill composition.

### 7. Seed Skills Compiled Into Binary
`include_dir!()` embeds seed-skills at compile time. `--reset-all` restores them from the binary. Evolution happens in the runtime skills/ dir; seeds are the factory baseline.

## Compared to OpenClaw

| Aspect | Lazar | OpenClaw |
|--------|-------|----------|
| Tools | 1 (bash) | 30+ native |
| Sandbox | OS-level (sandbox-exec) | Path allowlists |
| Self-mod | Proposal protocol | Direct file writes |
| Claim verification | Kernel-enforced [VERIFY] | None (trust agent output) |
| Hooks | 8 events, veto/transform | Heartbeat + nudge |
| Memory | 3-tier file-based | MEMORY.md + daily logs |
| Platform | macOS only | Cross-platform |
| Multi-channel | None (local CLI) | Discord/Feishu/WhatsApp/... |

## Key Insights for Us

1. **Verify contract is the biggest gap we could fill.** A post-execution verification step where the agent must prove its claims against reality. Could be a skill or a nudge-like mechanism.

2. **Pre-tool veto hooks** are powerful for safety. Our pre-execution approval is binary (allow/deny); lazar's hooks can transform commands or inject context before execution.

3. **Kernel immutability as trust signal**: The fact that the agent CANNOT modify its own runtime is a stronger trust guarantee than "the agent SHOULD NOT." OS-level enforcement > behavioral guidelines.

4. **One tool is viable.** The entire capability surface comes from bash + skills. This validates that the tool explosion in many agent frameworks (40+ tools eating context) is unnecessary overhead. Though for multi-channel messaging, you genuinely need native tools.

5. **Distill as explicit skill** (not automatic): LLM-powered knowledge extraction is opt-in, bounded, tagged with source+date. Our beliefs-candidates process could learn from the "always tag source and date" discipline.

## Ecosystem Position

- **Layer**: Infrastructure (harness-level, not application-level)
- **Competitors**: Claude Code (wrapped by [[Orb]]), OpenClaw, Hermes — but positioned as minimalist alternative
- **Philosophy**: Closest to [[thin-harness-fat-skills]] purist position. Even thinner than [[open-design]]'s ~300-line daemon.
- **Limitation**: macOS-only (sandbox-exec). No multi-platform story.
- **Traction signal**: Low stars (19) but high code quality and 5 forks in 8 days. The author has shipped real software before (Alloy/Titanium ecosystem).

## Anti-Patterns Documented

- Referential prompt misresolution: "executes the wrong thing confidently" — their #1 documented error source
- Context blowout from `cat`-ing unbounded logs
- Distilling every session (expensive, diminishing returns)
- Mixing LLM-generated notes with user-written notes

## Links

- [[thin-harness-fat-skills]] — lazar is the purest instance of this pattern
- [[self-evolving-agent-landscape]] — Identity layer (like us and ACE)
- [[skill-behavioral-testing]] — lazar's [VERIFY] is a runtime instance of this concept
- [[mechanism-vs-evolution]] — kernel is mechanism (frozen), skills are evolution (fluid)

## Tags
#self-evolving #architecture #agent-infra #rust #minimalism #deep-dive
