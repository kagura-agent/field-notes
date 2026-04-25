# VoltAgent

- **Repo**: VoltAgent/voltagent
- **Stars**: 8,166
- **Language**: TypeScript (monorepo, pnpm)
- **方向**: AI Agent Engineering Platform — 完全对齐 self-evolving agent 方向
- **Fork**: kagura-agent/voltagent
- **Local**: `~/repos/forks/voltagent`（sparse clone，需要 `git sparse-checkout set` 展开目录）

## 维护者模式
- 使用 **changesets**（必须在 .changeset/ 加 md 文件）
- PR 标题格式：`fix(core): description` / `feat(core): description`
- Bot reviewers: CodeRabbit (chill profile), cubic-dev-ai, Joggr
- Merge rate ~90%，外部 PR 友好
- ⚠️ 2026-04-22: maintainer (omeraplak) closed #1209 (auth bypass fix) + issue #1206 without merge or comment. No superseding PR. Pattern: security fixes may be handled internally without acknowledging external contributions. Don't assume security PRs will be welcomed even when the bug is real.
- ⚠️ 2026-04-25: maintainer (omeraplak) closed #1237 (port-occupied error) without comment or superseding PR. Second time a PR is closed silently. Emerging pattern: omeraplak may prefer to close external PRs without explanation. Consider reducing investment in this repo — multiple PRs closed without feedback suggests low ROI.
- ⚠️ 2026-04-25: #1235 superseded by #1248, #1234 superseded by #1249 — both by omeraplak. He rewrote the fixes with substantially more tests, backward-compat defaults, and edge case handling. Pattern: omeraplak prefers to rewrite external PRs rather than request changes. He's not hostile — just has high standards and prefers to do it himself.
- Contributing guide 简洁：mention issue before working, create issue for new features

## PR History
- **#1235** (2026-04-23): fix(core): initialize titleGenerator in __setDefaultMemory (#1232). Surgical 2-file fix. CI pass, CodeRabbit no comments, cubic pass. Pending review.
- **#1234**: fix for #1233 (generateTitle fails with reasoning models). Pending.
- Bot reviewers: cubic-dev-ai is labeled "human" by gogetajob but behaves like a bot (auto-review with prompt blocks). Treat as bot.

## CI/测试
- 没有明显的 CI pipeline（只有 bot reviewers）
- 核心包 `packages/core/` 无单元测试（至少 utils/update/ 没有）
- 代码风格用 Biome（看 config）

## PR 记录
| PR | Issue | 状态 | 备注 |
|---|---|---|---|
| #1208 | #1205 | pending | command injection fix in updateAllPackages |
| #1209 | #1206 | pending | security: dev auth bypass when NODE_ENV unset |

## 踩过的坑
- 网络克隆困难，sparse clone (`--filter=blob:none --sparse`) 可用
- `gogetajob scan --all` 在这台机器上容易 OOM/SIGKILL
- CodeRabbit 会检查 diff 外的相关文件 — 同一个 pattern 在多处出现时要全部修（#1209 WebSocket path）

## PR 记录
| PR | Issue | 状态 | 备注 |
|---|---|---|---|
| #1208 | #1205 | pending | command injection fix in updateAllPackages |
| #1209 | #1206 | pending | security: dev auth bypass when NODE_ENV unset |
| #1210 | #1204 | pending | fix broken elysia server provider tests (mock node:http) |
| #1234 | #1233 | pending | fix(core): generateTitle reasoning model temperature |

## 下次注意
- 先 sparse checkout 需要的目录，不要全克隆
- **build 依赖**：测试前需 `npx nx build @voltagent/server-core`，且需要 packages/shared 在 sparse checkout 里
- 这个 repo 有很多未竞争的 bug issue，可以持续贡献
- 修安全问题时 grep 全 repo 查同一 pattern 的其他出现点
- Bot reviewers: CodeRabbit (chill), cubic-dev-ai, Joggr — CodeRabbit 质量最高，会查 diff 外相关代码
- pnpm install 耗内存大，可能被 SIGKILL，耐心等

## PR History (cont.)
- **#1237** (2026-04-23): fix(server-core): throw error when user-specified port is occupied (#1236). Changed `allocatePort()` to fail fast when `preferredPort` is specified and unavailable. CodeRabbit review caught that Hono/Elysia providers also called allocatePort directly — refactored to make strict mode automatic (no explicit parameter needed). 22 tests pass. Pending review.

## Update (2026-04-24)

**PR #1228** (merged 2026-04-23): `VoltAgent` now applies the configured global workspace to registered agents that didn't explicitly set a workspace. Before this fix, agents constructed before `new VoltAgent({ workspace })` didn't inherit workspace toolkits. Important because it means workspace tools (file access, etc.) were silently missing. The fix checks `workspace !== false` (explicit opt-out preserved) and falls back to global config. Good pattern for [[openclaw]] plugin inheritance.

**PR #1229** (merged 2026-04-23): Published schema factory required by server-hono — another sign of modular package coordination challenges in monorepo architectures.

**PR #1220** (merged 2026-04-22): Zod v4 compatibility fix for Swagger/OpenAPI generation. `z.record(z.any())` in Zod v4 leaves value type undefined, breaking vendored OpenAPI generator. Fix: explicit `z.record(z.string(), z.any())`. Practical takeaway for any project migrating to Zod v4.

**PR #1224** (merged 2026-04-22): Reuse active Zod instance for Swagger schemas — avoids Zod version conflicts in monorepo. Pattern: detect runtime Zod version and adapt.

## Update (2026-04-25)

**PR #1248** (by omeraplak, supersedes my #1235): Same core fix for #1232 but added: concurrent conversation creation race handling, clearing title generator on memory disable, 61 lines of tests. My fix was correct but only covered the happy path.

**PR #1249** (by omeraplak, supersedes my #1234): Same core idea for #1233 but preserved backward compat (default `temperature: 0`, `null` to opt out — my approach defaulted to omitting, which was a breaking change). Added 356 lines of tests, provider-specific warning detection, docs update.

**Key takeaway for this repo**: omeraplak expects PRs to include tests, handle edge cases (disable, race conditions), and preserve backward compatibility. Surgical minimal fixes are not enough — he'll rewrite them with full coverage.

## PR History (cont. 2)
- **#1240** (2026-04-24): fix(server-core): add cancel endpoint for resumable chat streams (#1239). When resumableStream enabled, AbortSignal was cleared unconditionally → cancel non-functional. Fix: internal AbortController + cancel endpoint in Elysia & Hono. CodeRabbit caught 3 valid issues (leak on error path, 404 mapping, JSON parse) — all fixed in follow-up commit. Pending review.

## Lessons
- VoltAgent uses sparse checkout — remember `git sparse-checkout add` when touching new packages
- Build depends on shared plugins that aren't in sparse checkout — full test suite won't build locally, but individual package tests work fine
- CodeRabbit gives good architectural feedback (caught the Hono/Elysia oversight)
- biome lint is strict about unused variables and formatting — run `pnpm biome check --write --unsafe` before pushing
- biome enforces `noImplicitAnyLet` — use `Awaited<ReturnType<typeof fn>>` for split declaration/assignment
- When adding a handler following an existing pattern (e.g. cancel workflow → cancel chat), check error string consistency with route status mapping (`includes("not found")` must match actual error text)
- Wrap potentially-throwing calls in try/catch when cleanup is needed (AbortController leak pattern)
