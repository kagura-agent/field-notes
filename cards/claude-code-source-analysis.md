# Claude Code Source Analysis (2026-03-31 Leak)

## 概述
Claude Code 完整源码于 2026-03-31 通过 npm registry 的 .map 文件泄露。
- 规模：~1,900 文件，512K+ 行 TypeScript
- 运行时：Bun
- UI：React + Ink（CLI React 渲染器）
- 本地 clone：`~/repos/claude-code/`

## 架构概览

### 核心组件
| 组件 | 路径 | 说明 |
|---|---|---|
| QueryEngine | `QueryEngine.ts` (~46K行) | LLM API 调用核心 |
| Tool System | `tools/` (~40 个工具) | 每个工具自包含：schema + permission + execution |
| Command System | `commands/` (~50 个命令) | /slash 命令 |
| Memory System | `memdir/` | 三层记忆架构 |
| Coordinator | `coordinator/` | 多 agent 编排 |
| Skills | `skills/` | 内置 + 自定义 skill |
| Bridge | `bridge/` | IDE 集成（VS Code / JetBrains） |

### 工具列表（重点）
- **AgentTool** — 子 agent 生成（含 agent memory、coordinator mode）
- **TeamCreateTool / TeamDeleteTool** — 团队 agent 管理
- **SendMessageTool** — agent 间通信
- **SleepTool** — 主动等待（proactive mode）
- **CronCreateTool** — 定时触发
- **RemoteTriggerTool** — 远程触发
- **SkillTool** — Skill 执行
- **TaskCreateTool / TaskUpdateTool** — 任务管理
- **SyntheticOutputTool** — 结构化输出

## Memory 系统（重点研究）

### 三层架构
1. **MEMORY.md**（入口索引）— ≤200 行 / 25KB，纯索引不存内容
2. **Auto-memory**（`~/.claude/projects/<path>/memory/`）— 自动提取，每个文件有 frontmatter
3. **Team memory** — 团队共享，feature flag 控制

### Memory 四类型（frontmatter type 字段）
| 类型 | 用途 | 触发条件 |
|---|---|---|
| **user** | 用户画像（角色、偏好、知识水平） | 学到用户任何信息时 |
| **feedback** | 行为纠正 + 确认 | 用户纠正 OR 确认非显而易见的做法 |
| **project** | 项目动态（谁在做什么、为什么、deadline） | 学到项目状态变化时 |
| **reference** | 外部系统指针 | 学到外部资源位置时 |

**关键设计**：feedback 类型**同时记录纠正和确认**——"Record from failure AND success: if you only save corrections, you will avoid past mistakes but drift away from approaches the user has already validated, and may grow overly cautious."

### extractMemories — 自动记忆提取
- **触发时机**：每个 query loop 结束（模型最终响应无 tool call 时）
- **机制**：forked agent（共享 prompt cache，零额外缓存成本）
- **工具权限**：只能读 + 写 memory 目录，不能执行任意命令
- **互斥**：如果主 agent 已经写了 memory，extraction 跳过
- **限制**：最多 5 turns，2-4 turns 完成（read → write）
- **节流**：`tengu_bramble_lintel` 控制每 N 个 turn 才触发一次
- 文件：`src/services/extractMemories/extractMemories.ts`

### autoDream — 记忆整理（Sleep Consolidation）
- **触发条件**：≥24 小时 + ≥5 个 session 积累
- **四阶段流程**：
  1. Orient — ls memory 目录，读 MEMORY.md 索引
  2. Gather — 读日志、检查过时记忆、grep transcripts
  3. Consolidate — 写入/更新 memory 文件，合并重复，修正过时
  4. Prune — 更新 MEMORY.md 索引，保持 ≤200 行
- **UI 展示**：DreamTask 在 footer pill 显示进度
- **锁机制**：consolidation lock 防止并发
- 文件：`src/services/autoDream/autoDream.ts`, `consolidationPrompt.ts`

### findRelevantMemories — 记忆检索
- **不用 embedding**！用 Sonnet 读 frontmatter manifest，从 ≤200 个文件中选 ≤5 个
- 每个文件只读 frontmatter（前 30 行），不读内容
- 比语义搜索贵但更准（LLM 理解查询意图）
- 文件：`src/memdir/findRelevantMemories.ts`

