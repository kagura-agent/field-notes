# Claude Code vs OpenClaw 对比分析 + 可落地改进方案

> 基于 6 个模块的源码研究
> 最后更新：2026-04-01

---

## 综合对比

### Claude Code 的核心设计哲学
- **Fork-based**：forked agent 共享 prompt cache，零额外 prefill 成本
- **自主模式**：proactive + SleepTool + agent 自建 cron
- **LLM-as-infrastructure**：用 LLM 做检索（findRelevantMemories）、权限判断（auto mode classifier）、进度摘要（AgentSummary）
- **安全纵深**：6 层 permission mode + dangerous pattern + sandbox + managed policy

### OpenClaw 的核心设计哲学
- **消息路由**：channel → binding → agent → session，统一消息总线
- **声明式配置**：JSON config 定义 cron、permission、agent，不需要运行时创建
- **生态开放**：ClawHub skills、npm plugins、多 harness（Claude Code/Codex/Pi）
- **简洁优先**：heartbeat + HEARTBEAT.md > tick + SleepTool

---

## 按能力维度对比

| 能力 | Claude Code | OpenClaw | 差距 | 优先级 |
|---|---|---|---|---|
| **记忆提取** | 自动 fork agent 提取 | 手动写 memory | 🔴 大 | P0 |
| **记忆检索** | LLM side-query 选 top-5 | FTS 关键词 | 🟡 中 | P1 |
| **记忆整理** | autoDream 自动整理 | daily-review cron | 🟢 小 | P2 |
| **记忆新鲜度** | memoryAge staleness caveat | NUDGE.md 14天规则 | 🟢 已有 | - |
| **子 agent 通信** | task-notification XML + SendMessage | push completion event | 🟡 中 | P1 |
| **子 agent 继续** | SendMessage 继续已有 worker | 只能 kill + 重 spawn | 🔴 大 | P1 |
| **共享状态** | Scratchpad 目录 | 无 | 🟡 中 | P2 |
| **Skill 动态发现** | 文件操作触发 + paths 条件激活 | 启动时扫描 | 🟡 中 | P2 |
| **Skill fork 模式** | fork 执行不污染上下文 | 无 | 🟡 中 | P2 |
| **Cron 灵活性** | Agent 自建 + session-only | Config 声明式 | 🟢 各有优势 | - |
| **Heartbeat 空闲检测** | isLoading() gate | 无（到点就发） | 🟡 中 | P1 |
| **Permission 粒度** | 命令级（`Bash(npm test)`） | 工具级 | 🟡 中 | P2 |
| **Auto permission** | LLM classifier 自动判断 | 无 | 🟡 中 | P3 |
| **Plugin 容器** | 统一（skill+hook+MCP+agent） | 分离（skill 和 plugin 各自） | 🟢 小 | P3 |
| **Marketplace 自动同步** | Reconciler 自动 | 手动 update | 🟡 中 | P3 |

---

## P0：可立即落地的改进

### 1. MEMORY.md 索引化 + Frontmatter
**问题**：MEMORY.md 是一个大文件，memory_search 是 FTS，语义检索差
**CC 做法**：每个 memory 文件有 frontmatter（description + type），scanMemoryFiles 只读 header
**改进方案**：
```markdown
# 每个 knowledge-base card 加 frontmatter
---
description: OpenClaw subagent 使用模式和超时配置
type: reference
tags: [openclaw, subagent, timeout]
updated: 2026-04-01
---
```
- 已在做（knowledge-base cards 有 frontmatter），扩展到所有 memory 文件
- 写一个 `scan-manifest.sh` 扫描所有文件的 frontmatter 生成索引
- **工作量**：1-2 小时，自己就能做

### 2. 记忆提取自动化
**问题**：每次对话结束靠 nudge plugin 手动判断该记什么
**CC 做法**：stopHooks → extractMemories（fork agent 自动提取）
**改进方案**：
- nudge 已经在做类似的事（agent_end hook），但判断逻辑在 prompt 里
- 优化 NUDGE.md prompt：明确"提取本次对话中的可复用知识"而非"反思"
- 加入排除规则（CC 的 extraction prompt 明确列了"不要记的东西"）
- **工作量**：修改 NUDGE.md，30 分钟

### 3. 记忆分类 + 排除规则
**问题**：什么都往 memory 塞，没有分类标准
**CC 做法**：4 类（user/feedback/project/reference）+ 明确的排除列表
**改进方案**：
```
记忆分类：
- user: 用户偏好、习惯（→ USER.md / MEMORY.md）
- feedback: 行为纠正、gradient（→ beliefs-candidates.md）
- project: 项目知识（→ knowledge-base/projects/）
- reference: 可复用知识（→ knowledge-base/cards/）

排除（不要记的）：
- 一次性操作细节（具体命令、临时路径）
- 已在文件中的信息（代码注释、README 内容）
- 纯确认性对话（"好的"、"收到"）
```
- **工作量**：更新 NUDGE.md + AGENTS.md，1 小时

