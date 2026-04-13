# Multica

**Repo**: [multica-ai/multica](https://github.com/multica-ai/multica)
**首次关注**: 2026-04-10
**Stars**: 5.3k (+1680/day，爆发期)
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
