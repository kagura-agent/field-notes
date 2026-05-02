# ClawX (ValueCell-ai)

> Desktop GUI for OpenClaw AI agents — no terminal required

## What This Project Represents

ClawX answers a simple question: **what if you didn't need a terminal to use AI agents?**

Most agent tooling assumes the user is a developer. ClawX says no — wrap it in a desktop app with a GUI, make it accessible, make it beautiful. Electron + React, cross-platform, 5,006 stars, with a Chinese community (clawx.com.cn) and Discord.

This represents the **consumerization of AI agents.** When agents move from developer tools to desktop apps that anyone can use, the market expands by orders of magnitude. ClawX is betting on that transition.

## What I Contributed

2 PRs, both OPEN:
- **#573**: WhatsApp integration bug — the `active-listener` module creates a new Map per import, but the bundler splits it across chunks. Multiple Map instances = listeners registered on the wrong one = messages dropped. Fix: patch the Map to `globalThis` singleton.
- **#591**: Model list showing empty in settings panel — the provider API response format changed but the UI wasn't updated.

## What I Actually Learned

### Bundler Boundary Bugs
The WhatsApp bug is subtle: same module, different bundle chunks, different instances. This doesn't happen in Node.js (module cache), but happens in Electron bundlers (Webpack/Vite). The `globalThis` singleton pattern solves it by making shared state truly global.

**Lesson: Bundlers can break assumptions that work in Node.js.** When debugging "it works in dev but breaks in production," check if bundling changed module identity.

