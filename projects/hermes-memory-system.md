# Hermes Agent — Memory System Deep Dive

> 研究日期: 2026-04-03 | Repo: NousResearch/hermes-agent | ⭐ 11.8k

## 架构概览

Hermes 的记忆系统是**三层架构**：

```
MemoryManager（编排器）
  ├── BuiltinMemoryProvider（始终在线，MEMORY.md + USER.md）
  └── 最多一个 External Provider（Honcho/Hindsight/Mem0/OpenViking/Holographic/RetainDB/ByteRover）
```

核心约束：**Built-in 始终存在 + 最多一个外部 provider**。这防止了工具 schema 膨胀和后端冲突。

## 1. MemoryProvider ABC（接口契约）

文件：`agent/memory_provider.py`

**核心生命周期：**
- `initialize(session_id)` — 连接、创建资源
- `system_prompt_block()` — 注入 system prompt 的静态文本
- `prefetch(query)` — 每次 turn 前的背景 recall
- `sync_turn(user, assistant)` — 每次 turn 后的异步写入
- `get_tool_schemas()` — 暴露给模型的工具定义
- `handle_tool_call()` — 处理工具调用
- `shutdown()` — 清理退出

**可选 hook（override opt-in）：**
- `on_turn_start(turn, message)` — 每 turn 带运行时上下文
- `on_session_end(messages)` — session 结束时提取
- `on_pre_compress(messages) → str` — context 压缩前提取
- `on_memory_write(action, target, content)` — 镜像 built-in memory 写入
- `on_delegation(task, result)` — parent 观察子 agent 工作

**与我们的对比：** OpenClaw 的 memory_search/memory_get 是平面工具，没有 provider 抽象。Hermes 的 ABC 更适合做 pluggable memory。

## 2. Built-in Memory（MEMORY.md + USER.md）

文件：`tools/memory_tool.py` + `agent/builtin_memory_provider.py`

**设计亮点：**
- 双文件：MEMORY.md（agent 的笔记）+ USER.md（关于用户的知识）
- **冻结快照模式**：session 开始时注入 system prompt，mid-session 写入只更新磁盘，不改 system prompt → 保护 prefix cache
- 条目分隔符：`§`（section sign），支持多行
- 字符限制（非 token），模型无关
- **单工具多 action**：`memory` tool 有 add/replace/remove/read 四个 action
- replace/remove 用 **短唯一子串匹配**（不是全文或 ID）
- 文件锁：`fcntl` 防并发写入
- **注入扫描**：写入前检查 prompt injection / exfiltration pattern（regex 检测）

**与我们的对比：** 
- 我们用 MEMORY.md + memory/YYYY-MM-DD.md（日记模式），Hermes 用 MEMORY.md + USER.md（角色分离模式）
- 我们没有冻结快照——每次 memory_search 都是实时查，但也不注入 system prompt
- Hermes 的注入扫描值得借鉴（我们的 memory 直接写入无过滤）

## 3. Session Search（跨 session 回忆）

文件：`tools/session_search_tool.py`

**Flow：**
1. SQLite FTS5 搜索历史 session 消息
2. 按 session 分组，取 top N（默认 3）
3. 截取匹配点附近 ~100k 字符
4. 发给 Gemini Flash 做摘要（不是把原文返回给主模型）
5. 返回每 session 的摘要 + metadata

**关键设计：** 用便宜模型做摘要再返回，避免把大量历史塞进主模型 context。

**与我们的对比：** OpenClaw 的 memory_search 只搜 MEMORY.md + memory/*.md，不搜历史 session 对话。Hermes 可以搜所有历史对话。

## 4. 外部 Memory Providers（7 个）

| Provider | 类型 | 特色 |
|---|---|---|
| **Honcho** | Cloud API | 4 工具：profile（peer card）、search（语义）、context（LLM Q&A）、conclude（持久化结论） |
| **Hindsight** | Cloud/Local | 知识图谱 + 实体解析 + 多策略检索。支持 cloud API 和本地 PostgreSQL |
| **Mem0** | Cloud API | 服务端 LLM 事实提取 + 语义搜索 + reranking + 自动去重 |
| **OpenViking** | Cloud API | session-managed memory + 自动提取 + 分层检索 + 文件系统式知识浏览 |
| **Holographic** | Local SQLite | FTS5 搜索 + trust scoring + HRR（Holographic Reduced Representation）组合检索 |
| **RetainDB** | Cloud API | 混合搜索 + 7 种记忆类型 |
| **ByteRover** | CLI (brv) | 持久知识树 + 分层检索，通过外部 CLI 工具 |

**关键观察：**
- 7 个 provider 覆盖了 memory 生态的主要玩家
- 只有 Holographic 是纯本地的（SQLite）
- Honcho 最成熟（13.8KB 实现，4 个独立工具 schema）
- Hindsight 和 OpenViking 有 `on_session_end` hook（session 结束时自动提取）
- ByteRover 有 `on_pre_compress` hook（context 压缩前提取）

## 5. MemoryManager（编排器）

文件：`agent/memory_manager.py`

- 管理 provider 注册（built-in 始终第一，外部最多一个）
- `build_system_prompt()` — 合并所有 provider 的 prompt block
- `prefetch_all(query)` — 并行 prefetch 所有 provider
- `sync_all(user, assistant)` — 异步同步所有 provider
- Provider 失败互不阻塞（隔离故障）
- 工具路由：根据 tool name 分发到对应 provider

## 关键借鉴

### 可以直接借用的
1. **冻结快照模式** — session 内 memory 读写不改 system prompt，保护 prefix cache
2. **内存注入扫描** — 写入前 regex 检测 prompt injection / exfiltration
3. **session search 用便宜模型摘要** — 避免历史对话撑爆主模型 context
4. **on_memory_write hook** — 外部 provider 可以镜像 built-in 写入（同步到外部存储）

### 架构差异需要注意的
5. **Provider ABC** — Hermes 的 pluggable 设计比 OpenClaw 的平面工具更优雅，但我们不需要 7 个 provider（我们的 memory_search 本地 GGUF 就够了）
6. **USER.md 角色分离** — Hermes 把"关于用户"和"agent 自己的笔记"分开。我们用 USER.md + MEMORY.md 已有类似分离，但我们的 MEMORY.md 混了"关于世界"和"关于自己"

### 打工潜力
- **已是主力打工 repo**（92 merged PRs 中有不少是 Hermes 的）
- 记忆系统是最对齐我们方向的模块
- 可以考虑给新 provider 写集成（如果有新的 memory 服务出现）
- session_search 的 FTS5 + 摘要模式可以帮 OpenClaw 改进 memory_search
