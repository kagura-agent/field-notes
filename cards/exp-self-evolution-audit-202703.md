# 自进化机制全盘点 — 2026-03-27

## 总览

| 机制 | 写（存入） | 读（取出） | 触发时机 | 实际有效？ |
|------|-----------|-----------|---------|-----------|
| MEMORY.md | 手动写 | session 启动自动注入 | 每次对话开始 | ⚠️ 注入了但太长，不一定被注意 |
| memory/日记 | 手动写 / nudge 提醒 | session 启动注入今天+昨天 | 每次对话开始 | ⚠️ 同上 |
| beliefs-candidates | nudge 触发写入 | 手动 grep / daily-review | 无自动读取时机 | ⚠️ 写入有效，读取基本没有 |
| DNA (AGENTS.md/SOUL.md) | 手动升级（3次阈值） | session 启动自动注入 system prompt | 每次对话开始 | ❌ 注入了但行为不改（知行鸿沟） |
| knowledge-base | 手动写 / study workflow | 手动 cat / workloop study 节点 | FlowForge study 节点 | ❓ 有写，读取不可审计 |
| self-improving | 手动写 | AGENTS.md 说"干活前读" | 靠自觉 | ❌ 基本不读 |
| memory_search | N/A（检索工具） | 语义搜索 | system prompt 说"回答前先搜" | ❌ 从未工作（未配置 provider） |
| FlowForge | workflow yaml 定义 | 节点 task 描述指导行动 | skill 意图匹配 / 手动 start | ✅ 触发有效，但执行内容不可审计 |
| Nudge | 自动触发写 beliefs | 不涉及读 | agent_end hook，每5次 | ✅ 写入管线有效 |
| Heartbeat | HEARTBEAT.md 定义任务 | 执行时读 HEARTBEAT.md | 每30分钟 | ✅ 触发有效（3/24 修复后） |
| Cron (8个job) | 各 job 独立输出 | 各 job 独立 session | 定时触发 | ⚠️ 触发有效，输出质量参差 |
| Daily Review | 写 evolution-log | 读 workspace 全量盘点 | cron 3:00 | ❌ 审计抓出14个错误 |
| Daily Audit | 写 evolution-log 审计段 | 读 review 结果并验证 | cron 6:00 | ⚠️ 能抓错但无闭环修正 |
| evolution-log | daily-review/audit 写入 | 几乎不读 | 无自动读取 | ❓ 跟 memory 重复，价值不明 |

## 按"读写时机"分类

### ✅ 有效的写入机制
- **Nudge → beliefs-candidates**: agent_end hook 自动触发，每5次对话后写入。管线畅通 [已验证: 56条beliefs]
- **Heartbeat → 巡检任务**: 每30分钟读 HEARTBEAT.md 执行。触发可靠 [已验证: 3/24修复后]
- **FlowForge → workflow 推进**: skill 意图匹配触发 workflow。触发有效 [已验证: 20个instance 3/26]
- **memory/日记**: nudge 提醒 + 手动写入。写入频率够 [已验证: 21个daily文件]

### ❌ 断裂的读取机制
- **beliefs-candidates**: 56条写入，但没有任何自动读取时机。daily-review 会扫，但 review 本身质量差
- **self-improving/**: 写了26条 pattern，AGENTS.md 说"干活前读"，但没有强制触发点。靠自觉 = 不读
- **knowledge-base**: 68 cards + 58 projects，workloop study 节点说"必须先读"，但执行不可审计
- **evolution-log**: daily-review 写入，daily-audit 读取验证，但审计后的修正没闭环

### ❌ 完全不工作的
- **memory_search**: 未配置 embedding provider，provider=none，从未返回过结果

### ⚠️ 注入了但效果存疑的
- **DNA (system prompt)**: AGENTS.md 和 SOUL.md 每个 session 都注入。但"数据纪律"升级后仍犯3+次。注入 ≠ 遵守。问题是 system prompt 太长（AGENTS.md 已经很大），规则被淹没
- **MEMORY.md**: 275行，每个 session 注入。作为索引有用，但太长时重要信息被忽略

## 核心问题

### 1. 写入 >> 读取
- 56条 beliefs 写了，读取靠 daily-review（质量差）或手动 grep（几乎不做）
- 26条 self-improving 写了，几乎不读
- 68张 knowledge-base 卡片写了，读取只在 workloop study 节点（不可审计）
- **写入有很多自动触发点（nudge、heartbeat、cron），读取几乎没有**

### 2. 注入 ≠ 执行
- DNA 规则注入到 system prompt，但行为不改
- 可能原因：prompt 太长规则被淹没 / 规则太抽象不够具体 / 没有情境触发只是背景知识
- 这是 EXP-006（知识-行为鸿沟）的核心问题，至今未解

### 3. 触发时机的三种模式
- **自动注入**（session start）: MEMORY.md, DNA → 可靠但被动，信息过多时被忽略
- **流程嵌入**（FlowForge node）: workloop study → 确定性高但僵硬，只在走流程时触发
- **自觉调用**（靠 agent 想起来）: memory_search, self-improving → 基本无效

缺少的第四种：**情境感知的主动推送**——检测到当前意图后自动加载相关知识。这是 EXP-012（图书管理员）要解决的。

### 4. 质量保证缺失
- Daily review 质量差（审计抓14个错）
- 自己写自己查，无外部验证
- `[已验证]` 标签失信

## 哪些该留，哪些该改，哪些该砍？

### 留（有效且需要）
- **Nudge → beliefs-candidates 管线**: 唯一可靠的反思写入机制
- **Heartbeat**: 唯一可靠的定期巡检机制
- **FlowForge skill**: 唯一有效的意图→流程触发
- **memory/日记 + MEMORY.md**: 基础记忆层，不可替代

### 改（有价值但执行有问题）
- **memory_search**: 配上 embedding provider 就能工作，低成本高收益
- **Daily review**: 缩小范围，提高每项验证质量，或者改成只做增量检查
- **knowledge-base 读取**: 需要自动触发机制（图书管理员 or 流程嵌入）
- **beliefs-candidates 读取**: 需要在升级判断时自动加载，不是等 daily-review

### 砍或合并（投入>产出）
- **evolution-log**: 跟 memory/日记 + daily-review 重复，三个地方记同一件事
- **self-improving/**: 跟 knowledge-base + beliefs-candidates 重叠，26条 pattern 已迁移过一次又 revert
- **Daily audit**: 如果 daily review 质量提上去，就不需要再查一遍
