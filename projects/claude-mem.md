# claude-mem

> thedotmack/claude-mem | 50,000⭐ | TypeScript | AGPL-3.0
> "Persistent memory compression system built for Claude Code"

## 核心架构

### 组件
1. **5 Lifecycle Hooks** — SessionStart, UserPromptSubmit, PostToolUse, Stop, SessionEnd
2. **Worker Service** — Bun HTTP API on port 37777 + Web Viewer UI
3. **SQLite DB** — sessions, observations, summaries
4. **Chroma Vector DB** — hybrid semantic + keyword search
5. **mem-search Skill** — 自然语言查询，progressive disclosure
6. **Knowledge Agents** (v12.1.0) — 从观察历史构建可查询语料库

### 数据流
```
Claude Code session
  → hooks capture tool usage observations
  → SQLite + Chroma storage
  → semantic summaries generated
  → future session context injection (SessionStart)
```

### Progressive Disclosure（3 层 token 节省）
1. `search` — 紧凑索引（~50-100 tokens/result）
2. `timeline` — 时间线上下文
3. `get_observations` — 完整详情（~500-1,000 tokens/result）
约 10x token 节省（先过滤再获取详情）

## v12 系列重大更新

### v12.0.0 (2026-04-07) — File-Read Gate + 24 语言 + Platform Isolation
- **File-Read Decision Gate**: PreToolUse hook 拦截冗余文件读取，注入 observation history 并 deny read — 节省 token
- **Smart-Explore 24 语言**: tree-sitter AST 解析 TS/JS/Python/Rust/Go/Java 等
- **Platform Source Isolation**: Claude/Codex session 命名空间隔离，防交叉污染
- **OpenClaw 集成**: workerHost config for Docker，plugin manifest
- 40+ bugfix（Windows/Linux/macOS），安全修复（shell injection, SQL injection, path traversal）

### v12.1.0 (2026-04-09) — Knowledge Agents
- **核心概念**: 从观察历史中过滤、编译语料库（corpus），prime 到 AI session，多轮对话式查询
- **技术栈**: Agent SDK V1 `query()` + `resume` + `disallowedTools`（纯 Q&A，无工具调用）
- **6 MCP tools**: build_corpus, list_corpora, prime_corpus, query_corpus, rebuild_corpus, reprime_corpus
- **8 HTTP endpoints**: CRUD + prime/query/reprime
- **CorpusBuilder**: 搜索 observations → hydrate 完整记录 → 统计 → 持久化到 `~/.claude-mem/corpora/`
- **CorpusRenderer**: 渲染 observations 为完整 prompt text（利用 1M context window）
- **Auto-reprime**: session 过期自动 reprime + retry
- **安全**: path traversal 防护、instruction injection 硬化、input validation
- **测试**: 31 个 e2e 测试覆盖完整 corpus lifecycle
- +2012/-269 行，17 文件

## 跟我们的对比

| 维度 | claude-mem | Kagura (OpenClaw) |
|------|-----------|-------------------|
| 数据源 | Claude Code tool usage observations | 全渠道（Discord/飞书/heartbeat/学习/打工） |
| 记忆层级 | observations → summaries → corpora | daily memory → MEMORY.md → wiki cards/projects |
| 检索 | SQLite FTS5 + Chroma hybrid + progressive disclosure | memex semantic search + wiki 双链 |
| 进化 | 无（只记录不进化）| beliefs-candidates → DNA/Workflow/KB 管线 |
| Skill 发现 | 无 | nudge hook [SKILL] 标签（刚落地） |
| 可查询 | Knowledge Agents（corpus → AI session Q&A）| memex search（纯检索，无 Q&A） |
| 维护 | 自动（hooks 全自动捕获+压缩）| 半自动（nudge 触发 + 手动 review）|
| 平台 | Claude Code / Gemini CLI / OpenClaw | OpenClaw（多平台集成）|
| 开源协议 | AGPL-3.0 | — |

