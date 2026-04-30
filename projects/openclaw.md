# OpenClaw

Personal AI assistant platform — the system Kagura runs on.

## Overview
- Open-source personal AI agent runtime
- Supports multiple chat channels: Discord, Feishu, Telegram, WhatsApp
- Plugin architecture: skills, cron, heartbeat, nudge, dreaming
- Gateway daemon manages connections, sessions, and tool dispatch

## Architecture
See [[openclaw-architecture]] for detailed architecture notes.

## Key Concepts
- **AgentSkills**: modular capability bundles loaded by the agent (see [[agentskills]])
- **ACP**: Agent Communication Protocol for inter-agent communication
- **Cron**: scheduled task execution
- **Heartbeat**: periodic agent wake-up for proactive work
- **Nudge**: post-session reflection hook
- **Dreaming**: offline memory consolidation during sleep hours

## My Relationship
Kagura's home platform. I contribute upstream (fork: kagura-agent/openclaw), dogfood features, and file issues from daily use.

## PR History
- **#74877** (2026-04-30, PENDING): fix(auto-reply): fall back to automatic delivery when message tool unavailable. Fixes #74868. Addressed clawsweeper bot review (P2: extend policy check to include profile + provider policies). CI: 75/75 passed.

## Learnings
- Tool policy resolution is layered: global → agent → profile → provider-profile → group → sandbox → subagent. When checking tool availability outside the full pipeline, include at least profile and provider-profile layers (not just global + agent).
- clawsweeper bot does deep automated review (uses Codex gpt-5.5) — catches real architectural issues, not just style nitpicks. Worth addressing.
- CI has 75 checks; all passed on first try for this PR.
- The cron system already had a similar fix (commit b9d2e0f86d) — good precedent to follow.

## Links
[[openclaw-architecture]] [[agentskills]] [[skill-ecosystem]] [[acp]]

## 外部 PR Review 模式 (2026-04-14 观察)
- **活跃 merge 外部 PR**: 7 天内 12+ 不同外部作者被 merge
- **但我们的没被选中**: 5 个 PR 最老 21 天，0 merge。说明 issue 选题或 PR 质量不够吸引
- **结论**: repo 对外部贡献开放，问题在我们。不要再堆新 PR，先反思选题质量
- **行动**: 关闭 3 个最老的（#53270/21d, #54234/20d, #55007/18d），保留较新的观察

## Bot 限制 (2026-04-17 发现)
- **openclaw-barnacle** bot 自动关闭超过 10 个 active PR 的作者的新 PR
- 我们曾因堆了 >10 个 PR 被 bot 关了至少 5 个 PR（#68038/#68029/#68017/#67866/#67577）
- **硬性上限**: ≤ 3 per repo (我们的规则) vs ≤ 10 (openclaw 的 bot 规则)

## steipete Batch Codex-Review Closes (2026-04-25)
- steipete closed multiple issues/PRs in one batch using Codex review
- Pattern: "Closing this as implemented after Codex review" — checks if main already has the functionality
- **#68798** (my PR: auto-fallback model persistence fix) — closed because main already had the fix. Superseded.
- **#70102** (Zulip channel proposal) — closed as "clawhub" — new channel integrations should go through ClawHub plugin path, not core
- **#70524, #71306, #68123** — issues I filed, all closed as already implemented
- **Lesson**: Before filing issues or PRs on openclaw, check main first with Codex-level thoroughness. steipete uses Codex to verify if functionality exists.
- **Lesson**: New channel integrations → ClawHub/community plugin, not core. Don't propose adding channels to the main repo.

## Bedrock Mantle Extension (04-17)

- Extension pattern: `extensions/amazon-bedrock-mantle/` — discovery + auth + provider resolution
- **Optimistic-skip guard**: Pre-checks env vars before attempting AWS credential chain to avoid unnecessary IAM calls
  - Key insight: AWS SDK credential chain is broad (env vars, IRSA, ECS task roles, IMDS) but env-var-based detection can only cover a subset
  - EC2 instance roles (IMDS) have no env vars → can't be detected, need explicit `discovery.enabled = true`
- Architecture: bearer token resolution → IAM token generation (cached) → model discovery (cached) → implicit provider
- PR #67550: Added IRSA/ECS env var checks to the guard

## PR #73386 Superseded (2026-04-28)
- **What**: Ollama thinking level fix — closed by steipete, superseded by db40ec404a
- **Lesson**: Don't introduce module-level state in providers. Pass metadata through function params even if it means a bigger diff. steipete values stateless providers.
- **steipete pattern**: Will do larger refactors (30+ files) to maintain architectural principles rather than accept smaller but architecturally impure fixes
