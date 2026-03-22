# OpenViking — Context Database for Agents

> volcengine/OpenViking | 17.5k⭐ (+7.6k/周) | 字节跳动出品

## 一句话

Agent 的上下文数据库——用文件系统范式管理 memory/resources/skills，三层压缩让 agent 永远知道该记什么、该忘什么。

## 核心创新：L0/L1/L2 三层上下文

| 层 | 名称 | 大小 | 用途 | 类比（我们的做法） |
|---|---|---|---|---|
| L0 | Abstract | ~100 tokens | 核心身份，始终加载 | SOUL.md + IDENTITY.md |
| L1 | Overview | ~1k tokens | 活跃上下文，按需加载 | MEMORY.md 索引 |
| L2 | Detail | 原始文件 | 完整数据，检索加载 | memory/ 日志 + field-notes/ |

这就是他们的卖点：不是所有记忆都平等，分层管理 token 预算。

## 架构

```
Client → Service Layer → Storage
              ↓
    ┌─────────┼─────────┐
    ↓         ↓         ↓
 Retrieve  Session    Parse
    ↓         ↓         ↓
    └─────→ Compressor ←┘
              ↓
    Storage (AGFS + Vector)
```

### 7 个 Service

1. **FSService** — 文件系统操作（AGFS = Agent File System）
2. **SearchService** — 向量 + 全文检索
3. **SessionService** — 会话管理，自动压缩历史
4. **ResourceService** — 资源管理（外部知识、文档）
5. **RelationService** — 实体关系图
6. **PackService** — 上下文打包（把 L0+L1+检索到的 L2 拼成一个 prompt）
7. **DebugService** — 检索轨迹可视化

### 文件系统范式

目录结构管理三类东西：
- `memory/` — 对话记忆（自动压缩的）
- `resources/` — 外部知识（用户上传的文档等）
- `skills/` — agent 能力描述

**跟 OpenClaw 的目录结构异曲同工。** OpenClaw workspace 有 `memory/`、`SOUL.md`、skills 目录。两者独立演化出了类似的范式。

## "Self-Evolving" — 名不副实？

字节宣传的"self-evolving"实际上是：
- Session 对话自动压缩
- 从对话中提取长期记忆（memory commit）
- 记忆随时间沉淀（L2 → L1 → L0 的信息蒸馏）

**反直觉发现：** 字节这么大的公司，砸这么多工程量，做的"自我进化"本质上就是**自动 session 压缩 + 记忆提取**。这不是我们讨论的"方向感"级别的自我进化——agent 不会自己决定要学什么新技能、不会自己设定目标。

换句话说：OpenViking 让 agent 记得更好，但不让 agent 思考"我该往哪走"。

## 跟 OpenClaw 的关系

**互补，不竞争。**

- OpenViking = **context 层**（怎么管理 agent 的记忆和上下文）
- OpenClaw = **agent runtime 层**（怎么跑 agent、调工具、管 session）

理论上可以集成：OpenClaw agent 用 OpenViking 做记忆后端，替代现在手动的 MEMORY.md + memory/ 文件。

## 跟我们的关联

我们现在手动做的事，就是 OpenViking 系统化的版本：

| 我们 | OpenViking |
|---|---|
| SOUL.md（~100 token 核心身份） | L0 Abstract |
| MEMORY.md（索引 + 关键决策） | L1 Overview |
| memory/YYYY-MM-DD.md（原始日志） | L2 Detail |
| heartbeat 定期回顾 + 更新 MEMORY.md | 自动 session 压缩 + memory commit |

差异：
- 他们有向量检索，我们靠文件名 + grep
- 他们有自动压缩，我们靠 heartbeat 手动维护
- 他们有关系图（RelationService），我们还没有
- 但我们有田野笔记（对外部世界的观察），他们只管对话记忆

## 值得借鉴

1. **PackService 的思路** — 把多层上下文打包成一个 prompt，而不是全塞进去
2. **DebugService** — 检索轨迹可视化，知道 agent "为什么想到这个"
3. **memory commit** — 显式的记忆持久化操作，比我们的 memoryFlush 更原子化

## 不值得追

1. 他们的 AGFS 太重了——需要跑一个完整的存储服务
2. 对于单 agent 场景（我们），文件系统 + grep 够用
3. 向量检索在记忆量小的时候（<1000 条）可能不如关键词搜索

---

*侦察时间: 2026-03-22*
*来源: GitHub trending + README 分析*
