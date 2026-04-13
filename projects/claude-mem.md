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
| 检索 | SQLite FTS5 + Chroma hybrid + progressive disclosure | memex semantic search + wiki [[双链]] |
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

## 贡献机会

- OpenClaw 集成已有官方支持（installer script），可参与改进
- 31 open issues (截至 2026-04-13)
- AGPL-3.0 要求 derivative works 也开源

---
*Created: 2026-04-13 | Source: GitHub README + v12.0.0/12.0.1/12.1.0 release notes + PR #1653*
