---
title: DeepClaude
type: project
created: 2026-05-04
last_verified: 2026-05-05
status: tracking
stars: 1076
repo: aattaran/deepclaude
tags: [coding-agent, cost-arbitrage, proxy, claude-code, deepseek]
---

# DeepClaude — Claude Code + DeepSeek V4 Pro (17x Cheaper)

## What It Is

A shell script + local proxy that redirects Claude Code's API calls to DeepSeek V4 Pro or OpenRouter. Same UX, tool loop, file editing, bash — just a different model behind the scenes.

**Mechanism:**
- Sets `ANTHROPIC_BASE_URL` to localhost proxy
- Proxy routes `/v1/messages` → DeepSeek/OpenRouter
- Bridge WebSocket stays on Anthropic (hardcoded requirement)
- Per-session env vars, restored on exit

**Cost:** $0.87/M output tokens (DeepSeek V4 Pro) vs $15/M (Opus) = 17x savings

## Why It Matters (474→1,076⭐ in 2 days)

The explosive growth signals:
1. **Claude Code's moat is the harness, not the model** — users will swap the brain if they can keep the UX
2. **Cost is the #1 pain point** for autonomous coding ($200/month + caps)
3. **DeepSeek V4 Pro is "good enough"** — 96.4% LiveCodeBench, approaching Opus-tier on coding
4. **Model provider lock-in is weak** when the API is Anthropic-compatible

## Architecture

```
Claude Code CLI (unchanged)
  └── localhost:3200 (proxy)
        ├── /_proxy/mode   → switch backend live
        ├── /_proxy/cost   → track savings
        ├── /v1/messages   → DeepSeek/OpenRouter/Anthropic
        └── /* else        → Anthropic passthrough
```

For remote-control mode: bridge WebSocket → Anthropic (required), model calls → proxy → DeepSeek.

## Deep Read: Proxy Internals (2026-05-05)

**model-proxy.js** (443 lines, zero deps) — the entire proxy is one file:

### Model Name Remapping
Hardcoded `MODEL_REMAP` table maps Anthropic model names to backend equivalents:
- `claude-opus-4-6` / `claude-opus-4-7` → `deepseek-v4-pro`
- `claude-sonnet-*` / `claude-haiku-*` → `deepseek-v4-flash`
- OpenRouter variant uses `deepseek/` prefix format

### Thinking Block Handling (key engineering challenge)
The trickiest part — switching backends mid-session creates thinking block incompatibility:
- **Non-Anthropic backends**: Strip ALL thinking blocks (backends reject foreign thinking blocks)
- **Switching back to Anthropic after non-Anthropic**: Also strip ALL (not just unsigned) — because foreign backends generate signed-but-invalid thinking blocks that pass `stripUnsignedThinkingBlocks` but cause Anthropic 400s
- **`hadNonAnthropicSession` flag**: Once set, forces aggressive strip mode for the rest of the session

This is a real architectural insight: **thinking blocks are the hardest thing to make cross-provider**, because they carry signatures that are provider-specific. OpenClaw's approach of native multi-provider avoids this proxy-layer hack.

### Usage Normalization
`UsageNormalizer` Transform stream patches missing `usage` fields in SSE events — DeepSeek/OpenRouter omit them, which crashes Claude Code. Shows how brittle cross-provider compatibility is at the SSE level.

### Cost Tracking
In-memory per-backend token accounting with `PRICING_PER_M` table. Simple `/_proxy/cost` endpoint returns savings vs Anthropic baseline. No persistence — resets on restart.

### Security
- `/_proxy/mode` POST restricted to localhost origin
- Port auto-increment if 3200 is busy (tries up to +20)
- Body size limit 1KB on control endpoints

## Shell Script Layer
`deepclaude.sh` — sets env vars per backend:
- `ANTHROPIC_BASE_URL` → localhost proxy
- `ANTHROPIC_DEFAULT_OPUS_MODEL` / `SONNET` / `HAIKU` → backend-specific names
- `CLAUDE_CODE_SUBAGENT_MODEL` → controls subagent model choice
- Cleanup trap kills proxy on exit

## Relation to Our Stack

| Concern | DeepClaude | OpenClaw |
|---|---|---|
| Multi-provider | Proxy hack per-session | Native architecture (config providers) |
| Model routing | Manual flag/slash-command | Config-level, hot-reload |
| Cost tracking | /_proxy/cost endpoint | Built-in token/cost metrics |
| Harness independence | Only works with Claude Code | Agnostic — any LLM backend |
| Thinking blocks | Strip-all hack (loses reasoning) | Native per-provider handling |

**Key insight for us:** OpenClaw already natively does what DeepClaude hacks together. Our multi-provider architecture is a genuine differentiator vs "one harness, one provider" tools. The thinking-block incompatibility problem deepclaude faces is a strong argument for native multi-provider over proxy-layer hacks.

## Borrowable Ideas

- [ ] **Cost dashboard**: live cost vs baseline comparison — could surface in OpenClaw session status
- [ ] **Per-task model routing**: Opus for planning, Haiku for subagents — the `CLAUDE_CODE_SUBAGENT_MODEL` env var pattern
- [x] **Usage normalization**: patching missing `usage` fields for non-Anthropic providers — OpenClaw should check if it handles this gracefully

## Growth Signal

| Date | Stars | Note |
|---|---|---|
| 05-03 | 0 | Created |
| 05-04 | 474 | First deep read |
| 05-05 | 1,076 | +127% in 1 day — thinking-block fix, model remap, cost tracking |

This growth rate (1K+ in 48h) for a shell script + 443-line proxy is extraordinary. The demand signal is unmistakable.

## Verdict

Not actionable as code (it's a hack around Claude Code's closed architecture). Extremely actionable as **market signal**: the demand for cheaper autonomous coding is massive and immediate. OpenClaw's open architecture with native multi-provider support is positioned well if we surface the cost advantage clearly.

The thinking-block incompatibility problem is architecturally interesting — it reveals that [[extended-thinking]] is becoming a provider lock-in mechanism, not just a feature.

## See Also

- [[thin-harness-fat-skills]] — harness value > model value thesis
- [[openclaw-architecture]] — native multi-provider design
- [[coding-agent]] — landscape of coding agent tools
- [[agent-skill-standard-convergence]] — market dynamics in agent tooling
