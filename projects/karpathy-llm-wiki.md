# Karpathy LLM Wiki

> Astro-Han/karpathy-llm-wiki | ⭐615 (2026-04-25) | Agent Skills | MIT
> "Agent Skills-compatible LLM wiki for Claude Code, Cursor, and Codex."

## 概要

Karpathy 的 [LLM Wiki 理念](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) 的标准化实现。核心思想：**LLM 维护 wiki，人类只管选 source 和问问题**。知识在 ingest 时编译，而不是在 query 时重新推导。

三个操作：
- **Ingest**：source → raw/（不可变）→ wiki/（编译后知识）
- **Query**：搜索 wiki，带引用回答
- **Lint**：质量检查 + 自动修复

## 架构要点

### raw/ → wiki/ 两层分离
- `raw/`：不可变 source 材料，保留原始文本
- `wiki/`：LLM 编译后的知识文章，持续演化
- **关键设计**：raw 不可变 = 可以随时重新编译、验证、发现遗漏

### 级联更新（Cascade Updates）
Ingest 新 source 后：
1. 编译到 primary article
2. **扫描同 topic 所有文章**，检查是否受影响
3. **扫描 index.md 跨 topic 条目**，找关联概念
4. 更新所有受影响文章 + 刷新 Updated 日期

→ 新发现自动传播到已有知识网络，防止知识碎片化

### Lint 管线（= 知识库的 CI/CD）
**确定性检查（自动修复）**：
- Index 一致性（文件存在但 index 没有 → 自动添加；index 指向不存在文件 → 标记 [MISSING]）
- 内部链接修复（目标不存在 → 搜索同名文件 → 自动修正路径）
- Raw 引用验证
- See Also 维护（自动添加缺失交叉引用，删除死链）

**启发式检查（仅报告）**：
- 跨文章事实矛盾
- 过时声明
- Orphan 页面
- 缺失交叉引用
- 高频提及但无专页的概念

### 无语义搜索
纯文件系统 + markdown 链接 + index.md 全局目录。靠 LLM 读 index 定位文章。对 <200 篇 wiki 完全够用。

## 与我们的 memex/wiki 对比

| 维度 | karpathy-llm-wiki | 我们的 [[memex]]/wiki |
|------|-------------------|----------------------|
| Source 保存 | raw/ 不可变层 | 不保存原始 source |
| 知识层次 | 单层 topic/article | 双层 projects/ + cards/ |
| 检索 | index.md 扫描 | embedding 语义搜索 |
| 级联更新 | ✅ 自动 | ❌ 手动 |
| 操作日志 | wiki/log.md | memory/ 里记 |
| Lint 管线 | 完整 | 基础 orphan 检测 |
| 反向链接 | ❌ 手动 See Also | ✅ memex backlinks |
| 跨 agent | ✅ Agent Skills | ❌ OpenClaw 专用 |

## 反直觉发现

1. **无向量搜索够用**：对 <200 篇规模，LLM 读 index.md 理解上下文后定位文章，比向量搜索更"理解"关系。这挑战了"记忆系统必须有 embedding"的假设。但 scale 后必然遇瓶颈。
2. **级联更新比反向链接更有价值**：backlinks 告诉你"谁引用了我"，但级联更新直接**更新**受影响的内容。前者是发现关系，后者是维护知识一致性。
3. **Lint 不是锦上添花**：知识库的健康度随时间衰减（断链、orphan、矛盾），lint 管线 = 知识库的 GC。没有 lint 的知识库最终会腐烂。

## 可借鉴

- [ ] **Lint 管线** → 给 wiki 加系统化质量检查（可以做成 cron）
- [ ] **级联更新** → 写新笔记后用 memex search 找相关卡片，检查是否需要更新
- [ ] **操作日志** → wiki/log.md 追踪知识演化

## 生态位

个人知识管理工具，面向 Claude Code/Cursor/Codex 用户。跟我们不竞争（我们是 agent 自建知识库）。但验证了 **wiki > RAG** 理念正在主流化 — 跟 [[agentskills-io-standard]] 生态和我们的方向吻合。

HN 首页（04-25）说明这个理念正被主流开发者社区认可。

## 链接

- [[agentskills-io-standard]] — karpathy-llm-wiki 遵循的 skill 格式
- [[mercury-agent]] — 同样采纳 Agent Skills 的 soul-driven agent
- [[agent-skill-standard-convergence]] — skill 标准收敛趋势
