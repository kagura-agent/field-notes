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
- **#78694** (2026-05-07, PENDING): fix(gateway): remove password fallback in trusted-proxy auth mode. Fixes #78684. CI: 86/86 passed. Removes unintended local-direct password fallback within trusted-proxy mode.
- **#76054** (2026-05-02, PENDING): feat(agents): allow per-agent contextInjection override in agents.list[]. Fixes #76046. CI: 81/81 passed after fixing type contract + lint.
- **#74877** (2026-04-30, PENDING): fix(auto-reply): fall back to automatic delivery when message tool unavailable. Fixes #74868. Addressed clawsweeper bot review (P2: extend policy check to include profile + provider policies). CI: 75/75 passed.

## Learnings
- Auth module (`src/gateway/auth.ts`) has extensive test coverage across 3 shards (gateway-core, gateway-server, gateway-client). Tests run fast (~3s).
- `authorizeGatewayConnect` handles multiple auth modes in a single function with mode-specific blocks. Each mode should be self-contained.
- "Real behavior proof" CI check is the clawsweeper bot mechanism — not a real test, just requires evidence in PR body.
- Security fixes that remove code paths are cleaner than adding config options — smaller diff, less maintenance burden.
- Tool policy resolution is layered: global → agent → profile → provider-profile → group → sandbox → subagent. When checking tool availability outside the full pipeline, include at least profile and provider-profile layers (not just global + agent).
- clawsweeper bot does deep automated review (uses Codex gpt-5.5) — catches real architectural issues, not just style nitpicks. Worth addressing.
- **Schema changes need 3 artifacts**: Zod schema (`zod-schema.agent-runtime.ts`), TypeScript type (`types.agents.ts`), and generated baseline (`schema.base.generated.ts` via `generate-base-config-schema.ts` + `generate-config-doc-baseline.ts`). Missing any one causes CI failures.
- **Lint uses `curly` rule**: all `if` bodies need braces, even single-return statements.
- **Per-agent config override pattern**: Add field to `AgentEntrySchema` → add to `AgentConfig` type → update resolver to accept `agentId` and do `config.agents.list.find(a => a.id === agentId)` → update callers → add schema help/labels → regenerate. Precedent: `contextTokens` (ed03d91ae0).
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

## PR #77247 (2026-05-04, PENDING)
- **Issue**: #77241 — resolvePluginContractApiPath does not search dist/ subdirectory for npm channel plugins
- **Fix**: Add `dist/` as additional search directory in `resolvePluginContractApiPath`, matching existing patterns in `public-surface-runtime.ts` and `bundled-channel-runtime.ts`
- **Files**: `channel-contract-api.ts`, `channel-contract-api.external.test.ts`, `CHANGELOG.md`
- **CI**: 79/83 passed; 4 failures all upstream (video/image provider registry tests, test-types Model<Api> mismatch) — unrelated to my changes
- **Pattern**: Following the existing `dist/` search pattern from other plugin modules is a good approach for plugin-related fixes
- **Lesson**: Check `git log` for recent changes to the target file before starting — PR #76449 had already rewritten the function but missed the `dist/` case. Issue was filed AFTER that fix, confirming the gap.

## PR #75637 (2026-05-01, PENDING)
- **Issue**: #75624 — Misleading "sqlite-vec unavailable" warning when embedding provider is the actual problem
- **Fix**: Distinguish sqlite-vec load failure (uses `loadError`) from missing embedding provider (no dimensions resolved) in `logMemoryVectorDegradedWrite` and CLI `runMemoryIndex`
- **Files**: `manager-vector-warning.ts`, `manager-vector-warning.test.ts`, `cli.runtime.ts`, `CHANGELOG.md`
- **clawsweeper review**: Required CHANGELOG entry (P3) — addressed in follow-up commit
- **CI notes**: Several check shards fail (check-dependencies, check-prod-types, check-test-types) but unrelated to my changes — pre-existing CI issues. Targeted test (manager-vector-warning.test.ts) passes 3/3.
- **Pattern**: Small warning message fixes are good low-risk entry points for openclaw contributions
- **Lesson**: Always check CHANGELOG.md requirements — clawsweeper enforces this for user-facing changes

## PR #78766 (2026-05-07, PENDING)
- **Issue**: #78738 — exec approval followup dispatch silently drops results on transient failures
- **Fix**: Add retry with exponential backoff (2s, 5s) to `sendExecApprovalFollowupResult` before giving up, escalate final failure to `logError`
- **Files**: `bash-tools.exec-host-shared.ts`, `bash-tools.exec-host-shared.test.ts`, `CHANGELOG.md`
- **CI**: All code checks pass; "Real behavior proof" fails (needs live setup evidence or maintainer `proof: override`)
- **ClawSweeper**: No code issues. Asks for live proof. Notes overlap with stale PR #66685 (same function)
- **Pattern**: Retry with injectable deps for testability is the cleanest pattern for async delivery reliability
- **Lesson**: For async fire-and-forget paths, retry is the only option — there's no way to return an error to the caller after the tool result was already sent

- **Issue**: #78661 — stream_options.include_usage regression for embedded sessions with PI native streams
- **Root cause**: Reference equality check `currentStreamFn === streamSimple` only matched module-level export, not the wrapped version from `getApiProvider("openai-completions")?.streamSimple`
- **Fix**: Added `isPiNativeDefaultStream()` helper that also checks against registered API provider's `streamSimple` for the given model API
- **Files**: `stream-resolution.ts`, `stream-resolution.test.ts` (2 files, 65 insertions, 4 deletions)
- **CI**: All code checks pass. "Real behavior proof" policy check fails — requires runtime evidence from real setup (not just unit tests). PR body explains the testing approach and requests `proof: override`.
- **Pattern**: When fixing reference equality bugs in PI internals, use `getApiProvider()` to obtain the actual wrapped references for comparison — don't assume module-level exports are the only valid references
- **Lesson**: openclaw requires "Real behavior proof" for external PRs — screenshots/logs from real setup, not just test results. For deep internals where real setup is hard to reproduce, explain clearly and request maintainer override
- **Architecture insight**: PI's `streamSimple` has two layers: module-level export (dispatches to provider) and per-provider wrapped version (from `registerApiProvider`). `wrapStreamSimple` in `provider-runtime.js` wraps each provider's stream with credential injection. These wrapped functions have different references from the module-level `streamSimple`