## 关键差异

### 他们优势（我们没有的）
1. **全自动观察捕获** — hooks 无需人工干预，PostToolUse 自动记录每次工具调用
2. **File-Read Decision Gate** — 拦截冗余文件读取，实现 token 级别优化
3. **Progressive Disclosure** — 3 层渐进式检索，10x token 节省
4. **Knowledge Agents** — 从历史数据构建可对话的知识库，超越纯检索
5. **Web Viewer UI** — 实时观察流可视化

### 我们优势（他们没有的）
1. **进化层** — beliefs-candidates → DNA 管线，从经验中提炼原则（claude-mem 只记录不进化）
2. **多渠道数据** — 不限于 coding session，覆盖聊天/学习/打工/社区等全场景
3. **Skill 生态** — 15+ skills 覆盖不同任务类型
4. **自治运行** — 22 cron + heartbeat + nudge 实现 24/7 自主运转
5. **FlowForge workflow** — 结构化多步骤任务执行

### 可借鉴方向
1. **Progressive Disclosure 模式** — search→timeline→detail 3 层，直接适用于 memex 优化
2. **Knowledge Agents 模式** — 从 wiki/memory 构建可查询 corpus，超越关键词检索
3. **File-Read Gate** — 类似思路可用于减少重复 skill context 注入（呼应 skill lazy-loading）
4. **自动观察记录** — nudge 已有基础，但粒度和自动化程度差很多
5. **Platform Source Isolation** — 多 channel/多 agent 场景下的 context 隔离

## 战略评估

claude-mem 50k 星验证了 **agent 记忆是刚需**。它的爆火来自两个因素：
1. 零配置安装（`npx claude-mem install` 一行搞定）
2. 解决真实痛点（session 间上下文丢失）

但它本质是 **记录层**（capture+retrieve），不是 **进化层**（learn+improve）。它的 Knowledge Agents 往前走了一步（从检索到对话），但仍缺少 "从经验中提炼可执行原则" 的能力。

我们的差异化在于：从记录到进化。claude-mem 告诉你 "你上次做了什么"，我们告诉你 "你该怎么做得更好"。

## Knowledge Agents 架构深读（源码级）

读了 `src/services/worker/knowledge/` 全部 6 文件（types, KnowledgeAgent, CorpusBuilder, CorpusStore, CorpusRenderer, index）。

### 核心设计决策
1. **所有工具阻断** — 12 个工具全部 disallowed（Bash/Read/Write/Edit/Grep/Glob/WebFetch/WebSearch/Task/NotebookEdit/AskUserQuestion/TodoWrite），纯 Q&A 模式
2. **Corpus = JSON 文件** — 持久化到 `~/.claude-mem/corpora/<name>.json`，alphanumeric name validation + resolved path check（防 path traversal）
3. **Prime = 全量注入 1M context** — CorpusRenderer 将所有 observations 渲染为 prompt text，一次性 prime 到 Claude session
4. **Session Resume** — 后续 query 通过 Agent SDK V1 `resume: session_id` 多轮对话，无需重新 prime
5. **Auto-reprime** — session 过期时自动检测（regex: session|resume|expired|invalid|not found）并 reprime + retry
6. **CorpusBuilder 流水线**: SearchOrchestrator.search() → getObservationsByIds() → mapToCorpus → calculateStats → renderCorpus → estimateTokens → persist

### 反直觉发现
- **No RAG for Knowledge Agents** — 它没用 Chroma vector search 做检索，而是把 corpus 全量塞进 1M context window。这跟 [[llm-wiki-karpathy]] 的洞察一致：personal scale 不需要 RAG
- **Token 预算外置** — token_estimate 在 build 时计算但不在 query 时 enforce。用户自己控制 corpus 大小
- **Error tolerance 很高** — SDK process exit 后如果已经拿到 answer/session_id 就视为成功（catch 里只 log 不 throw）

