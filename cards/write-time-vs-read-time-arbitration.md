---
title: Write-Time vs Read-Time Memory Arbitration
slug: write-time-vs-read-time-arbitration
tags: [memory, architecture, agent-design]
created: 2026-04-18
---

# Write-Time vs Read-Time Memory Arbitration

两种 agent memory 冲突解决策略的对比。

## Write-Time (Orb 模式)
- 新 fact 写入时，取 top-N 近邻 → LLM 判断 ADD/UPDATE/DELETE/NONE
- **优势**: 读取时无冲突（已在写入时解决），一致性强
- **代价**: 每次写入多一次 LLM 调用（Orb 用 Haiku，成本低）
- **风险**: 如果 arbitration 判断错误，信息永久丢失（靠 tombstone 缓解）
- **实例**: [[orb]] Holographic Memory

## Read-Time (OpenClaw/dreaming 模式)  
- 写入直接存，读取时 embedding search + ranking 返回最相关结果
- **优势**: 写入快，不丢信息，ranking 可调
- **代价**: 可能返回矛盾信息，读取端需要 LLM 判断哪个对
- **风险**: 旧信息被反复召回但已过时
- **实例**: [[dreaming-observation]] memory_search

## 混合方案（待探索）
- Write-time: 只做重复检测（去重），不做语义 arbitration
- Read-time: 加 recency bias + trust score 排序
- 定期 maintenance: 类似 Orb 的 memory-lint，批量清理矛盾

## 关联
- [[evolution-needs-eval]] — arbitration 本身需要 eval 来验证质量
- [[frozen-trust-vs-time-decay]] — trust scoring 策略选择
