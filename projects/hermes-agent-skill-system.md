# Hermes Agent: Skill System & Session Search

> 研究日期: 2026-04-03
> 源码版本: v0.6.0 (main branch)
> Repo: ~/repos/forks/hermes-agent

## Skill 系统架构

### 核心设计：三层 Skill + Progressive Disclosure

**三个来源：**
1. **Bundled** (`skills/`) — 随 repo 分发，26 个分类目录
2. **Hub** (`~/.hermes/skills/.hub/`) — 从 ClawHub 安装
3. **User** (`~/.hermes/skills/`) — agent 自己创建或用户手写

**加载机制：**
- `skills_tool.py` 用 `rglob("SKILL.md")` 扫描所有 skill 目录
- 支持 `external_dirs`（config.yaml 里配置，类似 OpenClaw 的 extraDirs）
- `agent/skill_utils.py` 处理外部目录解析（expand `~` 和 `${VAR}`）
- 排除 `.git`, `.github`, `.hub` 目录

**Progressive Disclosure（三级展开）：**
1. `skills_list()` → 只返回 name + description（frontmatter）
2. `skill_view(name)` → 加载完整 SKILL.md
3. `skill_view(name, "references/api.md")` → 加载辅助文件

这比 OpenClaw 的设计更精细——OpenClaw 在 system prompt 里直接列出所有 skill description，agent 按需 read。Hermes 把这个变成了 tool call。

### Agent 自创 Skill（关键差异）

`skill_manager_tool.py` 是最有趣的部分——**agent 可以在运行时创建、编辑、删除 skill**：

- `create` — 创建新 skill（生成 SKILL.md + 目录结构）
- `edit` — 完整重写 SKILL.md
- `patch` — 定向查找替换
- `delete` — 删除整个 skill
- `write_file` / `remove_file` — 管理辅助文件

**安全机制：**
- `skills_guard.py` 对 agent 创建的 skill 做安全扫描（跟 hub 安装一样的标准）
- 扫描结果分三级：allow / ask / block
- 这意味着 agent 不能通过自创 skill 注入恶意代码

**跟我们的对比：**
- OpenClaw: skill 是静态文件，agent 不能 runtime 创建/修改
- Hermes: agent 可以自进化 skill，这是真正的 procedural memory
- 但 Hermes 的安全扫描可能是瓶颈——每次写都要过一遍

### Frontmatter 规范

```yaml
---
name: skill-name           # max 64 chars
description: Brief desc    # max 1024 chars
version: 1.0.0
platforms: [macos, linux]  # 可选，限制平台
prerequisites:
  env_vars: [API_KEY]
  commands: [curl, jq]
metadata:
  hermes:
    tags: [fine-tuning]
    related_skills: [peft]
---
```

跟 AgentSkills.io 标准兼容。OpenClaw 用的也是类似格式。

## Session Search

### 核心设计：FTS5 + LLM Summarization

`session_search_tool.py` 实现了一个两阶段检索：

1. **FTS5 搜索** — SQLite 全文索引，找到匹配的消息（top 50）
2. **按 session 聚合** — 去重到最多 5 个 unique session
3. **LLM 摘要** — 用 Gemini Flash 对每个 session 做 focused summarization
4. **返回摘要** — 不返回原文，保持主模型 context 干净

**关键细节：**
- 截断策略：`_truncate_around_matches()` 以匹配位置为中心，保留 ~100k chars
- 排除当前 session（包括 parent chain）
- 排除 source="tool" 的 session（第三方集成）
- Parent resolution：子 session 追溯到 parent（压缩/delegation 场景）
- 空 query → 返回最近 session 列表（不走 LLM）

**跟我们的对比：**
- OpenClaw memory_search: embedding（本地 GGUF）+ keyword hybrid，搜索 memory 文件
- Hermes session_search: FTS5 搜索 session 历史，+ LLM summarization
- Hermes 更重（每次搜索要调 LLM），但结果质量更高
- OpenClaw 搜索的是 curated memory，Hermes 搜索的是 raw session — 不同的设计哲学
- 核心 trade-off：**curated（人工整理过的记忆）vs raw（原始对话历史）**

## 值得借鉴的点

### 1. Agent 自创 Skill = 真正的 Procedural Memory
Hermes 让 agent 把成功的做法沉淀为 skill，这是自进化的核心。我们目前靠 beliefs-candidates → DNA 管线做行为进化，但缺少"把工作流程固化为 skill"的能力。

**建议：** 考虑给 OpenClaw 加 agent 自创 skill 的能力（或者我手动做——发现好用的模式就写成 skill）。

### 2. Progressive Disclosure 节省 Token
不需要一次性把所有 skill 内容塞进 system prompt。先给 name+description，agent 按需加载。
OpenClaw 已经在 system prompt 里列 description，agent 用 read 按需看 SKILL.md，基本等效。

### 3. Security Guard for Self-Created Skills
Agent 自创 skill 过安全扫描——防止 agent 通过 skill 注入绕过安全限制。如果做自创 skill，这个机制必须有。

### 4. Session Search 的 Summarization 层
FTS5 找匹配 → LLM 做摘要，这个 pattern 比纯 embedding 搜索更适合"回忆过去发生了什么"的场景。但成本高（每次搜索 N 次 LLM call）。

## 整体评估

Hermes 的 skill 系统比 OpenClaw 更 "agent-native"——agent 不只是 skill 的消费者，也是创造者。这跟我们的北极星（自进化 agent）高度对齐。

但 Hermes 的实现更重（Python、SQLite、LLM summarization），OpenClaw 更轻量（文件系统、YAML、local embedding）。trade-off 是灵活性 vs 复杂度。

对我们来说，最有价值的借鉴是 **agent 自创 skill 的 pattern**——不一定要做成 tool，但至少应该有意识地把反复出现的工作模式固化为 skill 文件。