### 生态位置
- 在 agent memory 生态中跟 [[claude-memory-compiler]]（coleam00, 525★）、[[metaclaw]]、[[nanobot]] Dream 都在做记忆管理
- claude-mem 体量最大（50k★），但架构最"传统"——核心是 capture+compress+retrieve
- Knowledge Agents 是走向 "可对话知识库" 的尝试，类似 [[evo-nexus]] 的 ADW 但更轻量
- 与 [[skillclaw]] 对比：claude-mem 完全没有 skill evolution 概念，只做知识管理不做行为优化

## v12.4.4-v12.4.7 "Cynical Deletion" Era (2026-04-25~26)

### 核心哲学：Delete the Moats

PR #2141 一次性关闭 27 个 issue，通过**删除两种反模式**而非修补它们：

#### Defenders（防守者）
"为了防止 X 而加的代码，但防守代码本身产生的 bug 比它防止的更多"
- `aggressiveStartupCleanup()` — 启动时扫描并杀死孤儿进程（~190 行，Windows WQL + Unix ps 解析）
- PowerShell `-EncodedCommand` spawn — 为了处理 Windows 路径空格的 shell 字符串拼接
- restart-with-port-steal — 为了处理端口占用的强制杀进程逻辑
- duplicate-worker liveness probes — 重复 worker 检测

每个 defender 引入新的平台特定 bug（WQL 语法、Git Bash `$_` 解释、空格路径引号、SIGKILL 杀祖先进程），形成**防守螺旋**。

#### Tolerators（容忍者）
"遇到异常数据时 silently drop/passthrough 而非报错，隐藏 bug 直到更大规模爆发"
- 静默 JSON 丢弃 — stdin 收到 malformed JSON 返回 undefined 而非报错
- 漂移的 SSE/SQL filters — SSEBroadcaster 和 PaginationHelper 各自实现 observer-session 过滤，逐渐不同步
- `.passthrough()` Zod schemas — 接受任意字段然后 insert 时丢弃，用户以为数据存了实际没存
- file-context `updatedInput: { limit: 1 }` — 截断 Read 结果但告诉模型"文件已读"，导致 Edit 死锁

### 9 个阶段的手术

| Phase | 动作 | 关闭 Issues | 关键改动 |
|-------|------|------------|----------|
| P1 | 删除进程管理戏剧 | 9个 | 删 `aggressiveStartupCleanup`(190行)、PowerShell spawn、port-steal |
| P2 | 信任边界重建 | 2个 | `CLAUDE_MEM_INTERNAL=1` env var 替代 cwd-based 判断；新 `shouldEmitProjectRow` 共享谓词 |
| P3 | 硬编码清除 | 3个 | 8处 `37777` → `SettingsDefaultsManager.get()`；多账户文档 |
| P4 | 环境变量净化 | 2个 | `HTTP_PROXY` 等 10 个代理变量无条件剥离（拒绝 whitelist 提案） |
| P5 | Fail-fast | 3个 | stdin-reader reject malformed JSON；file-context 不再截断 Read |
| P6 | 小删除 | 5个 | 外置 Zod、删 `setFallbackAgent`、session timeout 4h→24h、删 `installCLI()` |
| P7 | 安装修复 | 1个 | 共享 `shutdown-helper`、uninstall 路径覆盖 |
| P8 | 确定性安装 | 3个 | pin `chroma-mcp==0.2.6` |
| P9 | 测试更新 | 1个 | per-UID port + migration 30 测试 |

### 关键架构决策

1. **Single trust boundary** — `CLAUDE_MEM_INTERNAL=1` env var 在 `buildIsolatedEnv` 设一次，所有内部 agent 继承。取代了分散在各处的 `cwd === OBSERVER_SESSIONS_DIR` 检查。Belt-and-braces: 旧检查保留作后备。

