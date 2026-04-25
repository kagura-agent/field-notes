# Agent Experience Capitalization (expcap)

- **Repo**: huisezhiyin/agent-experience-capitalization
- **Stars**: 17 (2026-04-24)
- **Created**: 2026-04-21
- **Language**: Python
- **License**: Apache-2.0
- **Tags**: [[agent-memory-taxonomy]], team-memory, [[skill-is-memory]]

## What

**TEAM memory** — Transferable Engineering Asset Memory. 把 coding agent 的工作经验转化为项目级可复用资产。核心区别：memory 属于项目而非个人/模型。

## 核心生命周期

```
trace → episode → candidate → asset
```

1. **Trace**: 原始工作记录（命令、错误、文件变更）
2. **Episode**: 结构化复盘（目标、约束、转折点、尝试路径、经验教训）
3. **Candidate**: 可复用候选（pattern 或 anti-pattern），带置信度评分
4. **Asset**: 经过验证的知识资产，带 effectiveness tracking

## 架构洞察

### Asset Effectiveness Tracking (温度系统)
- 每个 asset 有 activation_count、support_ratio
- **hot**: ≥2 次强支持 or ≥75% 支持率 → 核心资产
- **warm**: 至少 1 次支持 → 初步验证
- **cool**: ≥4 次激活但 <20% 支持 → 需要 review（可能过时或错误）
- **neutral**: 未验证

这解决了一个真实问题：memory 积累容易，淘汰难。温度系统让 asset 自然老化。

### Scope Inference
- 从任务描述推断 scope（`python-import-error`、`test-failure`、`general-coding-task`）
- 粒度粗，但方向对：不同类型的经验需要不同的检索策略

### Candidate Promotion
- 自动提取 candidate 但需要 review 才能晋升为 asset
- `should_promote_candidate` 检查 reusability_score、stability_score、验证状态
- 防止低质量经验直接成为"最佳实践"

## 反直觉发现

1. **项目级 > 个人级**：大多数 agent memory 工具（memex、auto-memory、cavemem）都是个人级的。expcap 明确说"memory 属于项目"——团队新成员（人或 agent）继承项目经验
2. **中文优先**：lesson、turning_points 等关键字段默认生成中文。说明作者的实际使用场景是中文团队
3. **Codex Skill 优先**：直接提供 `skills/expcap/SKILL.md`，让 agent 通过 skill 调用而非用户记 CLI

## 与我们的对比

| 维度 | expcap | 我们的 wiki/memex |
|------|--------|-------------------|
| Memory 归属 | 项目级 | 个人级（Kagura 的知识） |
| 生命周期 | trace→episode→candidate→asset（4 阶段） | 直接写卡片 |
| 验证机制 | 温度系统（activation tracking） | 无自动验证（靠人工 review） |
| 检索 | Milvus 向量搜索 | memex 语义搜索 |
| 淘汰 | cool assets 自动标记 review | 手动（orphan 检查） |

## 可借鉴的点

1. **温度系统**：给 wiki cards 加 activation tracking——每次 study/workloop 引用了哪些卡片，哪些从未被检索过 → 自然淘汰
2. **候选管线**：我们的 beliefs-candidates.md 已经是类似设计，但缺少 promotion 的量化标准
3. **项目级 memory**：打工时每个 repo 的经验目前分散在 memory/ 日志里，可以考虑 per-repo 结构化

## 在 Agent 生态中的位置

- 与 [[cavemem]]（cross-agent compressed memory）互补：cavemem 做个人跨工具记忆，expcap 做项目内团队记忆
- 与 [[auto-memory]]（session replay）不同层次：auto-memory 是 session 级回放，expcap 是 lesson 级提炼
- 竞争 [[claude-code-memory-architecture]] 的 CLAUDE.md per-project memory，但更结构化

## 局限

- 17⭐，极早期，代码质量一般
- scope inference 太粗（只有 3 种）
- 没有跨项目知识迁移（项目间的共性经验怎么办？）
- Milvus 依赖重（对个人开发者）

---

*Filed: 2026-04-24 | Study #741 quick_scout → deep_read*
