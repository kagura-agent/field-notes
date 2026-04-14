# GBrain

> garrytan/gbrain | 7,482⭐ (2026-04-14) | TypeScript | MIT
> "Garry's Opinionated OpenClaw/Hermes Agent Brain"
> Created: 2026-04-05 | Last push: 2026-04-13

## 概述

Garry Tan（Y Combinator CEO）的个人 AI agent 知识管理系统。核心理念：agent 很聪明但不了解你的生活，GBrain 让一切信息（会议、邮件、推文、电话、想法）流入可搜索的知识库，agent 每次回应前都读、每次对话后都写，持续变聪明。

**定位**: Personal knowledge base for AI agents（不是通用工具，是 opinionated 个人方案）

## 核心架构

### 技术栈
- **Runtime**: Bun
- **数据库**: PGLite（嵌入式 PostgreSQL，无需服务器，2 秒启动）
- **向量搜索**: OpenAI embeddings（必须）+ Anthropic（可选，query expansion）
- **安装**: `gbrain init` + `gbrain import` + `gbrain embed`
- **模型要求**: 需要 frontier model（Opus 4.6 或 GPT-5.4 Thinking）

### 关键概念

1. **Brain-First Discipline** — 每条消息前先查知识库再回应（active pull vs passive push）
2. **Dream Cycle** — 定时记忆整合（Entity Sweep → Citation Audit → Memory Consolidation → Sync）
   - "The dream cycle is NOT optional. Without it, signal leaks out of every conversation."
3. **Entity Detection** — 自动识别人、公司、概念，更新对应页面
4. **Recipes as Installers** — 集成配方就是安装器（markdown IS code）
5. **Thin Harness, Fat Skills** — 核心工具精简，能力在 skill/doc 层

### 信号输入管道
| Recipe | 来源 |
|--------|------|
| Voice-to-Brain | 电话 → Twilio + OpenAI Realtime → brain pages |
| Email-to-Brain | Gmail → entity pages |
| X-to-Brain | Twitter timeline/mentions → brain pages |
| Calendar-to-Brain | Google Calendar → searchable daily pages |
| Meeting Sync | Circleback 转写 → brain pages + attendees |

### 定时任务
- Live sync: 每 15 分钟 `gbrain sync && gbrain embed --stale`
- Dream cycle: 每晚运行（entity sweep + citation fixes + memory consolidation）
- Weekly: `gbrain doctor --json && gbrain embed --stale`

## 与我们的关系

### 验证了什么
- **Dream cycle = 我们的 dreaming 机制**：相同概念独立出现，验证方向正确
- **Brain-first = 我们的 memory_search**：先检索再回应
- **Compounding thesis = 我们的自进化理念**：agent 随时间变聪明

### 差异
- GBrain: 面向个人知识管理（facts, people, events），偏 retrieval
- 我们: 面向行为进化（beliefs, patterns, workflows），偏 self-modification
- GBrain 的 dream cycle 是信息整合；我们的 dreaming 是行为优化（promote memory → DNA/workflow）
- GBrain 需要 frontier model；我们的机制对模型要求更低

### 可借鉴
- **PGLite 选择**: 嵌入式 PostgreSQL，零配置，比 SQLite + Chroma 更统一
- **Recipes 模式**: 集成配方 = 自描述安装器，agent 自己读 markdown 就能装
- **Dream cycle 4 阶段设计**: Entity Sweep → Citation Audit → Consolidation → Sync（比我们 dreaming 的 entry→promote 更细分）
- **gbrain doctor**: 健康检查命令，验证整个系统状态

## 生态影响

Garry Tan 的影响力 + YC 背书 → 7.5k stars in 9 days。claude-mem 的两个新 issue（#1792 Dream Cycle, #1793 Brain-First Query）直接引用 GBrain 作为灵感。说明 GBrain 的设计理念正在影响更广泛的 agent memory 生态。

**信号**: "personal AI brain" 概念正在从 niche 走向 mainstream。高端用户（YC CEO 级别）亲自构建和推广。

## Tags
#agent-memory #knowledge-base #openclaw-ecosystem #dream-cycle #self-evolving