### memoryAge — 记忆新鲜度
- 计算记忆年龄（天数），>1 天的自动添加 staleness 警告
- "This memory is X days old. Claims about code behavior or file:line citations may be outdated."
- 文件：`src/memdir/memoryAge.ts`

### Agent Memory（子 agent 记忆）
- 三种 scope：user（全局）、project（项目级）、local（本地不入 VCS）
- 每个 agent type 有独立 memory 目录
- 文件：`src/tools/AgentTool/agentMemory.ts`

## 与我们系统的对比

| 维度 | Claude Code | 我们（OpenClaw + Kagura） |
|---|---|---|
| Memory 提取 | extractMemories（forked agent，每 turn） | nudge（agent_end hook，每 5 次） |
| Memory 整理 | autoDream（24h + 5 session） | daily-review（每天 3AM cron） |
| Memory 检索 | LLM 选文件（Sonnet，frontmatter） | memory_search（embedding hybrid + FTS） |
| Feedback 分类 | 纠正 + 确认（双向） | gradient / directive（只记纠正） |
| Memory staleness | memoryAge.ts（自动警告） | 无 |
| Memory 类型 | user/feedback/project/reference | 无类型，按文件分（MEMORY.md/daily/beliefs） |
| 子 agent memory | 独立目录，三种 scope | 无（子 agent 无持久记忆） |
| Memory 容量控制 | MEMORY.md ≤200行/25KB | 无硬限制 |

## 可借鉴的设计

### 1. Feedback 同时记录纠正和确认
我们的 beliefs-candidates 只记"做错了什么"，不记"什么做对了"。Claude Code 的 insight："if you only save corrections, you will avoid past mistakes but drift away from approaches the user has already validated, and may grow overly cautious."
→ 应该在 nudge 里加：成功的非显而易见做法也值得记录

### 2. Memory Staleness 机制
老记忆被当成当前事实是真实风险。memoryAge.ts 的做法简单有效。
→ 可以在 memory_search 返回结果时加 staleness 标注

### 3. autoDream 的 Transcript 回顾
我们的 daily-review 不读历史对话（session transcript），只靠当天 memory 文件。Claude Code 会 grep JSONL transcripts 找具体信息。
→ OpenClaw 如果有 session transcript 存储，可以在 review 时回顾

### 4. Memory 类型化（frontmatter）
每个 memory 文件有类型标签，检索时可以按类型过滤。
→ 可以给 memory/ 下的文件加 frontmatter

### 5. MEMORY.md 容量控制
≤200 行硬限制 + 只放索引不放内容。我们的 MEMORY.md 已经很长了。
→ 考虑把 MEMORY.md 改为纯索引

## 其他有趣发现

### Feature Flags 无处不在
- `bun:bundle` 的 `feature()` 做编译时代码消除
- 关键 flag：PROACTIVE、KAIROS、BRIDGE_MODE、DAEMON、VOICE_MODE、AGENT_TRIGGERS、COORDINATOR_MODE、TEAMMEM
- GrowthBook 做运行时 A/B 测试（tengu_* 命名）

### Proactive Mode
- SleepTool + `<tick>` 定期唤醒 = 主动模式
- "Look for useful work to do before sleeping"
- 跟我们的 heartbeat 概念相似

### Plugin 系统
- `marketplaceManager.ts` — plugin marketplace
- 跟 ClawHub skill 生态类似

### 代码质量
- 大量 eval-validated 注释（"eval case 3, 0/2 → 3/3"）
- 每个 prompt 改动都有 A/B 测试数据支撑
- 注释里的失败案例分析非常详细

## 源码路径索引
- Memory 核心：`src/memdir/`
- 自动提取：`src/services/extractMemories/`
- 自动整理：`src/services/autoDream/`
- Agent 系统：`src/tools/AgentTool/`
- Skill 系统：`src/skills/`
- Coordinator：`src/coordinator/`
- Task 系统：`src/tasks/`

## 标签
self-evolving-agent, memory-system, claude-code, anthropic, source-analysis
