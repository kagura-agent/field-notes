# Claude Code Plugin 系统研究笔记

> 源码版本：2026-04 读码分析
> 最后更新：2026-04-14

---

## 架构概览

Plugin 系统是 Claude Code 的扩展机制——通过 marketplace 分发，支持 skills、hooks、MCP servers、agents、output styles 等多种组件。

```
Plugin 架构：

  Marketplace（GitHub repo / URL / npm / local）
       │
       ↓
  known_marketplaces.json ←→ reconciler（自动同步）
       │
       ↓
  PluginInstallationManager（后台安装，不阻塞启动）
       │
       ↓
  LoadedPlugin → skills / hooks / MCP servers / agents / output-styles
```

---

## Plugin 定义

### LoadedPlugin 核心字段

| 字段 | 类型 | 说明 |
|---|---|---|
| name | string | 插件名 |
| manifest | PluginManifest | 插件清单 |
| path | string | 安装路径 |
| source | string | 来源标识 |
| repository | string | 所属 marketplace |
| enabled | boolean | 是否启用 |
| isBuiltin | boolean | 是否内置 |
| sha | string | Git commit SHA（版本锁定） |

### Plugin 组件（5 种）
1. **commands** — 自定义命令（`/plugin-name`）
2. **agents** — 自定义 agent 类型
3. **skills** — SKILL.md 格式的能力
4. **hooks** — 生命周期钩子
5. **output-styles** — 输出样式

---

## 两类 Plugin

### 1. Built-in Plugins（内置）
- 随 CLI 发布，ID 格式：`{name}@builtin`
- 用户可在 `/plugin` UI 中启用/禁用
- 状态持久化到 user settings
- 通过 `registerBuiltinPlugin()` 注册
- 有 `isAvailable()` 检查（按系统能力决定是否显示）
- 有 `defaultEnabled` 字段

### 2. Marketplace Plugins（市场）
- 从 marketplace 安装，ID 格式：`{name}@{marketplace}`
- 支持多种来源：GitHub repo、URL、npm、本地目录
- 版本通过 Git SHA 锁定

---

## Marketplace 系统

### 官方 Marketplace
- 仓库：`anthropics/claude-plugins-official`（GitHub）
- 常量：`OFFICIAL_MARKETPLACE_NAME = 'claude-plugins-official'`
- 有 GCS 加速下载路径（`officialMarketplaceGcs.ts`）

### 文件结构
```
~/.claude/
  └── plugins/
      ├── known_marketplaces.json    ← marketplace 配置
      └── marketplaces/              ← 缓存目录
          ├── my-marketplace.json    ← URL 来源
          └── github-marketplace/    ← GitHub 来源（git clone）
              └── .claude-plugin/
                  └── marketplace.json
```

### Reconciler（自动同步）
- `diffMarketplaces()` — 比较 settings 声明和 known_marketplaces.json 实际状态
- `reconcileMarketplaces()` — 自动安装缺失的、更新源变更的
- 支持相对路径解析（`./path` 在项目 settings 中）
- Git worktree 路径规范化（`findCanonicalGitRoot`）

### 安装流程
1. 启动时 `PluginInstallationManager` 后台运行
2. `diffMarketplaces()` 计算差异
3. 缺失的 → 自动安装（git clone / download）
4. 源变更的 → 更新
5. 新安装 → 自动 refresh plugins
6. 仅更新 → 设 `needsRefresh`，提示用户 `/reload-plugins`
7. UI 显示安装进度（pending → installing → installed/failed）

### Marketplace Source 类型
- `github` — Git 仓库（clone）
- `url` — JSON 文件（HTTP fetch）
- `npm` — npm 包
- `local` / `directory` — 本地路径
- 有 allowlist/blocklist 安全策略

---

## Hook 系统

Plugin 可以提供 hooks：
- 生命周期钩子（启动、工具调用前后、compact 后等）
- 通过 `HooksSettings` 配置
- 与 permission 系统集成

---

## 安全

- **Policy allowlist**：管理员可限制允许的 marketplace 来源
- **Blocklist**：阻止特定来源
- **SHA 锁定**：marketplace entry 可指定 commit SHA
- **isAvailable()** gate：built-in plugin 可按系统能力隐藏

---

## 对比分析：Claude Code Plugins vs OpenClaw Plugins

| 维度 | Claude Code | OpenClaw |
|---|---|---|
| **分发** | Marketplace（GitHub/URL/npm/local） | npm plugin + ClawHub skills |
| **安装** | `/plugin marketplace add` + `/plugin install` | `openclaw plugins install` / `clawhub install` |
| **组件类型** | 5 种（commands/agents/skills/hooks/output-styles） | plugin hooks + skills 分离 |
| **内置 vs 市场** | `@builtin` vs `@marketplace` 明确区分 | 无明确区分 |
| **自动同步** | reconciler 自动安装/更新 | 无自动更新 |
| **版本** | Git SHA 锁定 | npm semver |
| **官方 Marketplace** | anthropics/claude-plugins-official | ClawHub (clawhub.ai) |
| **安全** | allowlist/blocklist + policy | 无 |

### OpenClaw 的优势
- Plugin 和 Skill 分离（关注点清晰）
- ClawHub 有完整的 search/install/update/publish 流程
- npm semver 语义化版本（vs Git SHA 不透明）

### Claude Code 的优势
- **统一的 Plugin 容器**：一个 plugin 可以同时提供 skills + hooks + MCP + agents
- **Reconciler 自动同步**：不需要手动更新
- **多来源支持**：GitHub/URL/npm/local 任选
- **Built-in 可禁用**：用户可以关掉不想要的内置功能
- **后台安装不阻塞**：启动时后台装，不影响交互

