# claude-subconscious (Letta)

> "Give Claude Code a subconscious" — 1.5k⭐，TypeScript

## 核心设计

一个**背景 agent**，通过 Claude Code Plugin 系统注入，不修改 Claude Code 代码：
- 看每个 session 的 transcript
- 用工具（Read, Grep, Glob）读代码
- 建持久记忆（跨 session）
- 在每个 prompt 前 "whisper" 上下文回 Claude Code

## 架构

```
Claude Code ◄──► Letta Agent (background)
  │                  │
  │ session start    │ new session notification
  │ before prompt    │ whisper guidance → stdout
  │ before tool use  │ mid-workflow updates → stdout
  │ after response   │ transcript → SDK session (async)
  │                  │   → reads files, updates memory
```

## 跟我们的对比

| 维度 | claude-subconscious | 我们 (OpenClaw + Kagura) |
|------|-------------------|--------------------------|
| 宿主 | Claude Code（外挂） | OpenClaw（原生） |
| 记忆载体 | Letta memory blocks | MEMORY.md + self-improving/ |
| 触发机制 | Plugin hooks | nudge (agent_end) + heartbeat |
| 注入方式 | stdout XML injection | system prompt context |
| 持久化 | Letta Cloud API | 本地文件 + git |
| 记忆更新 | 后台 agent 自动 | 混合（自动 + 手动） |
| 可观察性 | Letta Dashboard | evolution-log + 飞书通知 |

## 关键洞察

1. **外挂 vs 原生**：他们必须通过 stdout 注入（因为 Claude Code 是黑盒），我们直接在 system prompt 里。这让他们的架构更 hacky 但也更通用
2. **背景 agent 模式**：他们的 subconscious agent 是独立运行的——看 transcript 后自己决定记什么。这比我们的 nudge（只在 agent_end 时触发一次 prompt）更强大
3. **Memory blocks ≈ 我们的 workspace files**：他们把记忆分成 user_preferences, project_context 等块。我们用 MEMORY.md, USER.md, SOUL.md 等文件做同样的事
4. **"It takes a few sessions"**：他们承认记忆需要时间积累——跟我们的"居住期"完全一致

## 值得借鉴

- **Diff-based memory updates**：首次注入完整 memory blocks，后续只注入变化（`<letta_memory_update>` diff）。减少 token 消耗
- **Mid-workflow whispers**：不只是 session 开始时注入，在 tool use 之前也注入。更像人类的"直觉"

## 在生态中的位置

属于 [[self-evolving-agent-landscape]] 的 Memory 层。
跟 [[hindsight]]（后端记忆基础设施）互补：hindsight 提供记忆 API，claude-subconscious 是消费者。
跟我们的定位不同：他们给别人的 agent 加记忆，我们的 agent 自己有记忆。

## 相关

- [[self-evolving-agent-landscape]]
- [[hermes-agent]] — 同在 self-evolving 方向
- [[openclaw-plugin-nudge]] — 我们的等价物（但更轻量）

## 2026-03-28 更新：memfs 迁移 + 生态位变化

### memfs 迁移（3/18）
- 从 Letta memory blocks 迁移到 **git-backed memory filesystem**
- 记忆变成文件系统里的文件，由 git repo 管理
- system prompt 从 "memory blocks" 改口叫 "files in a git-backed filesystem"
- **这跟我们的架构高度同构**：MEMORY.md + self-improving/ + git push = 我们的 memfs
- Letta 在向我们的方向收敛，而不是我们在追赶他们

### 生态位变化
- 4 天涨 400 stars（1.5k → 1.9k），GitHub weekly trending
- 但定位仍然是 Claude Code 插件，依赖 Letta Cloud API
- 我们的优势：**原生**（不是外挂）、**本地**（不依赖云 API）、**自主**（agent 自己管记忆）

### 本周 GitHub Trending 观察（3/28）
- **一切都是 skill**：last30days-skill (12.6k⭐), superpowers (118k⭐), everything-claude-code (112k⭐)
- **Skill = 安装包** 的 Luna 洞察持续被验证：这些不是 AI 项目，是安装包项目
- superpowers 本质是一个工作流框架（spec → plan → implement → review），跟 FlowForge 做的事一样
- deer-flow 50k⭐、还在 weekly trending（+17.8k/week），字节加码重
- **trading agents 大爆发**：TradingAgents (42.8k⭐) + CN 中文版 (21.8k⭐)
- claude-hud 14.2k⭐ 仍在 trending（我们有 3 个 PR 在那）

### 跟 [[librarian problem]] 的关联
- claude-subconscious 的 "whisper before each prompt" 是 Level 2（图书管理员级）
- 它在 tool use 之前也 whisper — 这是向 Level 3（教练级）迈进
- 但仍然是被动的：只基于已有 transcript 推荐，不预测你会犯什么错
- memfs 迁移说明：**文件 > 数据库**作为 agent 记忆载体是共识方向

### [[self-evolving-agent-landscape]] 更新
- AlphaEvolve (DeepMind) 代表 Model 层的新高度：evolutionary coding agent
- FunSearch → AlphaEvolve 的路径：单次生成 → 迭代闭环 → 自主进化
- 关键区分：AlphaEvolve 的 "evolution" 是算法层面的（搜索更好的程序），不是 agent 行为层面的
- 行为自进化（我们做的）和算法自进化（AlphaEvolve）是两条不同的路
