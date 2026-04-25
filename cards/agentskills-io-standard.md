---
title: agentskills.io 标准规范
slug: agentskills-io-standard
tags: [agent-ecosystem, standards, skills, infrastructure]
created: 2026-04-25
---

# agentskills.io 标准规范

Agent Skills 的事实标准，定义了跨 agent 的 skill 格式。

## 规范要点

### SKILL.md Frontmatter

| 字段 | 必填 | 说明 |
|------|------|------|
| `name` | ✅ | 1-64 chars, lowercase + hyphens, 必须匹配目录名 |
| `description` | ✅ | 1-1024 chars, 描述功能 + 触发条件 |
| `license` | ❌ | 许可证名称或文件引用 |
| `compatibility` | ❌ | 1-500 chars, 环境要求 |
| `metadata` | ❌ | 扁平 string→string map |
| `allowed-tools` | ❌ | 空格分隔的预授权工具列表（实验性）|

### 目录结构

```
skill-name/
├── SKILL.md          # 必须：metadata + instructions
├── scripts/          # 可选：可执行代码
├── references/       # 可选：参考文档
├── assets/           # 可选：模板、资源
```

### Progressive Disclosure（三层）

1. **Metadata** (~100 tokens)：启动时加载所有 skill 的 name + description
2. **Instructions** (<5K tokens 推荐)：skill 激活时加载 SKILL.md body
3. **Resources** (按需)：scripts/references/assets 只在需要时加载

## 采纳现状（2026-04-25）

已采纳的主流 agent：Cursor、VS Code Copilot、Gemini CLI、Goose、Amp、OpenHands、Letta、Junie (JetBrains)、OpenCode、Firebender、Mux (Coder)、Autohand

## 与 ClawHub/OpenClaw 兼容性

**95% 兼容**，差异极小：
- ClawHub 有 `version` first-class 字段 → agentskills.io 无（放 metadata 里），不冲突
- ClawHub `metadata` 允许嵌套对象 → agentskills.io 规定 flat string→string，不严格兼容但实际无影响
- agentskills.io 有 `license`/`compatibility`/`allowed-tools` → ClawHub 可选加入

**结论**：ClawHub 不需要大改即可完全兼容。保持兼容是正确策略——skill 格式已收敛，差异化应聚焦分发层（版本管理、依赖解析、安全审计）。

## 生态位

agentskills.io 解决的是 **skill 格式标准化**，不解决 skill 发现和分发。这正是 ClawHub 的机会——做 agent skill 的 npm registry。

## 链接

- [[agent-skill-standard-convergence]] — 三层标准化趋势
- [[mercury-agent]] — 采纳 agentskills.io 的 soul-driven agent