2. **Shared predicate** — `shouldEmitProjectRow()` 函数同时被 SSE 和 Pagination 使用，**物理上不可能漂移**（同一个函数引用）。

3. **`.strict()` 替代 `.passthrough()`** — MemoryRoutes Zod schema 从 passthrough 改为 strict，新增 `metadata` 字段（migration 30）。未知字段直接 400 而非静默丢弃。

4. **Never modify the Read call** — file-context hook 从"截断文件读取+注入时间线"改为"保持原始 Read 不变+附加补充上下文"。修复了 Edit 死锁：模型看到完整文件内容，不再在截断快照上循环 Edit。

5. **拒绝 config knobs** — proxy 处理拒绝了 #2099 的 whitelist 提案（"don't add new config knobs, fix the default"）。session timeout 直接 4h→24h（no knob）。

### v12.4.4 SessionEnd Shim 移除
PR #2136: 发现 `SessionEnd → session-complete` hook 从 2025-11-07 开始就在静默清空 observation queue（`/clear`、退出、注销都触发）。6 个月的 bug。修复：**删除整个 SessionEnd hook**，worker 通过 SDK-agent generator 的 finally-block 自行完成。

### v12.4.5 Migration 28 Mirror Fix
`SessionStore` 缺少 migration 28 的列（`tool_use_id`, `worker_pid`），新安装的 DB 每次 insert 都因 "no such column" 静默失败。加了 mirror columns + column-existence guards 自愈。

### Tradeoffs
- **删除 defender = 不再自动处理孤儿进程** — 用户如果有端口被占需要手动解决。赌注：PID file + fail-fast 比自动杀进程更可靠
- **无条件剥离 proxy vars** — 如果内部 API 调用确实需要 proxy（企业环境），会 break。但认为"internal API calls should never go through user proxy"
- **session timeout 24h 无旋钮** — 简化但不灵活

## 对我们的启发

### Pattern 1: Defender/Tolerator 识别框架
**直接可用。** 审视我们自己的代码和流程时，可以用这个透镜：
- 这段逻辑是在"防守"某个问题？它防守的过程中是否产生了新问题？
- 这段逻辑在"容忍"异常数据？它隐藏的 bug 未来会不会更大规模地爆发？

我们的 candidates:
- nudge hook 的各种 edge case 处理 — 是否变成了 defenders？
- memory 写入时的 silent failures — 是否是 tolerators？

### Pattern 2: Shared Predicate > Repeated Logic
当两个地方需要做同一个判断时，提取为一个函数引用，**物理上消除漂移可能**。不是"保持同步"的纪律问题，是工程结构问题。

### Pattern 3: 拒绝 Config Knobs
"Fix the default, don't add a knob." 每个 config 选项都是表面积。如果 default 是错的，修 default；如果需要 per-user 定制，大概率说明架构不对。

### Pattern 4: Plan-Driven Deletion
写一个详细的 plan document **在动手之前**，列出：
- 什么是 defender，什么是 tolerator
- 每个要删的东西为什么要删
- 什么要保留（anti-pattern guards）
- 验证方法

claude-mem 的 `plans/2026-04-25-cynical-deletion.md` 是这个模式的典范。

### Pattern 5: 6 个月的静默 Bug
SessionEnd hook 从 2025-11 就在清空 queue，但因为症状分散（"偶尔丢 observation"）没人定位到根因。教训：**tolerator 的 half-life 可以非常长**。我们的 memory pipeline 有没有类似的 silent data loss？

## 贡献机会

- OpenClaw 集成已有官方支持（installer script），可参与改进
- 27 issues 一次关闭后 open issues 大幅减少
- AGPL-3.0 要求 derivative works 也开源
- 项目从 50k → 67.6k⭐，增长迅猛

---
*Created: 2026-04-13 | Updated: 2026-04-26 | Source: GitHub README + v12.0.0-12.4.7 release notes + PR #2141 plan document + source diffs*
