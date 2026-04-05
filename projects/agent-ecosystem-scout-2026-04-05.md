---
title: Agent Ecosystem Scout — 2026-04-05
created: 2026-04-05
source: GitHub trending, agents-radar, web search
tags: [landscape, scout, weekly]
---

## GitHub Trending (2026-04-05)

### AI/Agent 相关
1. **microsoft/agent-framework** (8.7K★) — MS 统一 agent 框架（合并 Semantic Kernel + AutoGen），Python + .NET，graph-based multi-agent orchestration
2. **badlogic/pi-mono** (31.6K★, +340/day) — AI agent toolkit: coding agent CLI, unified LLM API, TUI & web UI, Slack bot
3. **block/goose** — open source extensible AI agent
4. **dmtrKovalenko/fff.nvim** (3.5K★, +443/day) — 最快最准的 file search for AI agents
5. **Blaizzy/mlx-vlm** (3.8K★, +408/day) — Mac 本地 VLM inference/fine-tuning

### 非 AI 但热门
- **siddharthvaddem/openscreen** (21.5K★, +2692/day) — Screen Studio 开源替代
- **telegramdesktop/tdesktop** (30.8K★) — Telegram Desktop

## agents-radar 趋势（4/2 数据）

### 资金和注意力流向

1. **Terminal-native coding agents 已成品类**：Claude Code (+10,749★/天), Codex (+2,390★/天) 同时爆发
2. **Claude Code 生态淘金热**：everything-claude-code (130K★), learn-claude-code (46K★), claude-howto (+3,301★/天)
3. **Agent Memory 成为独立品类**：cognee (14.8K★), mem0 (51.7K★) — 从 vector DB 分化出来
4. **Vectorless RAG 新方向**：VectifyAI/PageIndex (23.5K★) — reasoning-based retrieval 替代 vector search
5. **LEANN**: 97% storage savings for private RAG — edge deployment 的突破

### 关键判断
- 钱和注意力在涌入：coding agents > agent memory > RAG > multi-agent orchestration
- Microsoft 入场（agent-framework）意味着 multi-agent 从学术进入企业市场
- 本地化/edge AI 是明确趋势（mlx-vlm, LEANN, Engram self-hosted）

## Self-Evolving Agent 最新动态

### 新发现的项目
1. **[[agentfactory]]** (arxiv 2603.18000) — 可执行 subagent 代码替代文本经验，57% token 减少
2. **[[openspace]]** (HKUDS) — skill 自进化引擎 + community cloud, 46% token 减少, v0.1.0 刚发
3. **[[engram]]** (Ironact) — 开源 agent memory 层，OpenClaw 一等公民插件
4. **EvoScientist** — 自进化多 agent 科研框架，persistent memory for ideation + experimentation
5. **AVO (Agentic Variation Operators)** — 用 coding agent 做进化搜索，attention kernel 超越 cuDNN 3.5%

### 对 self-evolving landscape 的更新
四层架构需要扩展第二层（Skill/Code）：
- AgentFactory: **code as skill** (executable Python modules + SKILL.md)
- OpenSpace: **skill auto-evolution** (FIX/DERIVED/CAPTURED) + community sharing
- 这两个项目跟我们的 ClawHub 方向直接相关

## 与 llm-wiki 的知识管理方向

llm-wiki (Karpathy) 的 compile-time knowledge 理念正在被验证：
- Engram 的 auto-capture → dedup → recall 跟 llm-wiki 的 ingest → query → lint 同构
- PageIndex 的 vectorless reasoning-based RAG 暗示纯 embedding 可能不够
- AgentFactory 用 **code as knowledge**（比 text 更可靠的知识表达）

我们的知识管理三层（raw → wiki → schema）被更多项目印证：
- Raw: auto-capture (Engram), execution traces (OpenSpace)
- Wiki: structured facts (Engram dedup), skill documentation (AgentFactory SKILL.md)
- Schema: skill taxonomy (OpenSpace quality monitoring), graph relations (cognee)

See also: [[llm-wiki-karpathy]], [[self-evolving-agent-landscape]], [[agent-memory-landscape-202603]]
