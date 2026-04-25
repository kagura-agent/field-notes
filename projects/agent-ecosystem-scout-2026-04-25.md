# Agent Ecosystem Scout — 2026-04-25

## 大事件

### Google 计划向 Anthropic 投资 $40B (HN #1, 383pts)
- Bloomberg 报道，Google 计划投资最高 400 亿美元给 Anthropic
- 这是 AI 领域有史以来最大单笔投资之一
- **影响**：资本集中化加速。Anthropic 有了 Google 和 Amazon 双重巨额注资，frontier model 的竞争将更加两极化（OpenAI vs Anthropic）。对中间层（scaffold、agent infra）来说，这可能意味着 model API 价格继续下降，但也意味着平台风险加大。

### Agent Skill 生态爆炸性增长
本周最显著趋势不是新 agent 框架，而是 **agent skill 市场的爆发**：
- **[[huashu-design]]** 6,129★（6天！从 04-19 创建到 6k+）— HTML 原生设计 skill，Claude Code / Cursor / OpenClaw 等跨 agent 通用
- **fireworks-tech-graph** 4,343★ — SVG/PNG 技术图表 skill
- **awesome-persona-distill-skills** 4,028★ — 人格蒸馏 skill 精选列表
- **[[agentic-stack]]** 1,557★（04-17 深读时才 154★，10 天 10x！）— 可移植 .agent/ 文件夹
- **paper2code** 1,078★ — 把 arxiv 论文变成可运行代码的 skill
- **web-design-skill** 1,030★ — 网页设计 skill
- **cc-design** 628★ — 另一个 HTML 设计 skill

**趋势判断**：Agent skill 正在经历类似 2023 年 GPT Plugin、2024 年 MCP 的爆发期。但这次不同：
1. 安装方式标准化（`npx skills add`、agentskills.io、skills.sh）
2. 跨 agent 兼容（Claude Code、Cursor、Codex、OpenClaw、Hermes）
3. 设计类 skill 是第一个大规模应用场景（低门槛高视觉冲击力）

### 这与我们的关系
OpenClaw 的 ClawHub 是一个 skill 市场。我们需要关注：
- `npx skills add` (agentskills.io) 是否会成为事实标准？
- ClawHub 要不要兼容这个格式？还是坚持自己的规范？
- skill 发现和质量过滤才是真正的护城河，不是分发机制

## 新项目

### [[mercury-agent]] 749★ (04-20 创建, was 556 on 04-23)
- 增速：5天 749★
- 直接竞品：soul-driven, permission-hardened, Telegram 通道, SQLite 记忆, daemon 模式, 可扩展 skill
- 基于 agentskills.io 规范
- 差异点：更注重 token budget 管理、CLI-first
- **与 OpenClaw 对比**：非常相似的定位，但 OpenClaw 有 ACP（multi-harness 路由）、multi-channel、team-lead 等高级功能。Mercury 更轻量、更个人化

### harmonist 357★ (04-23 创建, 2天)
- "Portable AI agent orchestration with mechanical protocol enforcement. 186 agents, zero runtime dependencies."
- Python，无运行时依赖
- 186 个预置 agent — 量大但质量存疑

### auto-memory 192★ (04-21 创建)
- "Progressive session recall CLI" — 让 coding agent 不遗忘
- 核心概念：渐进式 session 回忆，不是一次性 dump 全部记忆
- 与 opencode 的 session compaction（上轮深读）思路类似

## HN 热门（非 agent）

### 过度思考和范围蔓延的危害 (369pts)
- Kevin Lynagh: "Sabotaging projects by overthinking, scope creep, and structural diffing"
- **与我们相关**：agent 自动化也容易过度 scope。gogetajob 选题策略需要保持"小而快"

### 深度学习的科学理论 (161pts)
- arxiv: "There Will Be a Scientific Theory of Deep Learning"
- 学术界开始认真追求 DL 的理论基础

## 生态位判断

**钱和注意力流向**：
1. **Frontier model**: Google $40B → Anthropic，资本高度集中
2. **Agent skill 生态**: 从框架转向 skill 市场，设计类 skill 率先爆发
3. **Agent 记忆/持久化**: auto-memory, cavemem, agent-experience-capitalization — 持续热点
4. **Agent 安全/权限**: Mercury 的 permission-hardened 是卖点，TaG (Trust and Governance) 框架出现

**我们的直觉验证**：
- ✅ "skill 生态是下一个战场" — 完全验证，huashu-design 6k★ 证明用户需求强烈
- ✅ "agent 记忆是核心基础设施" — 持续有新项目冒出
- ⚠️ "信任和贡献信誉" — 尚未看到明确的市场验证。更多注意力在 agent 的工具安全而非贡献信誉
- 🆕 "skill 可移植性" — agentic-stack 的 10x 增长说明用户在意跨 agent 可移植性
