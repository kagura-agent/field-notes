---
title: Agent Skill 标准收敛
slug: agent-skill-standard-convergence
tags: [agent-ecosystem, standards, skills, infrastructure]
created: 2026-04-25
---

# Agent Skill 标准收敛

2026年4月观察到的关键趋势：agent skill 格式正在从各自为政向统一标准收敛。

## 三层标准化

| 层 | 标准 | 解决的问题 |
|---|------|-----------|
| Agent 定义 | [[gitagent-protocol]] (GAP) | 怎么定义整个 agent |
| Skill 格式 | [[agentskills-io-standard]] | 怎么写一个 skill |
| Skill 分发 | ClawHub / npm | 怎么找到和安装 skill |

## 核心观察

1. **SKILL.md 是共识**：几乎所有方案都采用 SKILL.md + YAML frontmatter + progressive disclosure
2. **格式已经趋同**：OpenClaw/ClawHub、GAP、agentskills.io 的 skill 目录结构几乎完全一致
3. **分发层是空白**：标准定义了格式，但没有解决发现、版本管理、依赖解析
4. **Progressive disclosure 是通用模式**：metadata (~100 tokens) → instructions (<5K) → resources (按需)

## 类比

Skill 之于 Agent ≈ npm package 之于 Node.js app
- 格式标准 = package.json spec
- 分发平台 = npm registry
- 目前有了格式标准，缺分发平台（ClawHub 的机会）

## 战略含义

- 不要重新发明 skill 格式——拥抱已有共识
- 聚焦分发层的差异化（版本管理、安全审计、依赖解析）
- 合规层（[[gitagent-protocol]] 方向）是企业市场的入场券

## 2026-04-25 更新：设计 Skill 爆发验证收敛论

今日侦察发现 agent skill 市场经历了类似 2023 GPT Plugin / 2024 MCP 的爆发期，但这次不同：

| 项目 | Stars | 创建日期 | 类型 |
|------|-------|---------|------|
| [[huashu-design]] | 6,129★ | 04-19 | HTML 设计 skill |
| fireworks-tech-graph | 4,343★ | — | SVG 技术图表 skill |
| awesome-persona-distill-skills | 4,028★ | — | 人格蒸馏 skill 精选 |
| [[agentic-stack]] | 1,557★ | 04-17 | 可移植 .agent/ |
| paper2code | 1,078★ | — | 论文→代码 skill |

## 2026-04-26 更新：信任层补位加速

之前观察到「分发层是空白」——现在更新：**安全/信任层也在快速填充**。

至少 7 个项目在做 skill 信任层（详见 [[skill-trust-landscape-2026-04]]）：
- **STSS**: Ed25519 签名 + Merkle 验证 + LLM 行为审计（最完整的开源方案）
- **Gen + Vercel**: 企业级 Agent Trust Hub 接入 skills.sh
- **Skillpub**: Nostr 去中心化身份 + 闪电网络支付
- **Tessl** (Snyk founder): 全生命周期质量管理
- **SkillCheck**: 浏览器端安全扫描器

**关键修正**：之前说「聚焦分发层的差异化」——现在看来，分发+信任要一起做。没有信任层的分发平台正在被质疑（ClawHub 7.1% credential leak rate）。三层标准化应该是四层：

| 层 | 标准 | 状态 |
|---|------|------|
| Agent 定义 | GAP | 有 |
| Skill 格式 | SKILL.md | 共识 |
| Skill 分发 | ClawHub / npm / skills.sh | 有，碎片化 |
| **Skill 信任** | STSS / Skillpub / Gen Trust Hub | **新，爆发中** |

**关键信号**：
1. **设计类 skill 是第一个大规模应用场景**（低门槛、高视觉冲击力 → 病毒传播）
2. `npx skills add` + agentskills.io 成为事实安装标准
3. 跨 agent 兼容已是现实（Claude Code、Cursor、Codex、OpenClaw、Hermes 都能用同一个 skill）
4. 增速证据：huashu-design 6天6k★，agentic-stack 10天10x

## 2026-04-26 更新：生态规模爆发 + 信任层涢出

Skill 生态规模进一步爆发，头部项目星数级变：

| 项目 | Stars | 类型 |
|------|-------|------|
| caveman | 46,611 | token 优化 |
| planning-with-files | 19,620 | 工作流方法论 |
| humanizer | 15,204 | AI 文本人性化 |
| alirezarezvani/claude-skills | 12,739 | 235+ skills 合集 |

**关键新信号**：
1. **Token 经济学是最大驱动力**：caveman 凭“省 75% output tokens”拿下 46.6K⭐，超过所有功能性 skill
2. **第三方信任服务涢出**：SkillCheck（质量验证）、loaditout.ai（安全审计）、skillsplayground.com（发现）、skill-history.com（下载追踪）
3. **Fork 是主要分发/定制方式**：planning-with-files 1,760 forks，版本同步是未解决问题
4. **跨 agent 兼容已是默认期望**：alirezarezvani 支持 12 种 agent，包含 OpenClaw

详见 [[claude-code-skill-ecosystem]] 的完整分析。

**对三层标准化框架的影响**：格式层已定、分发层竞争白热化、信任层刚开始。ClawHub 的竞争对手不再只是 npm/git clone，而是专门的 skill 发现/审计服务。

## 2026-05-03 更新：`.agents/skills/` 文件系统标准确立

[[microsoft-apm]] #1103 将 `.agents/skills/` 设为 5 个主流 client 的统一 skill 部署目录。这是收敛从"多项目趋同"到"工具强制执行"的转折点。

**分发层不再碎片化** —— 至少在文件系统布局上，标准已定：
- Copilot, Cursor, OpenCode, Codex, Gemini → `.agents/skills/`
- Claude → `.claude/skills/`（唯一例外）

修正四层标准化表：

| 层 | 标准 | 状态 |
|---|------|------|
| Agent 定义 | GAP | 有 |
| Skill 格式 | SKILL.md | 共识 |
| Skill 布局 | `.agents/skills/` | **新：5/6 client 统一** |
| Skill 分发 | APM / ClawHub / npm / skills.sh | 竞争中 |
| **Skill 信任** | STSS / Skillpub / Gen Trust Hub | 爆发中 |

另一个增强信号：[[library-skills]] 从 185→350⭐ in 2 days（05-01~03），tiangolo 的 library-embedded skill 分发模式正在爆发增长。

## 链接

- [[agents-md]] — 另一个 file-based agent config 标准
- [[mercury-agent]] — memory 层的标准化尝试
- [[huashu-design]] — 第一个爆发级 skill 案例
- [[microsoft-apm]] — `.agents/skills/` 标准的执行者
- [[skills-as-packages]] — 包级元数据和分发机制