---

## 可借鉴的设计

1. **Plugin = 组件容器**：一个 plugin 可以同时提供 skill + hook + MCP。OpenClaw 目前 skill 和 plugin 分离，可以考虑统一
2. **Reconciler 自动同步**：settings 声明了 marketplace → 自动确保本地有。减少手动 install 步骤
3. **Built-in 可禁用**：内置功能不强制——用户可以关掉不需要的。OpenClaw 可以让 built-in skills/plugins 有 enable/disable
4. **后台安装**：plugin 安装不阻塞启动。重启后台装，装完自动生效
5. **SHA 锁定**：marketplace entry 指定 commit hash = 可复现安装。比"latest"更安全

---

## v2.1.101 跟进 (2026-04-11)

v2.1.101 是一个大版本，2026-04-10 发布。关键变化：

### 与 OpenClaw 相关的变化

1. **`/team-onboarding` 命令**：从本地使用数据生成团队 ramp-up guide。说明 Claude Code 在推 enterprise 方向。OpenClaw 目前没有类似的 onboarding 自动化
2. **OS CA 证书信任**：默认信任系统 CA store，企业 TLS proxy 开箱即用。`CLAUDE_CODE_CERT_STORE=bundled` 回退。OpenClaw 在企业部署时也会遇到这个问题
3. **`/ultraplan` 自动建环境**：不再要求先去 web 设置，自动创建 cloud env。降低 friction 的好设计
4. **Plugin hooks 改进**：force-enabled plugin hooks 现在在 `allowManagedHooksOnly` 时也能运行。说明 managed settings (MDM) 是他们正在推的企业特性
5. **SDK `query()` 资源清理**：consumer break from `for await` 时正确清理子进程和临时文件。`await using` 支持说明他们在用 TC39 Explicit Resource Management
6. **修复 `permissions.deny` 被 hook 覆盖的 bug**：之前 PreToolUse hook 的 `permissionDecision: "ask"` 能降级 deny rule。这是个安全 bug，说明 hook 权限模型有设计缺陷

### 安全相关

7. **命令注入修复**：POSIX `which` fallback 的命令注入。LSP binary detection 路径
8. **#46452 rm -rf /* 事件**：用户报告 Claude Code 因 SSH 变量转义错误在生产 VPS 执行了 `rm -rf /*`。标记为 bug+security+data-loss。这是 agent coding 工具的噩梦场景

### 架构洞察

9. **Memory leak 修复**：长 session 在 virtual scroller 中保留了几十份历史消息列表拷贝。说明他们用了 virtual scroll 来渲染对话，且内存管理是痛点
10. **`--resume` 链恢复**：修了好几个 resume 相关 bug（死链、subagent 串话、文件路径丢失）。说明对话持久化和恢复是个复杂的工程问题
11. **Bash 异步执行 bug (#46527)**：所有 Bash 命令异步执行无法 opt-out。如果属实，这是个大问题——顺序执行是很多脚本的前提

### 反直觉发现

- Claude Code 的 enterprise 方向越来越明显（MDM templates、managed settings、team onboarding）。OpenClaw 是 personal-first，这是差异化方向
- `rm -rf /*` 事件说明即使有权限系统，agent coding 仍有灾难性风险。OpenClaw 的 sandbox 策略更保守但更安全
- 一个 release 修了 30+ bugs，说明 Claude Code 迭代速度极快但质量压力也大

## v2.1.105 重大更新 (2026-04-13)

### 新功能
1. **`monitors` manifest key** — 插件可声明 background monitors，session 启动或 skill invoke 时自动 arm。这是 event-driven background monitoring 的标准化——类似 [[gbrain]] 的 watch_patterns 和 [[hermes-agent]] 的 watch_patterns，但作为 plugin primitive 内建
2. **PreCompact hook** — hooks 可以通过 exit code 2 或 `{"decision":"block"}` 阻止 compaction。**重要的 memory preservation primitive**——跟我们的 dreaming promote 理念相通（保留重要记忆不被压缩）
3. **EnterWorktree `path` 参数** — 可直接切换到已有 worktree
4. **`/proactive` = `/loop` alias** — proactive agent 概念继续推进
5. **Skill description cap 250→1536 chars** — skill 可以有更丰富的描述（呼应 skill lazy-loading 讨论——更长描述 = 更精准的 skill 路由）

### 改进
- Stalled API stream 5 分钟超时 + non-streaming retry（跟我们遇到的 Copilot API 60s 超时是同类问题）
- WebFetch 剥离 `<style>` 和 `<script>` 内容（CSS-heavy 页面不再吃完 content budget）
- Stale agent worktree cleanup（squash-merged PR 的 worktree 不再永久保留）
- `/doctor` layout 改进 + press `f` 让 Claude 自动修复

### 与我们的关联
- **monitors** 标准化了 background agent 监控——OpenClaw 的 cron/heartbeat/nudge 是更早的类似实现
- **PreCompact hook** 是 memory management 的新 primitive。我们的 dreaming promote 在更高抽象层做类似的事（选择性保留记忆），但 PreCompact 是在 context window 级别操作
- **Skill description 1536 chars** 直接影响我们的 skill lazy-loading PR（#65139）——更长描述意味着更好的路由精度，但也意味着更多 context 占用。验证了 lazy-loading 的价值

### 趋势信号
- Agent 从 "CLI tool" 走向 "always-on runtime"：monitors + worktree cleanup + PreCompact 都是长期运行 agent 需要的基础设施
- Memory management 成为竞争维度：PreCompact hook 让插件控制 compaction = 开放 memory 管理给社区
