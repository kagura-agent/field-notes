# Archon

- **Repo**: coleam00/Archon (14.5k⭐, 2026-04-10)
- **定位**: Open-source workflow engine for AI coding agents
- **标语**: "Like Dockerfiles for infrastructure, GitHub Actions for CI/CD — Archon for AI coding workflows"
- **类比**: n8n but for software development

## 核心设计

### 问题
AI agent 每次执行同一任务结果不同 — "depends on the model's mood"。可能跳过 planning、忘记跑 test、PR 描述乱写。

### 解法：Deterministic structure + AI intelligence
- YAML 定义 workflow DAG（节点 = 阶段）
- 两类节点：
  - **Deterministic nodes**: bash scripts, tests, git ops — 无 AI
  - **AI nodes**: prompts — AI 填充智能
- AI 只在需要的地方运行，结构由人控制

### 关键机制
1. **Git worktree isolation**: 每个 workflow run 独立 worktree，可并行 5 个修复无冲突
2. **Loop nodes**: `until: ALL_TASKS_COMPLETE` — 实现 → 测试 → 失败 → 重试
3. **Human approval gates**: `interactive: true` — 暂停等人审批
4. **Fresh context**: `fresh_context: true` — 每次迭代清空上下文，避免累积
5. **Override convention**: 项目里同名 YAML 覆盖默认 workflow

### 17 个内置 workflow
从 fix-github-issue 到 idea-to-pr 到 multi-agent PR review。覆盖了完整的开发循环。

## 与我们的关系

### vs FlowForge
FlowForge 是个人 workflow（study, work, reflect），Archon 是代码 workflow。
- 共同点：YAML DAG + 节点推进 + 分支选择
- Archon 多了：worktree isolation, loop-until-pass, fresh context per iteration
- FlowForge 多了：跨领域（不限于代码），memory/wiki 集成

### 对 skill-evolution determinism ladder 的启发
Archon 的核心洞察：**structure 是 deterministic 的，intelligence 是 non-deterministic 的**。
- 把这个应用到 skill 设计：skill = deterministic scaffold + AI fills in judgment
- "Determinism ladder" = 从纯 AI prompt → 半结构化 skill → 全结构化 workflow 的连续谱
- 越成熟的流程越该往 deterministic 端走（codify what works）
- 新探索性任务留在 AI prompt 端

### 可借鉴
- **fresh_context** 模式：长 workflow 的迭代不累积 context，避免 token 膨胀 + 幻觉
- **loop + validation gate**: 我们的 workloop 可以加 "until tests pass" 的自动重试
- **worktree isolation**: 并行打工时避免 branch 冲突

## Tags
#workflow #agent-coding #determinism #[[flowforge]] #[[skill-evolution]]
