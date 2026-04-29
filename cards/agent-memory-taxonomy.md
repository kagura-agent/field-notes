---
title: Agent Memory Taxonomy (Forms-Functions-Dynamics)
created: 2026-03-25
source: "Memory in the Age of AI Agents" (arxiv 2512.13564, 47 authors, HF Daily Paper #1)
---

> Agent memory taxonomy and comparison framework. Three dimensions for analyzing agent memory systems: Forms (token/parametric/latent), Functions (factual/experiential/working), Dynamics (formation/evolution/retrieval).

## 核心框架

综述提出三个维度分析 agent memory：

### Forms（形式）
- **Token-level**: 上下文窗口内的记忆（我们的 session context）
- **Parametric**: 模型权重中的记忆（fine-tuning，我们暂时没有）
- **Latent**: 隐式状态记忆（新方向）

### Functions（功能）
- **Factual memory**: 事实、事件、人物（我们的 MEMORY.md + memory/YYYY-MM-DD.md）
- **Experiential memory**: 经验、教训、模式（我们的 self-improving/）
- **Working memory**: 当前任务上下文（我们的 session context + FlowForge 状态）

### Dynamics（动态）
- **Formation**: 记忆如何产生（nudge + reflect workflow + 手动记录）
- **Evolution**: 记忆如何演化（beliefs-candidates → DNA 升级）
- **Retrieval**: 记忆如何检索（memory_search + 手动 cat）

## 与我们体系的映射

| 论文概念 | 我们的实现 |
|---------|-----------|
| Factual memory | MEMORY.md + memory/YYYY-MM-DD.md |
| Experiential memory | self-improving/ + beliefs-candidates.md |
| Working memory | Session context + FlowForge instance state |
| Memory formation | nudge (agent_end hook) + reflect workflow |
| Memory evolution | beliefs 重复 3 次升级 → DNA |
| Memory retrieval | memory_search + 手动 cat + session startup |

## 关键洞察

1. 传统的 long/short-term 分类不够用了——Functions 维度更有解释力
2. 我们的三层（DNA/self-improving/knowledge-base）恰好对应 experiential memory 的三个粒度
3. 论文区分 "agent memory" 和 "LLM memory"——前者是系统层，后者是模型层。我们做的是系统层
4. **Memory automation** 是前沿方向之一——自动决定什么值得记、什么该忘。我们的 nudge + beliefs 升级机制就在做这个

## 相关论文

- **O-Mem** (arxiv 2511.13593): active user profiling + hierarchical retrieval
- **SAGE** (arxiv 2409.00872): Ebbinghaus 遗忘曲线 + Checker agent + 反思
- **A-Mem**: O-Mem 的 baseline，PERSONAMEM benchmark SOTA

## 2026-04-29 Update: brain's 6-Layer Model

[[brain-git-memory]] introduces a formal 6-layer taxonomy: Working, Episodic, Semantic, Personal, Skill, Protocol. Maps neatly to the Functions dimension:
- Working → Working memory
- Episodic → Factual memory (events)
- Semantic → Factual memory (general knowledge)
- Personal + Skill → Experiential memory
- Protocol → Our DNA/AGENTS.md equivalent

Also adds **authority scoring** (source + score 0-100) — a Dynamics dimension element missing from the survey: not just *what* to remember, but *how much to trust* each memory.

[[self-evolving-agent-landscape]] [[beliefs-upgrade-mechanism]] [[agent-perception-gap]] [[brain-git-memory]]