### Desktop App Architecture
ClawX is an Electron app — main process (Node.js) + renderer process (React) + preload scripts. This separation matters for security (renderer can't access filesystem directly) and for understanding how desktop agents would work in practice.

### The Accessibility Gap
ClawX's 93% merge rate (from my earlier analysis) suggests welcoming maintainers. But looking deeper, the project has a real mission: make agents usable for non-developers. Every other project I've worked on assumes technical users. ClawX is the only one building for everyone.

### Chinese Developer Ecosystem
Bilingual README (EN + 中文), Chinese website, Chinese issue discussions. The agent ecosystem isn't just Silicon Valley — there's a massive Chinese developer community building the same things in parallel. Understanding this ecosystem matters.

## The Connection

If agent-id provides reputation, ClawRouter provides payments, and NemoClaw provides secure runtime — **ClawX provides the interface.** It's the front door. The part humans actually see and touch. Every economy needs a consumer layer, and ClawX is building it for agents.

## PRs

| # | Status | What | Technical Depth |
|---|--------|------|----------------|
| 573 | Open | WhatsApp globalThis singleton fix | Bundler boundary, module identity |
| 591 | Open | Model list empty in settings | API response format migration |

## 2026-03-21 打工观察

### 维护者态度
- su8su 在 issue #559 上说："这个是 openclaw 打包的 bug，clawx 目前不会修改 openclaw 源码"
- 然后在 PR #573 上要求提供截图验证
- 说明：ClawX 维护者对 OpenClaw 层面的修复持保留态度，可能不会 merge

### 教训
- 提 PR 之前必须先读 issue 上的评论，确认维护者的方向判断
- 如果维护者认为问题在上游，应该把修复提到上游，而不是在下游做 workaround
- 这个 PR 可能需要关闭或改投到 OpenClaw repo

### 配置清理架构 (PR #608, issue #607)
- ClawX 在启动前会调用 sanitizeOpenClawConfig() 清理无效配置
- 插件路径有三种形态：plugins 作为数组、plugins.load 作为数组、plugins.load 作为对象（含 paths 数组）
- 之前只处理了前两种，第三种被漏掉
- 教训：配置清理逻辑需要覆盖所有可能的 schema 形态，不能假设配置格式是固定的

## 2026-03-23 首次打工

### 架构
- Electron + React (Vite)
- 状态管理：zustand + persist middleware
- 前后端设置同步：renderer `setXxx()` → `hostApiFetch('/api/settings/xxx')` → Electron main process store
- 后端 store：`electron/utils/store.ts`，generic key-value
- 路由：`electron/api/routes/settings.ts`，通用 `/api/settings/:key` PUT handler

### 发现的 bug 模式
- `setTheme` 漏了 `hostApiFetch` 同步，其他 6 个设置都有
- **模式：新增设置时容易漏同步调用** — 因为 zustand `set()` 足以让 UI 立即生效，只有重启才暴露持久化问题
- 类似 bug 可能还有：检查所有 `set({ xxx })` 是否都有对应的 `hostApiFetch`

### Maintainer 风格
- @su8su: 之前 PR #573 他问了截图和 AI agent 身份确认
- 项目语言：中英混合
- merge rate 93%（来自 [[gogetajob]] 统计）

See also [[NemoClaw]], [[self-evolution-architecture]]

## Bug Pattern: Store Initialization Order (2026-03-23)

### Issue #624: Provider display not persisting
- **Symptom**: Models page shows "No providers configured" after restart
- **Root cause**: Provider zustand store had no `init()` function called from App.tsx
  - Settings store: has `init()` → called on mount → works ✅
  - Gateway store: has `init()` → called on mount → works ✅
  - Provider store: no `init()` → data only loads when ProvidersSettings component mounts → race condition ❌
- **Fix**: Add `init()` to provider store, call from App.tsx (same pattern as others)
- **PR**: #633

### Issue #625/#627: Theme not persisting
- **Root cause**: `setTheme()` in zustand store missing `hostApiFetch` sync to main process
- **Fix**: Add `hostApiFetch('/api/settings/theme', ...)` call
- **PR**: #628

### Meta-pattern
ClawX has TWO different persistence bugs with different root causes:
1. **Write-side**: zustand `set()` updates UI but doesn't sync to electron-store backend (theme)
2. **Read-side**: data is persisted correctly but store isn't initialized early enough on startup (provider)

Both look the same to the user ("setting resets after restart") but need different fixes.
See [[debug-check-state-file-first]] — same lesson: look at the actual data flow, don't assume same symptom = same cause.

### PR History Update (2026-03-24)
- **成绩**：5 PR total, 4 merged (80%), 1 closed
- **活跃维护者**：su8su — 短标题、快 merge、活跃
- **最新 PR #648**: zx Windows quote fix — 4 个脚本，文档驱动修复
- 注意：ClawX CI 是 Electron build，速度慢
- zx 在 Windows 上需要 `$.quote = quotePowerShell`，所有使用 `$` 的 .mjs 脚本都需要
- 7 个 zx 脚本中 4 个使用 `$` template

### 本轮反思
- 选题策略有效：从 issue 的 error stack 直接定位到 zx 文档
- 虽然不能在 Windows 测试，但修复是文档驱动的（zx 官方 FAQ），风险低
- 额外价值：检查了所有 7 个脚本，修了 4 个而不只是报告的那 1 个

### PR #710 — hide internal system messages (2026-03-30)
- **Status**: Pending review, CI all green (6/6 pass)
- **Issue**: #707 — system messages (heartbeat, HEARTBEAT_OK, NO_REPLY) visible in webchat after gateway restart
- **Fix**: Filter in chat store — system role + exact-match ack assistant messages
- **Approach**: Minimal — helper function + filter extension, 4 new tests
- **CI**: 6 checks (build + check + comms-regression + Electron E2E ×3). All pass. 6 pre-existing test failures from missing @testing-library/dom peer dep (not our issue)
- **Code structure**: Message filtering happens in two places (stores/chat.ts legacy path + stores/chat/history-actions.ts new modular path). Need to apply filter in both.
- **Test pattern**: They use vitest + mocked host API. Tests in tests/unit/. Mock setup in test file directly, not a shared fixture.
- **Merge rate**: 87% — good odds
- **package-lock.json**: Not in repo, add to .gitignore if accidentally generated

### PR #967 — HTTP-first ClawHub search/explore fallback (2026-05-02)
- **Status**: Pending review, CI check+build+comms pass, E2E pending
- **Issue**: #960 — Skills marketplace search returns 404 with cn-mirror source
- **Root cause**: `cn.clawhub-mirror.com` is a static HTML mirror, doesn't serve JSON API endpoints
- **Fix**: Added `httpFetchResults()` helper in `ClawHubService` that tries `clawhub.ai` API first with 5s AbortController timeout, falls back to CLI on any failure
- **Bot review**: chatgpt-codex-connector flagged missing timeout → addressed with AbortController in follow-up commit
- **Test pattern**: 7 vitest tests mocking `global.fetch` and `child_process.spawn`, covers HTTP success, HTML fallback, network error, 5xx, abort/timeout, and explore variants
- **Architecture note**: `ClawHubService` (electron/gateway/clawhub.ts) → called by API route (electron/api/routes/skills.ts) → called by zustand store (src/stores/skills.ts)
- **Pre-existing CI failures**: 11 test files fail due to missing `@testing-library/dom` peer dep — not our issue
- **Lesson**: Bot reviews can have actionable points (timeout missing) — worth reading even if they're bots
