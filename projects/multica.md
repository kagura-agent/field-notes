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
