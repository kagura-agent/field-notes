---
title: Write-Read Gap in Self-Evolution Memory
created: 2026-03-26
source: self-improving skill 体验 + Luna 对话
---

自进化记忆系统的通病:**写入容易但读取很少发生**。

## 现象
- self-improving skill 三层文件(global/domain/project),写入有在做,但干活前很少读取
- knowledge-base 田野笔记写了但打工前不看
- beliefs-candidates 记了 42 条 gradient 但升级动作拖延

## 本质
写入是被动的(反思完顺手记),读取需要主动的(干活前有意识去查)。
被动 > 主动在执行纪律上永远成立。

## 解法
1. 把“读取”嵌入流程节点（FlowForge workloop study 节点强制读田野笔记）
2. [[skill-as-behavior-trigger]] — Skill 在意图触发时主动推送相关知识
3. 写入时打标签，读取时按标签 pull（而非全量读）
4. **L1 导航索引** (2026-04-28) — wiki/L1.md ≤ 30 行存在编码，告诉 LLM 知识存在且在哪，触发主动检索。借鉴 [[genericagent]] 的 L1 层设计。**已应用**: AGENTS.md session startup step 3 加载 L1.md (2026-04-28)

## 学术支撑
- **MemEvolve** (arXiv 2512.18746) - 把这个问题形式化为"记忆架构静态性",提出 4 模块(encode/store/retrieve/manage)独立进化
- Retrieve 模块是关键瓶颈--encode 和 store 相对容易,retrieve 需要主动且上下文相关

## 新证据: sop_index → L1 迁移 (2026-04-29)

[[genericagent]] PR #199: plan_sop.md 从依赖单独的 `sop_index.md` 文件改为依赖 L1 Insight (context-injected)。社区贡献者发现 sop_index.md 是私有文件，主仓库不存在 → 改用每轮自动注入的 L1。这验证了解法 #4 的方向：**注入式导航比文件查找可靠。**

## 相关
- self-improving-agent - ClawHub 热门 skill,同样面临这个问题
- [[capability-evolver]] - 用 Gene 模板化读取路径,减少主动读取成本
- [[memevolve]] - 学术界对同一问题的形式化研究
