# GodModeSkill (99xAgency)

> Multi-LLM cross-review workflow for Claude Code — lineage diversity as quality gate.

- **Repo**: 99xAgency/GodModeSkill (167★, 2026-04-30)
- **License**: MIT
- **Language**: Bash (1165 LOC orchestrator) + Python (525 LOC pack builder + 260 LOC converge)
- **Status**: Active, built incrementally April 2026
- **Requires**: Claude Code + Codex CLI + Gemini CLI + OpenCode CLI + tmux + inotify-tools

## Core Insight

**Single-model review is an echo chamber.** Same model family reviewing its own work shares blind spots. GodModeSkill enforces **lineage diversity**: every plan/implementation must pass quorum from 3 different model families (Codex/GPT, Gemini, OpenCode/Kimi/DeepSeek) before merge.

## How It Works

1. User invokes `/work plan|implement|major-bug|minor-bug <description>` in Claude Code
2. Claude Code is the **conductor** — writes code, manages git, orchestrates phases
3. `work-pack-build` (Python) assembles an XML review pack with context (code, diff, plan, memory)
4. `work` (Bash) fans the pack to 3 tmux sessions (1 per lineage), then **blocks on `inotifywait`** — zero tokens burned during wait
5. Each reviewer writes findings as structured XML with `<verdict agree="true|false|partial">`
6. `work-converge` (Python) parses verdicts, checks lineage-weighted quorum
7. If disagree → Claude revises, builds `prior-rounds-file`, re-submits (max 3 rounds)
8. If agree → pre-merge checklist shown to human → human approves merge

## Architecture Patterns Worth Noting

### Event-Driven Wait (Zero Token Burn)
The orchestrator suspends Claude on a single `inotifywait` bash call. No polling, no tokens consumed. Resume latency <1s on filesystem event. A 5s safety wakeup also checks for TUI popups and permission prompts.

This is elegant — it turns a potentially expensive multi-minute wait into a free kernel-level event wait. Compare with our OpenClaw ACP approach where we poll subagent status.

### Self-Consistency Verification (Anti-Hallucination)
Findings require structured evidence with `<file-path>`, `<line-number>`, `<quoted-line>`. `work-converge` **greps the actual source file** for each quoted line. Findings that can't be verified get `verified: false`. Critical/high unverified findings are flagged as likely hallucinations.

This is a concrete, cheap countermeasure to reviewer hallucination — no LLM needed, just a grep. Output JSON distinguishes `verified_findings` vs `unverified_findings`.

### Pack Truncation with Integrity Warnings
When packs exceed 800KB, it drops journals → memory → diff (truncated to 50KB last resort). Truncated diffs get a `<reviewer-instruction priority="critical">` warning telling reviewers to verify against full `<code_file>` blocks rather than trusting the truncated diff.

### Cross-Round Context Efficiency
Round 2+ packs **drop memory and journals** (unchanged between rounds), saving ~65% pack size. Prior round findings are carried forward via `<prior-rounds>` block. Reviewers are told not to invent new critiques unless the revision opened them.

### Per-CLI Prompt Format Adaptation
Each CLI handles multi-line input differently:
- **Codex**: Multi-paragraph (bracketed-paste safe)
- **Gemini**: **Single line** with `@/path/to/pack.xml` (every `\n` = Submit in Gemini TUI!)
- **OpenCode**: **Single line**, no leading `/` or `@` (chunk boundary during paste triggers slash-command/agent-picker)

This is hard-won practical knowledge from real tmux orchestration failures.

### Resilience: Provider Error → Peer Swap
On provider errors, retry once → if 2nd error within 60s, **swap to another agent of same lineage** (e.g., kimi ⇄ deepseek). Stays on subscription pricing.

### Destructive Command Blocking at 3 Layers
CLI configs + runtime regex guard + Gemini policy file. Destructive ops leave agent **visibly stuck** for human decision.

## Quorum Rule

```
agree iff: ≥1 codex agree AND ≥1 gemini agree AND ≥1 opencode agree
partial → agree only if no critical/high findings
disabled lineage → excluded from quorum (degraded but valid)
```

Exit codes: 0 (agree), 1 (disagree → revise), 2 (incomplete → escalate)

## Ecosystem Position

- **Sits on top of** Claude Code (conductor) + Codex + Gemini + OpenCode (reviewers)
- **Not a framework** — it's a Claude Code skill (SKILL.md + bash binaries)
- **tmux as IPC** — the orchestrator communicates with reviewers via tmux send-keys, which is fragile but works today
- **Competes with**: individual CI review bots (CodeRabbit, etc.) — but those are same-model-family; this is multi-family by design
- **Cost model**: ~$0 incremental on subscription-priced CLIs (ChatGPT + Google AI Pro + OpenCode Go)

## Relevance to Us

### Applicable Insights
1. **Finding verification via source grep** — we could use this in our PR review workflow. Before reporting a finding, verify the cited code actually exists. Cheap hallucination filter.
2. **inotifywait for zero-cost wait** — our subagent orchestration uses polling; filesystem events could be more efficient for local scenarios.
3. **Per-CLI prompt format knowledge** — if we ever orchestrate multi-CLI workflows, Gemini's newline-as-submit and OpenCode's chunk-boundary issues are critical to know.
4. **Lineage diversity principle** — philosophically aligned with our own multi-model approach. Different model families genuinely catch different things.

### Not Applicable
1. **Heavy tmux orchestration** — we use ACP protocol, not tmux keystrokes. More reliable IPC.
2. **3-reviewer quorum per change** — expensive in time (10min+ per review round). Our PR workflow is faster with single-reviewer + human.
3. **Claude Code as conductor** — we use OpenClaw as conductor, which is model-agnostic.

### Key Difference from [[skill-forge]]
skill-forge (GodModeAI2025) optimizes SKILL.md content via automated eval loops.
GodModeSkill (99xAgency) uses multi-model review as a quality gate for code changes.
Same "multi-model" intuition, completely different applications: one evolves prompts, the other validates code.

## See Also
- [[skill-forge]] — different GodMode project, skill self-evolution
- [[dirac]] — hash-anchored edits, different approach to reliable code modification
- [[cron-observability-metrics]] — our observability approach (simpler)
- [[code-review-lessons]] — our PR review patterns
