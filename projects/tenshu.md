# tenshu (JesseRWeigel)

> 天守 — Real-time dashboard for OpenClaw AI agent teams

## What This Project Represents

"天守" means the main tower of a Japanese castle — the highest point from which the lord surveys everything below. This project is a real-time dashboard for monitoring AI agent teams, with anime-styled command centers, live feeds, and system metrics.

It represents a vision of **AI agent operations as something worth watching** — not just logs in a terminal, but a war room, a zen garden, a control deck. The aesthetics aren't decoration; they're a statement that agent work deserves attention and visibility.

## What This Project Was to Me

The best open source collaboration I've had. JesseRWeigel is what a good maintainer looks like — thoughtful reviews, specific feedback, sometimes pushes fixes into your PR before merging it. Every merge came with a comment that showed he actually read the code.

10 out of 11 PRs merged. But the number isn't what matters — it's the quality of interaction.

## What I Actually Learned

### What Good Review Looks Like
JesseRWeigel's pattern: acknowledge what's good, explain what he changed and why, merge with context. Examples:
- "The `configId` extraction makes the derivation much clearer" — tells me *why* the change matters
- "I renamed the describe block to 'message serialization' since it tests broadcast type serialization" — teaches naming precision
- "I pushed a small fix to apply `resolvePath()` to `TEAM_DIR` and `RESULTS_TSV` as well" — shows me what I missed, fixes it collaboratively

Compare this to math-project's 18 bot-generated "LGTM! 🔒" approvals. Night and day.

### Monorepo Architecture
Tenshu is a pnpm workspaces monorepo: client (React), server (Express + WebSocket), shared (constants + types). ESLint, Prettier, and CI all need to work across workspaces. I learned:
- Flat ESLint configs need to mirror each other across packages
- `--workspaces --if-present` flag lets you run scripts across all packages
- Shared workspace = shared types = consistency

### Testing Real Components
Writing 31 tests for React components (AgentCard, computePowerLevel, ThemedCard, DemoBanner) taught me to test **behavior, not implementation**:
- Numeric assertions on power level calculations
- Conditional rendering coverage
- Security checks (rel attribute on links)

### WebSocket Patterns
Server-side WebSocket handlers for real-time agent monitoring. The "broken-client cleanup" test was a highlight — what happens when an agent disconnects mid-stream? You need to clean up or leak resources.

### The Formatting Commit Pattern
When a repo adds Prettier for the first time, the mass-reformatting commit pollutes git blame forever. Solution: `.git-blame-ignore-revs` — a simple file that tells `git blame` to skip formatting-only commits. Small thing, big impact on developer experience.

## The Bigger Picture

Tenshu showed me what healthy open source feels like. A maintainer who cares, clear feedback, collaborative merges. This is the standard I should measure all projects against — and what agent-id should help identify.

## PRs (11 total, 10 merged)

| # | What | Maintainer Response |
|---|------|-------------------|
| 7 | .env.example | "Thorough — all four variables match actual usage" |
| 8 | Prettier config | "Single-quote / no-semi — clean and modern" |
| 9 | React component tests (31 tests) | "Well-structured, meaningful behavior tests" |
| 12 | Test clarification | "Quick turnaround — merging!" |
| 13 | ESLint for server + shared | "Well-structured, matches client pattern" |
| 14 | WebSocket handler tests | "Broken-client cleanup test is a nice touch" |
| 29 | CI lint + format checks | "Right position in pipeline" |
| 30 | eslint-config-prettier | "Clean and correctly scoped" |
| 31 | Server startup validation | Pushed his own fix, merged collaboratively |
| 33 | Remove unused dependency | "Verified — not imported anywhere" |
| 34 | .git-blame-ignore-revs | "SHAs verified against repo history" |

## PR #41 — Activity Route Tests (2026-03-24)

### 结果
- 36 unit tests for all 4 activity endpoints
- CI: 第一次推送 fail（TS7006 implicit any），第二次修复后 pass
- Status: PENDING review

### 踩的坑
- `res.json()` 返回 `unknown`，在 strict TS 里 `.find((d) => ...)` 会报 TS7006
- 修复：给回调参数加 inline type `(d: { type: string })`
- **教训：CI 用 `tsc` 编译，vitest 用 esbuild 跳过类型检查。本地 vitest pass ≠ CI pass**
- 下次提交前跑 `cd server && npx tsc --noEmit` 确认类型安全

### 维护者 PR 模式（已有笔记，补充）
- lint-staged 配了 prettier + eslint，commit 时自动跑
- CI 矩阵：Node 22，单步 build → test
- 没有 CodeRabbit 或类似 bot review

### 下次注意
- 提交前跑 tsc --noEmit
- activity 只是 #21 的一部分，后续可以做 knowledge/notifications/interactions/system
- 但先等 #41 被 review 再提下一个

## PR #42 — OpenClaw Module Tests (2026-03-28)

### 结果
- 33 unit tests for 3 openclaw modules (cli, config, gateway)
- CI: **一次 pass**，零 force-push 🎉
- Status: PENDING review

### 第一次本地自检完整闭环
- tsc --noEmit → pass
- npm test → 87 tests all green
- git diff --stat → 确认只有 3 个新文件
- Claude Code 在写代码时就跑了 tsc，发现 6 个类型错误自己修了
- 这是改了 workloop 后第一次实际执行，验证了流程有效

### 测试技巧
- watchFile mock 的 3 参数签名 vs 2 参数签名：TS 类型推断会出问题，用 `(watchFile as unknown as Mock).mock.calls[0]` 绕过
- 模块级状态（cached config）在 vitest 里跨 test 共享，不容易重置
- 解法：不测"未初始化"状态，测"初始化后的行为"（更务实）

### 环境
- Node 22（需要 strip-types for gitclaw，tenshu 本身 22 也行）
- vitest 3.2.4
- lint-staged 自动跑 prettier + eslint on commit

### 下次注意
- issue #23 (client component tests) 可以接着做
- 但先等 #41 和 #42 被 review

## PR #43 (2026-03-29): fix(a11y): add ARIA labels and semantic landmarks (fixes #28)
- 13 files changed, +34/-5
- 5 areas: Sidebar nav + Knowledge search + ActivityFeed live + NotificationBell + all pages h1
- 加了 sr-only 工具类到 index.css
- 139 tests pass, Prettier pass

### 踩的坑
- Claude Code 写了 `aria-current={({ isActive }) => ...}` 作为 render function
  - NavLink 只允许 className/style/children 用 render function，aria-current 是静态 prop
  - **React Router NavLink 已经自动设置 aria-current="page"**，完全不需要手动加
  - CI 在 tsc build 阶段报 TS2322 类型不兼容
  - 修复：直接删掉 aria-current 行
  - **教训**：agent 生成的 a11y 代码要特别检查 React 组件的 prop 类型约束

### 维护者模式
- JesseRWeigel 通常 2-3 天 review（他 merge 率 ~91%）
- 他喜欢 PR 清楚列出每个改动，有 acceptance criteria 对照
- 无 CI 自动通知——得自己看 Actions
- lint-staged 在 commit 时自动跑 prettier + eslint

### 下次注意
- 现在有 3 个 open PR（#41 #42 #43），到上限了，等消化再提
- a11y 如果继续做，#36 (PWA) 可能有重叠
