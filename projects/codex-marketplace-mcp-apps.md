# Codex Marketplace + MCP Apps 架构演进

> 跟进日期: 2026-04-11 | Repo: openai/codex | 版本: main (Apr 11)

## 核心发现

### Marketplace（插件分发系统）
- **`codex marketplace add`** — 从 GitHub/本地/git URL 安装 marketplace
- 存储路径: `$CODEX_HOME/marketplaces/<name>/`
- marketplace 是 git repo，核心文件: `.agents/plugins/marketplace.json`
- 每个 plugin 有三层策略:
  - **InstallPolicy**: NOT_AVAILABLE / AVAILABLE / INSTALLED_BY_DEFAULT
  - **AuthPolicy**: ON_INSTALL / ON_USE
  - **Products**: 产品分级（Codex 不同版本可见性不同）
- 支持 sparse checkout（大 marketplace 按需拉取）
- Staging → replace 的原子安装（不会出现半装状态）

### MCP Apps（三部曲，2026-03~04 完成）
1. **Part 1** (#16082, merged): `mcpResource/read` — MCP 服务器可以暴露 resources 给 agent 读
2. **Part 2** (#16465, merged): tool call result 携带 metadata — 调用结果可以带结构化附加信息
3. **Part 3** (#17364, merged Apr 11): **MCP Apps 可以调用自己的 MCP server tools** — 形成闭环
- 还有 OAuth 登录流: MCP server 可以要求 OAuth 授权再使用

### 相关 PR
- #17406: MCP tool wall time tracking（性能监控）
- #17404: namespace 注册所有 MCP tools（命名空间隔离）
- #13433: 早期 `track plugins mcps/apps and add plugin info to user_instructions`
- #10584: `approve and remember MCP/Apps tool usage`（approval 记忆）

## 架构洞察

### Plugin 即 MCP Server
Codex 的 plugin = MCP server + manifest + marketplace metadata。不是独立的 plugin 格式，而是把 MCP 协议作为 plugin 的通信层。这意味着：
- 任何 MCP server 都可以变成 Codex plugin
- Marketplace 只是 discovery + policy 层
- 实际能力完全由 MCP server 提供

### 反直觉发现
- Marketplace 用 git 做分发，不是 npm/pip 那样的 registry。好处：version control 天然自带，坏处：没有 search/discovery API
- AuthPolicy 分 ON_INSTALL 和 ON_USE — ON_USE 意味着 plugin 可以免安装先用、用时才授权。这对 agent-as-router 场景很关键：agent 可以先发现工具再决定是否授权
- Product gating 是 TODO 状态（代码注释里说 "Surface or enforce product gating at the Codex/plugin consumer boundary"）— 说明多产品线策略还在早期

## 与我们的关联

### 验证北极星
- **agent-as-router**: Codex marketplace = tool discovery + policy，MCP Apps = tool integration protocol。这正是 北极星 里预测的"agent 找到合适工具帮你办事"
- **工具碎片化悖论**: marketplace 的 INSTALLED_BY_DEFAULT 策略是一种回应——不让用户选择困难，直接预装
- **skill 生态爆发**: marketplace + .skill + MCP = 三层分发（能力分发、行为分发、协议分发）

### 对 OpenClaw 的启示
- OpenClaw 的 skill 系统（SKILL.md + scripts/）类似 marketplace plugin 但更轻量
- 如果 OpenClaw 要做 marketplace，可以参考 Codex 的 git-based 分发 + policy 层
- MCP Apps 的 "调用自己的 MCP server" 能力 = agent 内部工具组合，比 OpenClaw 当前的 exec 调用更结构化

### 与 [[skill-ecosystem]] 的关系
- .skill 文件 = 行为层（怎么用工具）
- MCP server = 能力层（工具本身）
- marketplace = 发现层（找到工具）
- 三者正在收敛：[[claude-code-skills]] + MCP + marketplace

## 待跟进
- [ ] Codex marketplace manifest 格式详细规格
- [ ] MCP Apps Part 3 后的生态变化（会不会出现 marketplace plugin 直接组合 MCP tools 的模式？）
- [ ] Claude Code 的 plugin 系统是否在做类似演进？

## First seen
2026-04-11, study followup → deep_read (FlowForge #115)
