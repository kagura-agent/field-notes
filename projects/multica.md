# Multica

**Repo**: [multica-ai/multica](https://github.com/multica-ai/multica)
**首次关注**: 2026-04-10
**Stars**: 11,471 (04-14, +6k in 4 days — 爆发持续加速)
**语言**: TypeScript
**License**: Apache-2.0

## 定位

"Managed agents platform" — 把 coding agent 变成团队成员。分配 issue 给 agent，agent 自主执行、报告 blockers、更新状态。

核心卖点：**skill compounding** — 每次解决方案变成可复用 skill，团队能力随时间累积。

## 架构

- Docker self-host: PostgreSQL + backend + frontend
- CLI daemon 连接本地 agent runtime
- WebSocket 实时进度
- Multi-workspace 隔离

## 支持的 Runtime

Claude Code, Codex, [[openclaw-architecture]], OpenCode — 把自己定位为 runtime-agnostic 管理层。

## 与 OpenClaw 的关系

**竞品+互补**:
- multica 专注 **agent as managed worker**（任务板、进度追踪、团队协作）
- [[openclaw-architecture]] 专注 **agent as personal assistant**（消息路由、多平台、生活集成）
- multica 把 OpenClaw 列为支持的 runtime 之一，说明他们认为两者是不同层

**启发**: 如果 OpenClaw 想做 "多 agent 协作" 方向，multica 的 skill reuse 机制值得参考。但 OpenClaw 的优势在消息和个人化，不需要直接竞争任务管理赛道。

## 与 [[Archon]] 的区别

Archon 是 "harness builder"（让 AI coding 可重复）；multica 是 "team manager"（让 agent 像同事一样协作）。不同层次。

## Skill 机制深读 (2026-04-11)

Multica 的 Skill 是 DB-backed 的结构化对象，跟我们的 file-based AgentSkills 不同：

**数据模型**：
- `skill` 表：workspace_id, name, description, content (主 SKILL.md), config (JSON)
- `skill_file` 表：skill_id, path, content — 支持多文件 skill
- `agent_skill` junction 表：多对多关系，一个 skill 可被多个 agent 共享

**注入路径**（execenv/context.go）：
- 每次任务启动时，daemon 创建隔离 workdir
- Skills 写入 provider-native 路径：
  - Claude: `.claude/skills/{name}/SKILL.md`
  - Codex: codex-home/skills/
  - OpenCode: `.config/opencode/skills/{name}/SKILL.md`
  - OpenClaw/默认: `.agent_context/skills/{name}/SKILL.md`
- 同时写 `issue_context.md` 包含任务上下文

**runtime_config.go — Meta Skill**：
- 写入 CLAUDE.md / AGENTS.md，教 agent 使用 `multica` CLI
- 包含 issue CRUD、repo checkout、workflow 指令
- 区分三种任务模式：chat（对话）、comment-triggered（回复评论）、assignment（全流程）

**关键洞察**：
1. Multica 的 Skill = **数据库里的 SKILL.md + 附件文件**，本质跟 AgentSkills 格式兼容
2. Skill compounding = 人/agent 在 UI 里创建 skill → 分配给 agent → agent 下次任务自动获得
3. 没有自动 skill 发现/学习——是人工策展的，不是 agent 自己发现的
4. Provider-native 路径注入很聪明——利用各 agent 框架的原生 skill 发现机制，不需要统一格式

**vs OpenClaw AgentSkills**：
- OpenClaw: file-based, 在 workspace 里，agent 通过 `<available_skills>` 列表发现
- Multica: DB-backed, 通过 API/UI 管理，注入到 workdir 的 provider-native 路径
- OpenClaw 更去中心化（skill 就是文件），Multica 更结构化（有版本、权限、workspace 隔离）
- 两者的 SKILL.md 格式本质相同，可以互通

**打工机会**：
- #646 OpenClaw 集成报错 — 可能是 provider detection 问题
- #669 buildMetaSkillContent 硬编码覆盖 agent skills — 这个 bug 说明 skill 注入还在完善中

## PR #1249: fix resolveTaskWorkspaceID for run_only autopilots (2026-04-17)

**Issue**: #1224 — run_only autopilot tasks 100% fail with 404
**Root cause**: `resolveTaskWorkspaceID` in `server/internal/handler/daemon.go` only handled `IssueID` and `ChatSessionID`, missing `AutopilotRunID` branch
**Fix**: 6-line addition — look up `AutopilotRun` → `Autopilot` → `WorkspaceID`
**Status**: pending review

### 踩的坑
- **Repo 太大无法 clone** — pnpm monorepo + Go + Docker，普通 `git clone` 被 OOM killed
- **解决**: 直接用 GitHub Contents API 下载文件、编辑、通过 API 提交。不需要本地 clone
- **无 Go 测试 CI** — Vercel 只跑 web build，Go server 没有 CI 检查。说明他们可能本地跑 Go tests

### 维护者风格
- PR 标题用 `fix(scope):` / `feat(scope):` 格式（conventional commits）
- 活跃度极高，日均 10+ PRs merged
- 主要贡献者：ldnvnbl（infra/daemon）、NevilleQingNY（frontend/UX）
- 外部 PR 也会被 merge（78% merge rate）

### 下次注意
- 不要尝试 git clone 这个 repo — 用 GitHub API 直接操作
- Go server changes 没有自动 CI，可能需要在 PR 中说明测试方式
- 这是第一个 multica PR，观察 review 速度和风格

## PR #1328: fix(daemon): adopt agents from offline runtimes on register (2026-04-19)

**Issue**: #1326 — Agents keep stale runtime_id after daemon restart, tasks never claimed
**Root cause**: When daemon restarts with a different daemon_id (pre-#1220, daemon.id file loss, cross-machine), agents remain bound to the old offline runtime UUID. No server-side safety net to auto-migrate.
**Fix**: Server-side adoption in `DaemonRegister` — after upserting runtime and merging legacy IDs, also reassign agents and pending tasks from any offline runtime of the same (workspace_id, provider) to the newly-online runtime.
**Key design**: Only adopts from **offline** runtimes (never steals from online ones), only pending tasks (completed tasks keep original runtime_id for audit).
**Files**: runtime.sql (2 new queries), runtime.sql.go (regenerated), daemon.go (+adoptOrphanedAgents method), daemon_test.go (+2 integration tests)
**Status**: pending review, CI all green (backend + frontend)
**Scope**: ~120 lines across 4 files

### 经验
- GitHub API 提交方式继续顺畅，这是第5个 multica PR
- 需要手写 sqlc generated code（无法本地运行 sqlc generate）— 按现有 :execrows 模式写
- 两个测试：positive case (adoption) + negative case (non-stealing from online) — 覆盖核心安全约束
- 理解了 runtime registration 的完整流程：upsert → mergeLegacy → adoptOrphaned → response

### 下次注意
- 继续用 GitHub API 提交
- 现在有5个 PR (1249 merged, 1273/1294/1307/1328 pending) — 接近上限，下轮等消化

## 快速判断

- 增速惊人，6.1k⭐（+3.5k/week）
- Skill compounding 核心 idea 有价值但实现偏简单（DB CRUD + 文件注入）
- 真正的 compounding 应该是 agent 自己从任务中提取 skill 并改进——目前还没到这步
- 值得关注 #669 等 skill 相关 issue，看社区怎么推动这个方向
- 作为打工目标合适：Go+TS monorepo，issue 活跃，OpenClaw 直接相关

## 2026-04-13 Afternoon Sprint: Security Audit + Cross-Platform Observability

### Security Audit Sprint (MUL-566)
multica 做了系统化安全审计（跟 [[openclaw-architecture]] 同天做 3 个 security PR 是巧合但有意义）：

- **#819 HttpOnly Cookie Auth** (359 additions, 14 files): auth token 从 localStorage 迁移到 HttpOnly cookie + CSRF double-submit validation + WebSocket Origin 白名单。经典 XSS mitigation。
  - 亮点：Electron desktop 保留 token auth（cookie 在 Electron 里不好用），web 用 cookie — 按 runtime 区分 auth 策略
  - 新增 `POST /auth/logout` 清除 server-side cookie
- **#822 CSP Headers** (57 additions): `script-src 'self'`, `object-src 'none'`, `frame-ancestors 'none'` — 基本但必要
- **#831 Legacy Auth Fallback**: WebSocket 降级到 token-mode 兼容老 localStorage 用户
- **#837 Online Status Revert**: 上午合了 #821（online 状态指示器），几小时后被 revert — 说明快速迭代但也快速回滚

**跟 OpenClaw 同步进化**: hermes 04-13 port 了 [[startup-credential-guard]] 从 OpenClaw，multica 04-13 做了 auth 全面升级。三个头部框架同天安全加固，不是巧合——agent security 是 2026-04 行业主题。

### Cross-Platform Token Usage Scanning (#824)
**这是今天最重要的发现之一。**

multica daemon 现在能扫描 3 种 agent 框架的本地 session 文件提取 token usage：

| Runtime | 路径 | 解析方式 |
|---------|------|----------|
| OpenClaw | `~/.openclaw/agents/*/sessions/*.jsonl` | assistant messages with `usage` field |
| Hermes | `~/.hermes/sessions/*.jsonl` | assistant messages + `usage_update` entries |
| OpenCode | `~/.local/share/opencode/storage/message/ses_*/*.json` | assistant token usage |

**OpenClaw scanner 实现细节**:
- `openClawLine` struct: type, timestamp, message.role/provider/model/usage(input/output/cacheRead/cacheWrite)
- Fast pre-filter: 先 `bytesContains` 检查 `"usage"` 和 `"assistant"`，避免 JSON 解析所有行
- Model normalization: `normalizeOpenClawModel(provider, model)` — provider 不为空时拼 `provider/model`
- 按天+model 聚合为 `Record`
- 14 个单元测试，Go

**关键洞察**: multica 把自己定位为 **meta-observability layer** — 不管你用什么 agent 框架，multica 都能汇总你的 token 使用。这跟 [[cron-observability-metrics]] 卡片提的需求完全一致，只是 multica 从外部文件扫描，而我们需要的是内部 runtime metrics。

**对我们的启发**:
1. OpenClaw JSONL session 文件里已有完整的 token usage 数据 — 我们不需要新 API，只需要解析现有文件
2. multica 的 `mergeRecords()` 按 date+provider+model 聚合 — 合理的粒度
3. 这验证了 [[cron-observability-metrics]] 的方向：token cost tracking 是 production agent 的基础设施

### 其他变化
- **#800**: ws:task:dispatch 事件加 issue_id（给前端做 realtime issue 关联）
- **#829**: comment-triggered 任务把 triggering comment 内容嵌入 agent prompt（之前 agent 可能看不到触发评论的内容，如果 workdir 有 stale output）
- **#827**: workspace list 从 Zustand 迁移到 React Query

## v0.1.27 跟进 (2026-04-13 morning)

### 发布节奏
- v0.1.25 (Apr 11) → v0.1.26 (Apr 11) → v0.1.27 (Apr 12) — **一天两个 release**，速度极快
- 日均 ~10 commits，主要修 bug 和完善基础设施

### 关键变化
- **`.claude/skills/` candidate path** (#792): skill importer 新增 Claude Code 原生的 skill 路径 `.claude/skills/{name}/SKILL.md`
  - 这说明 multica 在主动适配 Claude Code 的 skill 生态，不是只做自己的格式
  - 跟 [[openclaw]] 的 AgentSkills 和 [[nanobot]] 的 agents/*.md 趋势一致：多平台 skill 互通
- **cycle detection** (#788): BatchUpdateIssues parent_issue_id 处理加循环检测
- **local file storage fallback** (#710): 自托管不再强制需要 S3，本地文件系统即可
  - 降低自托管门槛 — 跟北极星方向（个人场景）对齐
- **Codex sandbox network access** (#796): Codex sandbox 默认无网络，现在可以配置开放

### 生态信号
- multica 在快速补齐自托管能力（local storage、auth graceful degradation）
- skill 路径适配多平台 → skill 格式标准化趋势加速
- 社区活跃度高，contributor 多样

## 2026-04-13 Afternoon Sprint

### Workspace GC (#839, 692 lines)
- Background GC loop in daemon: scans local workspace dirs, removes those with `done`/`canceled` issue status + TTL expired
- `.gc_meta.json` written at task completion (issue_id, workspace_id) → GC uses API to check issue status
- Orphan cleanup (no metadata or deleted issues) after 30 days
- Env vars: `MULTICA_GC_ENABLED`, `MULTICA_GC_INTERVAL` (1h), `MULTICA_GC_TTL` (5d), `MULTICA_GC_ORPHAN_TTL` (30d)
- Prunes stale git worktree references from bare repo caches each cycle
- **Pattern**: metadata breadcrumb at creation + API-driven lifecycle check at cleanup = robust garbage collection

### Claude control_request Dead Code (#811)
- `handleControlRequest()` was implemented but `"control_request"` case missing from switch → tool-use permission prompts silently dropped → Claude stalls indefinitely
- 5-line fix. Classic "dead code from incomplete integration" pattern
- **Relevant to us**: our `--permission-mode bypassPermissions` usage means this specific bug wouldn't bite us, but the pattern (implement handler, forget to wire case) is universal

### Other Afternoon PRs
- **#836**: OpenClaw result incremental parsing — stream stderr line by line, detect JSON result immediately (was: wait for full stream close)
- **#842**: Desktop strip Origin header from WS requests (workaround for #819's origin whitelist blocking Electron localhost)
- **#840**: Repo cache sync in background to unblock heartbeat (was blocking main loop)
- **#626**: Desktop Google login via deep link (OAuth flow through custom protocol handler)

### Sprint Pace
- 10+ PRs merged in a single day, across security (#819/#822/#831), infrastructure (#839/#840), Claude integration (#811/#836), and desktop (#842/#626)
- Consistent pattern: security audit (MUL-566) → infrastructure → integration polish → desktop UX
- multica is shipping at hermes-level velocity now (~10 PRs/day)

### Consolidation Signal
- multica's afternoon sprint is infrastructure-heavy (GC, caching, auth) — post-security-audit stabilization phase
- Same pattern we saw in hermes post-launch: security sprint → infrastructure hardening → docs (#8864)
- All three frameworks (OpenClaw/hermes/multica) now in a "maturation" phase: fewer new features, more resilience/security/observability

### 2026-04-13 Evening
- **#848 WebSocket First-Message Auth** (MUL-580, merged): Token was exposed in WS URL query params (`?token=eyJ...`), logged by proxies/CDNs/browser history. Fix: non-cookie clients send JWT as first WS message after connection opens, 10s timeout. Cookie-based auth (web) unchanged
- **#847**: Make create-workspace button always visible in dropdown
- **#746**: Default create status to "todo" instead of "backlog"

### 2026-04-13 Late Evening: Windows Support Push + v0.1.28
- **v0.1.28 released** (#867): major theme is Windows support + bug fixes
- **#854 Windows installation**: PowerShell installer, GoReleaser Windows build target, `install.sh` redirects Windows users
- **#855 Unix/Windows platform separation** (MUL-690): Go build tags (`//go:build !windows` / `//go:build windows`) for daemon syscalls — `Setsid` vs `CREATE_NEW_PROCESS_GROUP`, `SIGTERM` vs `process.Kill()`, `tail` vs native Go file reading
- **#856 Windows build target**: GoReleaser .zip archive for Windows
- **#859 Windows symlink fallback** (MUL-691): `os.Symlink` → junction (`mklink /J`) → file copy fallback. No Developer Mode or admin required
- **#860 Path separator fix**: Replace hardcoded `/` with `filepath.Join` and `os.TempDir()`
- **#865 Sub-issue progress from DB** (MUL-702): Client-side computation was wrong (paginated cache missed done issues beyond page 1). Fix: server-side aggregation endpoint
- **#861 Chat UI overhaul**: Resizable window, expand/restore, open/close animations, session history improvements, draft persistence. Major UX polish
- **#857 Keyboard navigation**: Arrow keys in assignee picker — accessibility improvement

**Platform expansion signal**: 9 PRs in one evening, half devoted to Windows. multica is not just fixing bugs — they're aggressively expanding platform reach. This mirrors what happened with [[nanobot]] (provider dialect explosion) and [[hermes-agent]] (multi-runtime): when a project hits product-market fit, they immediately expand surface area.

**Architectural maturity**: Build tags for platform-specific code (not `runtime.GOOS` switches) = they're planning for sustainable cross-platform. The symlink fallback chain (`symlink → junction → copy`) shows defensive coding for Windows's quirky filesystem semantics.

### 04-13 晚间跟进

**UX 打磨加速**：
- **#869 Bubble Menu 富文本编辑** — 选中文字后弹出格式化菜单（bold/italic/link/heading 等），chat-first 产品的标配功能
- **#870 Cookie Auth 修复** — `AuthInitializer` 未支持 cookie auth 模式，self-hosted 部署路径修复
- **#862 OpenClaw JSON 兼容** — 有 `durationMs` 但无 `payloads` 的 JSON 结果被错误拒绝，一行 fix
- **#852 Onboarding Wizard** — 全屏 4 步引导（Create Workspace → Connect Runtime → Create Agent → Get Started），哲学是 "building your AI team" 而非 "configuring a tool"，WebSocket 实时检测 runtime 连接状态。992+/-301, 21 files

**跟 [[hermes-agent]] 的收敛**：hermes 做 operational hardening（SQLite backup、env sanitize），multica 做 UX polish（onboarding、editor）。不同侧重，但都是从 feature-building → production-ready 转型

**对我们的启示**：onboarding wizard 是 product-market fit 信号——项目到了"有人用但不好用"阶段就会投入 first-run experience。OpenClaw 的 Feishu QR (#65680) 是同方向的投入

## 2026-04-14 Afternoon: OpenClaw Backend P0+P1 + Daemon Watchdog

### #910 OpenClaw Backend P0+P1 Improvements (809+/-36, merged)
multica 的 OpenClaw 集成从 "basic adapter" 升级到 "first-class backend"：

**P0 — 用户体验**：
- **Streaming output**: NDJSON events (text/tool_use/tool_result/step_start/step_finish/lifecycle) 实时 emit，不再等最终 blob
- **Tool use support**: parse `tool_use` + `tool_result` events，匹配 Claude/OpenCode 后端行为
- **--model / --system-prompt passthrough**: 转发到 OpenClaw CLI

**P1 — 鲁棒性**：
- **Hardened JSON parsing**: `tryParseOpenclawResult` 要求行以 `{` 开头（之前扫描任何包含 brace 的行 → false match log 行）
- **Lifecycle event handling**: 新增 `lifecycle` event type + phase tracking (error/failed/cancelled) + 结构化 error 对象
- **Usage field name variants**: `parseOpenclawUsage` 支持 input/inputTokens/input_tokens 三种命名 + cacheRead/cachedInputTokens/cache_read_input_tokens + 增量累积 across step_finish events

**测试**: 31 个新 OpenClaw 单元测试（从 4 个增长到 35 个），全面覆盖 legacy blob + streaming events + edge cases

**关键洞察**: multica 现在完全理解 OpenClaw 的 NDJSON 流协议。这意味着 multica 用户能用 OpenClaw 做 coding agent 并获得跟 Claude 一样的实时反馈体验。OpenClaw 在 multica 生态中从 "also supported" 变为 "fully integrated"。

### #947 Daemon Stall Watchdog (123+/-58, merged)
**三层防挂机制**，解决 agent CLI 进程卡住（如 tool call 访问不可达路径）导致任务永久 `running` 的问题：

**Layer 1 — Agent Backend Watchdog** (claude.go / opencode.go / openclaw.go / gemini.go):
- goroutine 监听 `runCtx.Done()`，context 取消时主动 `Close()` stdout/stderr pipe → 强制 scanner.Scan() 返回
- `cmd.WaitDelay = 10s` — Go 进程退出后 10s 内强制关闭 pipe（OS 级保障）
- 所有 4 个 backend 统一应用，不是只修一个

**Layer 2 — Drain Timeout** (daemon.go executeAndDrain):
- 独立于 backend timeout，额外 +30s 缓冲
- `select` 同时监听 message channel + drainCtx.Done()，不会因 backend 故障无限阻塞
- 默认 21 分钟（无 timeout 时），足够覆盖长任务

**Layer 3 — Ping Context-Aware** (daemon.go handlePing):
- ping 操作加 `select` 监听 pingCtx.Done()，不再裸 `<-session.Result` 死等
- 超时后主动报告 `"failed"` + duration_ms 而非 deadlock

**为什么这重要**：
- 直接关联我们的 subagent timeout 问题（Copilot API 60s idle timeout + Claude Code OOM SIGKILL）
- multica 的三层方案是 defense in depth：进程级(pipe close) → goroutine级(drain timeout) → 功能级(ping select)
- 我们的 OpenClaw exec 只有单层超时（exec timeout），没有 pipe close watchdog 和 drain timeout
- **可借鉴**: 给 OpenClaw subagent spawn 加 pipe close watchdog，防止 hung process 阻塞 session

### 其他 04-14 变化
- **#938**: Description click-to-focus UX fix
- **#910 + #947 合体效果**: multica 的 OpenClaw 后端现在既有实时流（#910）又有防挂保护（#947），生产可靠性大幅提升

## 2026-04-14 跟进：爆发持续 + 架构扩展

### 增长数据
- **Stars**: 5.3k (04-10) → 11.4k (04-14) — 4 天翻倍，日均 +1.5k
- **Forks**: 1,423
- 15+ PRs merged in 24h（04-13 evening → 04-14 morning）
- 从 "快速增长" 进入 "生态扩张" 阶段

### Gemini CLI Backend (#755, merged 04-13)
**multica 第六个 runtime provider**（alongside claude, codex, opencode, [[openclaw-architecture]], hermes）

关键设计：
- `geminiBackend` implements polymorphic `Backend` interface
- Spawns: `gemini -p <prompt> --yolo -o text [-m <model>] [-r <session>]`
- Context deadline → `"timeout"` status，跟 Claude/Codex 契约一致
- `GEMINI.md` meta-skill injection（Gemini CLI natively discovers GEMINI.md）
- 4 unit tests covering `buildGeminiArgs` variations
- **最小可行集成**：272 additions, 5 deletions, 6 files — 利用已有的多态架构

**洞察**：multica 的 `Backend` interface 足够泛化，新 provider 只需 ~270 行。这说明他们的 agent-agnostic 架构是真的不是口号。对 [[openclaw-architecture]] 也有参考——skill injection 应该 provider-native（写到各框架的原生发现路径）而不是统一格式。

### 安全审计第二波 (MUL-577~582)
继 04-13 HttpOnly Cookie + CSP 后，今日继续系统性修复：

| PR | 级别 | 修复内容 |
|----|------|----------|
| #934 | LOW | JWT 30d→72h + attachment UUID v7→v4（防时间枚举） |
| #935 | MED | Cross-workspace subscription injection + upload missing member check |
| #936 | MED | S3 keys scoped per workspace（`workspaces/{id}/{uuid}.{ext}`）|

**Pattern**: 系统化安全审计 → 编号跟踪（MUL-566/577/580/581/582） → 按严重度分批修复。multica 的安全工程成熟度在快速提升。对比 [[agent-security]]，这是 "agent platform security" 跟 "agent runtime security" 的区别——multica 关注的是多租户隔离，我们关注的是 agent 权限边界。

### CLI 重构 (#888, merged 04-13)
- `install.sh` 不再写 config.json — 安装与配置解耦
- 新命令：`multica setup` / `multica setup cloud` / `multica setup self-host`
- `resolveServerURL` 不再静默 fallback 到 `multica.ai` — fail loudly
- Overwrite protection + health check probe
- **教训**：silent defaults 是 self-host 产品的大敌。"默认连到 SaaS" 对免费版可以，对 self-host 是安全隐患。

### 任务生命周期完善 (#940)
- Issue status → `cancelled` 时自动 cancel active agent tasks
- Daemon polling 5s 内生效
- 12 行 fix — 利用已有的 polling infrastructure
- 体现 multica 的 "agent as managed worker" 哲学：工单取消 = worker 任务取消

### Gemini 集成的早期痛点 (#937)
- Daemon health check ping 频率太高 → Gemini preview model 429 rate limit
- Claude ping 也有问题：daemon 过滤 `CLAUDECODE_*` 环境变量 → 自定义 gateway/proxy 配置丢失 → ping 挂 60s
- **这验证了 multica "runtime-agnostic" 架构的脆弱面**：每个 runtime 的环境变量约定不同，统一管理必然丢配置。跟 [[openclaw-architecture]] 面临的 agent harness 兼容性问题类似

### 打工机会
- #937 (Gemini rate limit + Claude env stripping) — 可以修 daemon 的 env filter 逻辑
- #933 (Homebrew formula outdated) — 只需 cut new release，但可以帮写 CI 自动化
- #939 (快速分配 agent 到 issue) — feature request，有设计空间

### 整体判断
- multica 从 "demo 阶段" 进入 "生产就绪" 阶段的速度极快（<1 周完成安全审计 + 跨平台 + CLI 重构）
- Stars 翻倍不是偶然——产品在解决真实痛点（团队级 coding agent 管理），且迭代速度极快
- 对我们的影响：multica 验证了 "managed agent" 赛道有需求，但 [[openclaw-architecture]] 的个人化路线和 multica 的团队管理路线是互补的
- **核心趋势确认**：agent platform 从 single-runtime → multi-runtime，从 developer-only → team-wide，从 feature-building → security/infra hardening。三个头部框架（OpenClaw/hermes/multica）同步经历这个转型

## PR #1273: fix(editor): mention suggestion mousedown click (2026-04-17)

**Issue**: #1039 — mouse click on mention dropdown doesn't insert agent name
**Root cause**: `MentionRow` used `onClick` which fires after editor blur → TipTap suggestion plugin tears down popup before click handler executes
**Fix**: Switch to `onMouseDown` + `preventDefault()` in both button variants (issue row and member/agent row). Well-known TipTap pattern.
**Status**: pending review, CI passed (frontend + backend)
**Scope**: 1 file, 6 lines changed

### 踩的坑
- 无。GitHub API 提交方式上轮已验证，直接复用

### 新发现
- multica frontend CI 有 frontend + backend 两个 job，frontend 约 2.5 分钟
- Vercel docs deploy 需要 team authorization — 外部 PR 会显示 fail，不影响
- cubic-dev-ai 自动 review 但不在这个 repo（只在 VoltAgent 等少数 repo）
- coderabbit 也没有自动 review（不同于 VoltAgent/Archon）

### 下次注意
- 继续用 GitHub API 提交，不要尝试 clone
- multica 没有 coderabbit/cubic 自动 review，review 完全靠维护者人工
- 这是第二个 multica PR，观察 review 时间（第一个 #1249 还在 pending）

## PR #1307: fix(selfhost): disable dev master code by default (2026-04-18)

**Issue**: #1304 — Self-hosted Docker deployments leave 888888 master verification code enabled
**Root cause**: `docker-compose.selfhost.yml` doesn't pass `APP_ENV` to backend container. The `auth.go` check `os.Getenv("APP_ENV") != "production"` always evaluates to true when env is unset.
**Fix**: 
1. Add `APP_ENV: ${APP_ENV:-production}` to backend environment in `docker-compose.selfhost.yml`
2. Add `APP_ENV=production` with documentation to `.env.example`
**Approach**: Minimal config-only fix, no auth.go logic changes. Issue also suggested opt-in `ALLOW_DEV_MASTER_CODE` approach but that's a bigger change for maintainers to decide.
**Status**: pending review, CI all green (backend + frontend)
**Scope**: 2 files, ~4 lines changed

### 经验
- Security issues with clear reproduction and suggested fix = ideal PR targets
- Config-only fixes are low-risk, high-value
- GitHub API commit workflow now well-established for this repo (4th PR)

## v0.2.5 跟进 (2026-04-17)

**Stars**: 15,072 (+3,601 since 04-14) — 持续高增长

### Autopilot 系统

v0.2.5 最大新功能。核心概念：**定时/触发式自动任务执行**。

**数据模型**：
- `Autopilot`: 定义 what+who — title, assignee(agent), priority, execution_mode
- `AutopilotTrigger`: 定义 when — cron/webhook/api, timezone-aware
- `AutopilotRun`: 追踪 execution — status lifecycle: issue_created → running → completed/failed

**两种执行模式**：
- `create_issue` — 创建 issue → assign agent → agent 自主解决
- `run_only` — 直接给 agent 发任务（无 issue 追踪）

**自引用能力**：agent 能通过 CLI 管理 autopilot（list/create/trigger/delete），实现 **agent 自我调度**。
⚠️ 权限问题未解决（PR #1234 follow-up 提到）：agent 创建的 autopilot 无特殊权限检查。

**与我们的对比**：
- multica autopilot ≈ OpenClaw heartbeat + cron 的合体，但更结构化
- 我们用 file-based cron entries + heartbeat polling，multica 用 DB-backed scheduler
- multica 优势：可视化管理（desktop UI）、webhook 触发、运行历史
- 我们优势：零依赖（无需 PostgreSQL）、与消息平台深度集成

### Persistent Daemon Identity (#1220)

UUID identity + legacy-id merge。解决跨 reinstall 的"同一台机器"识别问题。
machine-scoped（#1263）确保 CLI + desktop 共享 identity。

### Runtime 支持扩展

现支持 8 个 runtime: Claude, Codex, Copilot, OpenCode, [[openclaw-architecture]], Gemini, Pi, Cursor。
每个 runtime 写入 native config 文件（CLAUDE.md, AGENTS.md, GEMINI.md）。

### Hermes 同期动态

- dingtalk-stream 0.24+ SDK 适配（async process, oapi webhooks）
- `hermes skills reset` 命令（解决 bundled skills 卡住问题）
- Recraft V3 → V4 Pro 图像生成升级
- claude-opus-4.7 模型支持
- 稳定维护期，无架构变化

### 洞察

1. **autopilot 是 "agent infra" 的自然演进** — 从 "人给 agent 分活" 到 "agent 自己安排活"
2. **agent self-scheduling 的安全问题** multica 主动提出但未解决 — 这是整个行业的共同挑战
3. multica 增长说明 **managed agent platform** 需求强烈，但与 OpenClaw "personal assistant" 定位不直接冲突

## PR #1294: fix ClaimTaskByRuntime for autopilot run_only tasks (2026-04-18)

**Issue**: #1276 — run_only autopilot fails with "execenv: workspace ID is required"
**Root cause**: `ClaimTaskByRuntime` in daemon.go populates `resp.WorkspaceID` from `issue.WorkspaceID` or `cs.WorkspaceID`, but has no `AutopilotRunID` branch. For `run_only` autopilot tasks (no issue, no chat session), workspace_id stays empty → daemon's `execenv.Prepare()` rejects the task.
**Fix**: Add `AutopilotRunID` branch after `ChatSessionID` block, resolving workspace via `autopilot_run → autopilot → workspace_id`. Also populates `resp.Repos` for worktree setup.
**Test**: Added `TestClaimTask_AutopilotRunOnly_PopulatesWorkspaceID`
**Status**: pending review, CI all green
**Related**: Direct follow-up to my PR #1249 (merged) which fixed the auth check path but not the response population path

### 踩的坑
- 无新坑。GitHub API 提交方式已成熟，第三次使用

### 经验
- 同一个 root pattern（missing AutopilotRunID branch）可能出现在多个代码路径 — 修一个要 grep 所有类似路径
- 已有3个 PR: #1249(merged), #1273(pending), #1294(pending) — 接近上限，下轮等消化

## 跟进 2026-04-18: v0.2.5 → v0.2.6

- **#1168 per-agent MCP config**: 解决 #592 strict-mcp-config 后 spawned agents 丢失 MCP access 的问题。新增 `agent.mcp_config` jsonb 列，通过 `--mcp-config <tempfile>` 传给 Claude，并阻止 custom_args 覆盖
- **#1270 Copilot skills native discovery**: 修正 skill 注入路径，从 `.agent_context/skills/` 改到 `.github/skills/<name>/SKILL.md`，符合 Copilot CLI 原生发现规范
- **#1309 open redirect fix**: 验证 `next=` redirect target，防止开放重定向
- **#1313 Docker 安全**: 禁用 dev master code by default
- **趋势**: 平台成熟期——安全加固 + 多 runtime 兼容性修复，不是大的架构变化

## PR #1333: fix(openclaw): remove unsupported --model and --system-prompt flags (2026-04-19)

**Issue**: #1332 — Two bugs in OpenClaw provider: unsupported flags crash tasks + AgentInstructions discarded
**Root cause**: 
- Bug 1: `openclaw.go` forwards `--model` and `--system-prompt` but `openclaw agent` doesn't accept them → exit 1 in ~700ms
- Bug 2: `InjectRuntimeConfig` writes AGENTS.md to task workdir but OpenClaw loads from its own workspace dir → instructions silently lost
**Fix**:
- Remove `--model` and `--system-prompt` from arg construction
- Prepend `opts.SystemPrompt` to `--message` body (OpenClaw receives instructions inline)
- Add both flags to `openclawBlockedArgs` to prevent custom_args bypass
**Status**: pending review, CI all green (backend + frontend)
**Scope**: 1 file, +15/-10

### 经验
- GitHub API 提交方式继续稳定（第6个 multica PR）
- Issue 质量极高（详细 repro + root cause + suggested fix）— 理想的打工目标
- Bug 2 的 fix 选了最简单方案（prepend to message）而非最完整方案（write to workspace dir），因为后者需要 OpenClaw workspace path discovery 逻辑
- `openclawBlockedArgs` 是 defense-in-depth 好模式：即使修了直接调用，也防 custom_args 泄漏

### 下次注意
- 现在有6个 PR (1249 merged, 1273/1294/1307/1328/1333 pending) — 超过上限了，下轮必须等消化
- 考虑在 PR 评论中 @ 维护者（如 ldnvnbl）加速 review

## PR #1333: CLOSED — superseded by maintainer's #1362 (2026-04-20)

**Issue**: #1332 — openclaw provider passing unsupported flags
**Our fix**: Drop unsupported flags + prepend instructions into `--message`
**Why closed**: Our `if opts.SystemPrompt != ""` branch never fires in production because `daemon.go` never populates `opts.SystemPrompt`. Maintainer's #1362 fixed this properly by:
1. Populating `opts.SystemPrompt = instructions` for openclaw provider in `daemon.go` (scoped to avoid double-injection for claude/codex/pi)
2. Extracting `buildOpenclawArgs` helper for testability
3. Adding unit tests

**Lesson**: Always trace the data flow end-to-end. We fixed the consumer but didn't check whether the producer actually sent data. `grep` for the field across the codebase before assuming it's populated.

## PR #1328: Review response (2026-04-20)

Addressed Bohan-J's review:
- Added `owner_id` scoping to both adoption queries (must-fix)
- Zero OwnerID guard: skip adoption for daemon-token auth
- Added `agents_adopted` to task failure log
- Isolated test provider name (`claude-adopt-test`)
Awaiting re-review.

## PR #1377: Board card description fix (2026-04-20)

**Issue**: #1375 — Board cards don't show description even when Description property is enabled
**Root cause**: `ListIssues` and `ListOpenIssues` SQL queries omitted `description` column. API response always had null description → client never rendered it.
**Fix**: Added `description` to both SQL queries, generated Go structs/Scan calls, and response mapping functions. 10 insertions, 4 deletions across 3 files.
**CI**: Backend + frontend passed. No review feedback yet.
**Status**: PENDING

### Notes
- sqlc-generated code (`issue.sql.go`) can be manually edited — just follow the exact pattern (struct field + Scan order + SQL column position)
- Go 1.26.1 required — our local Go is 1.24.4, can't build locally. Rely on CI.
- Bohan-J does thorough reviews with must-fix/nice-to-have tiers. PR template is informal (no mandatory sections).

## v0.2.7 Release (2026-04-20)

> ★17,309 (04-20) | +2,237 since first check (15,072 on 04-19)

增量发布，无架构变化：
- `feat`: configurable pgxpool size（默认 sane defaults），multi-select autopilot weekly triggers，hourly desktop update poll，create sub-issue from selected text，ALLOW_SIGNUP + email allowlist for selfhost
- `fix`: OpenClaw AgentInstructions delivery，session resume pointer，cookie Secure flag from scheme，infinite re-render loops，stale --parent UUID reuse
- 观察：selfhost 功能快速完善（auth gating + .env.example 文档化），与 [[openclaw]] 在自托管方向竞争加剧
