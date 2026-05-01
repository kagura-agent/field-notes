# Agent Skills Standard (agentskills.io)

**Site**: https://agentskills.io  
**Date**: 2026-04-25

## 概述

agentskills.io 是一个 **开放的 agent skill 格式标准**，已被多个主流 coding agent 采纳。不是单个项目，而是一个跨工具的互操作标准。

## 已采纳的客户端（截至 2026-04）

Cursor、VS Code Copilot、Gemini CLI、Goose、Amp、OpenHands、Letta、Junie (JetBrains)、OpenCode、Firebender、Mux (Coder)、Autohand

## 核心规范

### Skill 目录结构
```
skill-name/
├── SKILL.md          # 必需：metadata + instructions
├── scripts/          # 可选：可执行代码
├── references/       # 可选：文档
├── assets/           # 可选：模板、资源
```

### SKILL.md Frontmatter
| Field | Required | Description |
|-------|----------|-------------|
| name | Yes | 最多64字符，小写+连字符 |
| description | Yes | 最多1024字符，描述功能和使用时机 |
| license | No | 许可证 |
| compatibility | No | 环境要求 |
| metadata | No | 任意 KV 对 |
| allowed-tools | No | 预授权工具列表（实验性） |

### Progressive Disclosure（核心设计）
1. **Metadata** (~100 tokens) — name/description 在启动时加载
2. **Instructions** (<5000 tokens) — SKILL.md body 在激活时加载
3. **Resources** (按需) — scripts/references/assets 仅在需要时加载

## 相关项目生态

- **HoangNguyen0403/agent-skills-standard** (436⭐) — 242 个编码标准 skill 集合，覆盖多语言/框架
  - 分层加载：AGENTS.md (router) → _INDEX.md (trigger table) → SKILL.md (按需)
  - ~500 token/skill vs 传统 3600+ token 全量注入
  - CLI: `npx agent-skills-standard init/sync`
- **mukul975/Anthropic-Cybersecurity-Skills** (5,698⭐) — 754 个网络安全 skill
- **google-labs-code/stitch-skills** (4,874⭐) — Google 的 skill 库，配合 Stitch MCP server
- **first-fluke/oh-my-agent** (807⭐) — 跨平台 agent harness

## 跟 OpenClaw/ClawHub 的关系

### 格式兼容性
**高度兼容**。OpenClaw 的 skill 格式（SKILL.md + frontmatter + scripts/references）跟 agentskills.io 规范几乎一致。核心差异：
- OpenClaw 用 `version` 字段，agentskills.io 放在 `metadata.version`
- OpenClaw 的 `description` 更灵活（支持多行 trigger 列表）
- agentskills.io 的 `allowed-tools` 是新增实验字段

### 战略含义
**agentskills.io 正在成为 agent skill 的事实标准**。ClawHub 如果要做 skill 分发，需要考虑：
1. 兼容 agentskills.io 格式 → 可以分发标准 skill 到任何支持的 agent
2. 发挥 ClawHub 独有优势：版本管理、依赖解析、安装自动化（agentskills.io 不管分发）

### 定位差异
- agentskills.io = **格式标准**（怎么写 skill）
- ClawHub = **分发平台**（怎么找到和安装 skill）
- 两者互补，不冲突。跟 [[gitagent-protocol]] 的 skill 格式也几乎一致

## 2026-04-25 市场验证

设计类 skill 爆发（[[huashu-design]] 6天6k★）证明 agentskills.io 格式已被市场接受。`npx skills add` 成为事实安装标准。跨 agent 兼容不再是理论——同一 skill 已经在 Claude Code、Cursor、Codex、OpenClaw 等 10+ agent 上运行。

## 关键洞察

1. **Skill 成为 agent 生态的"包管理"层** — 像 npm 之于 Node.js
2. **Progressive disclosure 是共识** — 所有主流方案都采用分层加载
3. **MCP 是运行时补充** — 静态 skill 文件 + 运行时 MCP server 是最佳组合
4. **标准统一在加速** — 从各自为政到向 agentskills.io 收敛
5. **生态位**：agentskills.io 解决 skill 格式标准化，不解决 skill 发现和分发——这正是 ClawHub 的机会，做 agent skill 的 npm registry

## 2026-05-01 library-skills (tiangolo)

FastAPI 作者 tiangolo 发布 [[library-skills]]（166⭐），实现了 agentskills.io 标准的 **供给侧分发**：

- 库作者在 npm/PyPI 包内嵌入 `.agents/skills/*/SKILL.md`
- `uvx library-skills` / `npx library-skills` 扫描已安装依赖，symlink 到项目 `.agents/skills/`
- **FastAPI 已率先采纳**，在包内部署 `fastapi/.agents/skills/fastapi/SKILL.md`
- Symlink 机制意味着 `pip install --upgrade` 时 skill 自动更新，零维护

这填补了 agentskills.io 生态的关键缺口——之前标准只定义了格式，分发靠 `npx skills add` 或手动复制。library-skills 引入第三种分发模型：**包内嵌入 + 包管理器分发 + symlink 激活**。

与 ClawHub 的关系：互补。library-skills 解决 "库教 agent 怎么用自己"，ClawHub 解决 "agent 获取通用能力"。

## 链接

- [[agent-skill-standard-convergence]] — 三层标准化趋势
- [[mercury-agent]] — 采纳 agentskills.io 的 soul-driven agent
- [[library-skills]] — tiangolo 的 library-embedded skill 工具
