---
title: Claude Code Plugin 系统 vs Codex Marketplace 对比分析
created: 2026-04-11
source: 'claude-code-plugins.md + codex-marketplace-mcp-apps.md + web research'
modified: 2026-04-11
---

# Claude Code Plugin 系统 vs Codex Marketplace

两家都在 2026 Q1 推出了 plugin/marketplace 系统，但架构哲学、分发模型和安全策略有显著差异。

## 架构对比

| 维度 | Claude Code | Codex |
|---|---|---|
| **Plugin 容器** | 统一容器：一个 plugin 可含 skills + agents + hooks + MCP + commands + output-styles（6 种组件） | 统一容器：skills + MCP servers + app integrations 打包 |
| **分发协议** | Git-based marketplace（GitHub repo / URL / npm / local） | Git-based marketplace（GitHub / local / git URL） |
| **官方 marketplace** | `anthropics/claude-plugins-official`（55+ curated + 72+ 社区） | OpenAI 内置 Plugin Directory（app 内浏览） |
| **安装方式** | `/plugin marketplace add` → `/plugin install name@marketplace` | `codex marketplace add` → `codex plugin install`（或 `/plugins` 命令） |
| **版本控制** | Git SHA 锁定 | Git SHA 锁定 |
| **存储位置** | `~/.claude/plugins/cache/` | `$CODEX_HOME/marketplaces/<name>/` |
| **自动更新** | Reconciler 自动同步（启动时 diff + 后台安装） | Staging → replace 原子安装 |
| **安装阻塞** | 不阻塞启动（后台安装） | 不阻塞（staging 模式） |

## 关键差异

### 1. 组件丰富度：Claude Code 更完整

Claude Code 的 plugin 支持 6 种组件类型（skills、agents、MCP servers、hooks、commands、output-styles），形成从"代码分析"到"工作流自动化"的完整链条。

Codex 的 plugin 聚焦 3 种（skills、MCP servers、app integrations），更精简但组合能力更弱。没有 hooks（生命周期钩子）和 agents（子 agent），意味着 plugin 不能在工具调用前后触发逻辑，也不能委托子任务。

**启示：** Hook 系统是 Claude Code 的差异化——允许 plugin 在 agent 生命周期中注入逻辑（保存后自动验证、编译后自动测试等）。OpenClaw 的 nudge plugin 就是类似设计。

### 2. 安全模型：Codex 三层策略更精细

Codex 有独特的三层策略系统：
- **InstallPolicy**: NOT_AVAILABLE / AVAILABLE / INSTALLED_BY_DEFAULT
- **AuthPolicy**: ON_INSTALL / ON_USE（用时授权 = 先发现再决定）
- **Products**: 产品分级（不同 Codex 版本可见性不同）

Claude Code 安全靠 allowlist/blocklist + SHA 锁定 + enterprise MDM：
- `strictKnownMarketplaces`：只允许已知 marketplace
- Anthropic Verified badge：人工审核标记
- `allowManagedHooksOnly`：企业管理员控制 hook 权限

**启示：** Codex 的 ON_USE AuthPolicy 对 agent-as-router 场景非常关键——agent 可以先发现所有可用工具，用到时才弹授权。这比"安装时一次性授权所有能力"更符合最小权限原则。

### 3. 生态规模：Claude Code 当前领先

| 指标 | Claude Code | Codex |
|---|---|---|
| 官方 plugins | 55+ | ~20+（app 内目录） |
| 社区 plugins | 72+（wshobson/agents 单个 marketplace） | 增长中（awesome-codex-plugins 列表） |
| MCP 生态 | 5000+ servers（2000+ 在官方 registry） | 共享同一个 MCP 生态 |
| 语言覆盖 | 11 种 LSP plugins | 无 LSP 层 |

但 Codex 的 MCP Apps 三部曲（resource read → metadata → tool self-call）技术上更前沿——plugin 的 MCP server 可以调用自己的 tools，形成闭环。Claude Code 的 MCP 集成相对静态。

### 4. Enterprise 方向：两家都在推但路径不同

Claude Code：MDM templates、managed settings、`/team-onboarding`、allowlist 策略 → 自上而下的企业管控

Codex：Product gating（TODO 状态）、marketplace allowlist → 还在早期，但 API-first 的企业 feature 更多

### 5. 分发哲学：都选了 Git，但原因不同

两家都用 Git 做 marketplace 分发（不是 npm/pip registry），这是有意设计：
- **版本控制天然自带**（diff、blame、rollback）
- **审计友好**（谁改了什么一目了然）
- **离线可用**（clone 后不依赖中心服务）
- **缺点**：没有 search/discovery API，需要额外的 UI 层

对比 ClawHub（OpenClaw）用 npm 语义化版本 + 集中式 registry：搜索体验好，但缺乏 Git 的审计能力。

## 对 OpenClaw Skill 分发的启示

### 值得借鉴

1. **Plugin = 组件容器**：OpenClaw 当前 skill 和 plugin 分离，可以考虑统一——一个 skill 包同时提供 SKILL.md + hooks + MCP config
2. **Reconciler 自动同步**：settings 声明依赖 → 自动确保本地有。减少 `clawhub install` 手动步骤
3. **ON_USE 授权**：发现和安装分离，用到时才授权。对 agent-as-router 场景很关键
4. **Built-in 可禁用**：让用户关掉不需要的内置 skill，而不是全加载
5. **后台安装**：不阻塞 agent 启动

### OpenClaw 的独特优势

1. **Personal-first**：Claude Code 和 Codex 都在推 enterprise，OpenClaw 走 personal companion 路线，skill 可以更贴个人场景（家庭管家、个人记忆）
2. **Skill 和 Plugin 分离**：关注点清晰（SKILL.md = 行为、plugin = 能力），虽然统一有好处但分离也有好处——skill 作者不需要写代码
3. **ClawHub 搜索体验**：npm registry 模式在 discovery 上比 Git marketplace 更好
4. **轻量级 skill**：一个 SKILL.md 文件就是一个 skill，不需要 plugin.json manifest + 目录结构

### 收敛趋势

三层正在收敛：
- **行为层**（怎么用工具）：Claude Code skills ≈ Codex skills ≈ OpenClaw SKILL.md
- **能力层**（工具本身）：MCP servers（三家共享生态）
- **发现层**（找到工具）：marketplace（Git-based）/ registry（npm-based）/ directory（app 内置）

最终赢家取决于生态密度 × 安全信任。目前 Claude Code 生态密度领先，Codex 安全模型更精细，OpenClaw 在个人场景的深度上有机会。

## 待验证

- [ ] Codex Product gating 实装后的多产品线策略
- [ ] Claude Code plugin 生态的恶意 plugin 比例（ClawHub 是 6.9%，Claude Code 呢？）
- [ ] OpenClaw 是否应该引入 Git-based marketplace 模式（vs 保持 npm ClawHub）
