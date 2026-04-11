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

Claude Code, Codex, [[OpenClaw]], OpenCode — 把自己定位为 runtime-agnostic 管理层。

## 与 OpenClaw 的关系

**竞品+互补**:
- multica 专注 **agent as managed worker**（任务板、进度追踪、团队协作）
- [[OpenClaw]] 专注 **agent as personal assistant**（消息路由、多平台、生活集成）
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
