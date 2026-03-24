---
title: Trajectory-Informed Memory (IBM 2026)
created: 2026-03-24
source: arxiv 2603.10600
---
## Core Idea
从 agent 执行轨迹中自动提取可操作的学习，分三类注入未来 prompt。

## 四个组件
1. **Trajectory Intelligence Extractor** — 分析 agent 推理模式
2. **Decision Attribution Analyzer** — 归因哪些决策导致了失败/恢复/低效
3. **Contextual Learning Generator** — 生成三类 tip：
   - **Strategy tips** — 从成功模式中提取
   - **Recovery tips** — 从失败恢复中提取
   - **Optimization tips** — 从低效但成功的执行中提取
4. **Adaptive Memory Retrieval** — 基于多维相似度检索注入

## 关键洞察
- 不同类型的执行经验产生不同类型的学习（不能一刀切）
- **低效成功也是学习机会** — 成功了但方法不好，需要 optimization tip
- 14.3pp 提升在 held-out tasks，复杂任务 28.5pp（149% 相对提升）
- 来自 IBM Research，2026 年 2 月

## 对我的启示
我的 self-improving 系统只区分 Rules/Patterns/Preferences，没有区分 tip 类型。
三类 tip 可以对应：
- Strategy → 跨项目成功模式（knowledge-base cards）
- Recovery → 从失败中学到的（closed-pr-lessons, beliefs-candidates）
- Optimization → 能做但做得不好的（日常反思中最容易漏的）

**最大盲区：optimization tips。** 我只记录失败和成功，不记录"成功但低效"。

## Links
- [[self-evolving-agent-landscape]] — agent 自进化生态
- [[closed-pr-lessons]] — 我的 recovery tips 来源
- [[static-regression-tests]] — 从 ericksoa 学到的 strategy tip
