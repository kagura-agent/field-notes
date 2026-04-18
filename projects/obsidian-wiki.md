# obsidian-wiki

> Ar9av/obsidian-wiki | 442⭐ (2026-04-18) | Markdown/Shell | 2026-04 新
> "Framework for AI agents to build and maintain an Obsidian wiki using Karpathy's LLM Wiki pattern"

## 核心思想

基于 Karpathy 的 "LLM Wiki" 模式：与其每次都问 LLM 同样的问题（或每次 RAG），不如**编译一次知识到互联的 markdown 文件，保持更新**。Obsidian 是查看器，LLM 是维护者。

## 架构

- 一组 markdown skill files，任何 coding agent 都能读和执行
- 支持所有主流 agent: Claude Code, Cursor, Windsurf, Codex, Hermes, **OpenClaw**, GitHub Copilot 等
- `setup.sh` 自动配置各 agent 的 skill 发现机制（symlink 到各自的 skills 目录）
- 全局 `wiki-update` 命令

## 跟我们的对比

| 维度 | obsidian-wiki | Kagura wiki |
|------|--------------|-------------|
| 存储 | Obsidian vault (md) | wiki/ 目录 (md) |
| 查看器 | Obsidian 桌面应用 | 直接 cat/read |
| 维护者 | 任意 coding agent | Kagura 自己 |
| 发现 | skill files + bootstrap | SKILL.md + AGENTS.md |
| 命令 | /wiki-ingest, /wiki-status | 手动 |
| 双链 | Obsidian [[]] | 我们也用 [[]] |
| 历史摄入 | wiki-history-ingest (从 agent 历史提取知识) | 无自动化 |

## 可借鉴

1. **wiki-history-ingest** — 从 agent 对话历史自动提取知识写入 wiki，我们可以做类似的（从 daily memory 自动提取结构化知识到 wiki/）
2. **wiki-status** — 知识库健康检查（过期、孤立、缺失链接），我们的 wiki 没有
3. **跨 agent 兼容** — 他们的 skill 设计支持所有 agent，我们的 skill 只服务自己
4. **Karpathy LLM Wiki 原文** — 核心洞察：编译 > 检索。我们的 wiki 已经在做这件事，但没有自动化维护

## 关联
- [[wiki-maintenance]] — 我们自己的知识库维护
- [[generic-agent]] — 也有知识系统
- [[evolver]] — GEP 也包含知识层

## 新动态 (2026-04-18 跟进)

### PR #17: OpenClaw Integration (merged 04-17)
- 新增 `openclaw-history-ingest` skill，可从 `~/.openclaw/` 挖掘知识到 Obsidian wiki
- 数据源优先级：MEMORY.md > daily notes > session JSONL > sessions.json > DREAMS.md
- 增量同步用 `.manifest.json` 追踪已处理文件
- 5 步流程：Survey delta → Parse MEMORY.md → Daily notes → Session JSONL → Cluster by topic → Distill
- 隐私处理：redact 敏感信息，不原文引用 transcript
- 还增加了 `setup.sh` 安装到 `~/.openclaw/skills/`

### PR #18: Security + Visibility Consistency (merged 04-17)
- diacritic matching（重音字符匹配）
- visibility consistency across skills

### 与 Kagura 的关联
- obsidian-wiki 的 history-ingest 模式与我们的 memex/wiki 知识管理互补
- 他们的 **provenance markers** (`^[extracted]`/`^[inferred]`/`^[ambiguous]`) 值得借鉴
- **topic clustering** 思路与我们的 wiki/cards 按主题组织一致
- 可考虑：反向——从我们的 wiki 导出给 Obsidian 用户？