---

## P1：近期可做的改进

### 4. 给 OpenClaw 提 heartbeat 空闲检测
**状态**：✅ 已提 [#58656](https://github.com/openclaw/openclaw/issues/58656)
**CC 做法**：`isLoading()` gate，空闲时才触发
**等待**：上游回复

### 5. 给 memex 提 LLM 检索建议
**状态**：已记 TODO，待合适时机提 issue
**CC 做法**：Sonnet side-query 从 manifest 选 top-5
**方案**：manifest-based pre-filter 或 LLM fallback（无 embedding provider 时）

### 6. Subagent 使用模式优化
**状态**：✅ 已落地到 knowledge-base/cards/subagent-usage-patterns.md
**CC 启发**：
- fork 共享 prompt cache → 我们没有，所以 subagent 做研究效率低
- SendMessage 继续 worker → 我们只能 kill + 重 spawn
- 进度摘要（每 30s）→ 我们只有完成通知
**可提 issue**：subagent continue（保留上下文追加指令）

---

## P2：中期改进

### 7. Knowledge-base LLM 检索
- 扫描所有 cards/projects 的 frontmatter 生成 manifest
- 查询时把 manifest + query 发给当前模型选 top-5
- 比 memory_search FTS 语义准确率高
- **依赖**：frontmatter 索引化先完成

### 8. Skill 条件激活
- CC 的 `paths:` 字段按文件模式激活 skill
- OpenClaw 可以加 `activateWhen:` 字段（路径模式 / 关键词 / 上下文条件）
- 减少 system prompt 中不相关 skill 的 token 占用

### 9. Scratchpad for Subagents
- spawn subagent 时传一个共享临时目录路径
- subagent 把中间结果写入，parent 读取
- 比靠文件系统约定更明确

---

## P3：长期方向

### 10. Auto Permission（LLM Classifier）
- 用 LLM 判断工具调用是否安全，减少 /approve 频率
- CC 的两阶段 classifier（fast → thinking）是好设计
- 但 token 成本高，需要评估 ROI

### 11. Plugin = 组件容器
- 一个 plugin 同时提供 skill + hook + MCP
- ClawHub 和 npm plugin 统一
- 简化安装流程

### 12. Agent 自建 Cron
- 让 agent 运行时创建 cron（类似 CC 的 CronCreateTool）
- 不需要改 config 文件 + 重启 gateway
- Session-only + durable 双轨

---

## 行动计划

| 序号 | 改进 | 工作量 | 依赖 | 状态 |
|---|---|---|---|---|
| 1 | MEMORY.md 索引化 + frontmatter | 1-2h | 无 | 待做 |
| 2 | NUDGE.md 提取优化 | 30min | 无 | 待做 |
| 3 | 记忆分类 + 排除规则 | 1h | 无 | 待做 |
| 4 | heartbeat 空闲检测 issue | - | 上游 | ✅ 已提 |
| 5 | memex LLM 检索 issue | 30min | 时机 | TODO |
| 6 | subagent 使用模式 | - | - | ✅ 已落地 |
| 7 | KB LLM 检索 | 半天 | #1 | 待做 |
| 8 | Skill 条件激活 | 提 issue | 上游 | 待评估 |
| 9 | Scratchpad | 提 issue | 上游 | 待评估 |

**下一步**：先做 P0 的 1-3（自己就能做，不依赖上游），然后推进 P1。

## 应用笔记（2026-04-02）

### Skill 三分法应用到打工选题

Claude Code 源码揭示了 skill 的三个层次，直接对应打工的价值密度：

1. **System 级**（改变 agent 运行方式）→ 最高价值
   - agent memory: hindsight, mem0
   - agent self-evolution: Hermes, nudge
   - agent identity: 我们自己的 DNA 系统
   
2. **Tool 级**（扩展 agent 能力）→ 中等价值  
   - agent 编排: OpenClaw, LangGraph
   - skill 生态: ClawHub, awesome-claude-code
   
3. **Prompt 级**（知识注入）→ 最低价值
   - 纯 markdown skills, howto guides
   - 数量最多但可替代性也最高

**应用**：打工选题按这个排序。之前选 tenshu（UI dashboard）是 tool 级偏下，不如 hindsight（system 级）。

### Fork 模式 vs OpenClaw Subagent

| | Claude Code Fork | OpenClaw Subagent |
|---|---|---|
| 上下文 | 继承父对话完整历史 | 全新 session，只有 task |
| Prompt cache | 共享（大幅省 token） | 独立（每次重新编码） |
| 递归 | 不允许 fork child 再 fork | 允许（但实际很少用） |
| 结果传递 | XML task-notification 注入 user message | subagent_announce 事件 |

**洞察**：我们的 subagent 每次从零开始，token 成本高。如果能把 workspace context 预编码共享，效率会大幅提升。但这需要 OpenClaw 底层支持，不是我能改的——可以提 issue。

→ 记入 [[IDEAS.md]]: OpenClaw subagent prompt cache sharing
