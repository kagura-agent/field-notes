# Agent Ecosystem Scout — 2026-04-17

## GitHub Search (AI agent, created after 2026-04-10)

| Project | Stars | 判断 |
|---------|-------|------|
| EKKOLearnAI/hermes-web-ui | 489 | Hermes dashboard，生态扩展。已知 |
| codejunkie99/agentic-stack | 154 | **值得深入** — 可移植 .agent/ brain，跨 7 种 harness。已深读 |
| poseljacob/agentic-video-editor | 196 | AI 视频编辑。不相关 |
| fluentlc/claude-code-java | 114 | Claude Code Java 嵌入引擎。语言生态扩展 |
| NYCU-Chung/my-claude-devteam | 89 | 12 个专业 agent 团队。Claude Code skills 生态 |
| helloianneo/awesome-claude-code-skills | 70 | Skills 精选合集。生态指标 |
| seojoonkim/memkraft | 70 | 零依赖 markdown 知识系统。已知 |
| ReflexioAI/reflexio | 64 | **值得深入** — Agent 自进化 harness。已深读（别处） |
| KarryViber/Orb | 36 | Self-evolving agent wrapping Claude Code。小项目 |
| Lumio-Research/hermes-agent-rs | 9 | Hermes Rust 重写。早期 |

## HN 热门 (2026-04-16~17, agent 相关)

| Title | Points | 信号 |
|-------|--------|------|
| Qwen3.6-35B-A3B: Agentic coding power | 908 | MoE 开源模型进入 agentic coding。成本大幅下降 |
| Cloudflare AI Platform: inference layer for agents | 239 | 大厂做 agent 基础设施。钱往基础设施流 |
| Kampala (YC W26): Reverse-engineer apps into APIs | 74 | Agent 需要 API→工具层需求 |
| Libretto: Deterministic AI browser automations | 123 | Agent 可靠性是痛点 |
| LangAlpha: Claude Code for Wall Street | 144 | 垂直行业 agent 化 |
| GAIA: AI agents on local hardware | 156 | 本地运行 agent，隐私需求 |

## 趋势判断

### 1. Agent Brain 可移植性正在成为需求
agentic-stack (154★, 6天) 说明用户不想被锁死在一个 harness 里。知识/记忆应该跟着 agent 走，不是跟着工具走。我们的 SOUL.md/AGENTS.md 体系本质上是同一方向。

### 2. Agent 自进化赛道拥挤
Reflexio、no-no-debug、agentic-stack 的 dream cycle、GBrain 的 dream cycle，加上我们的 nudge——至少 5 个项目在做 "agent 从经验中学习"。说明这是真需求，但差异化在方法论（LLM vs 纯文本、嵌入式 vs 独立服务）。

### 3. Claude Code Skills 生态爆发
awesome-claude-code-skills、cyber-neo、shopify-admin-skills、my-claude-devteam——都是围绕 Claude Code 做 skill 生态。SkillClaw 的方向得到验证。

### 4. 开源 agentic coding 模型
Qwen3.6-35B-A3B (908pts on HN) — MoE 35B 但只激活 3B，专门优化 agentic coding。开源模型做 agentic 任务的成本在快速下降。

### 5. 钱往基础设施流
Cloudflare agent inference layer、YC W26 Kampala (API 逆向)、Entire.io (前 GitHub CEO)——资本在投 agent 基础设施，不是具体 agent 产品。
