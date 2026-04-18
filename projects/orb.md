# Orb

> Self-evolving AI agent framework wrapping Claude Code CLI with persistent memory, multi-profile isolation, and messaging platform integration.

- **repo**: KarryViber/Orb
- **创建**: 2026-04-16
- **语言**: JavaScript + Python (~2.6k JS LOC + Python bridges)
- **Stars**: 44 (2026-04-18)
- **定位**: Claude Code 的"操作系统层"——不重写 agent runtime，而是在 Claude Code CLI 外包一层

## 核心机制

### 架构: Adapter → Scheduler → Worker → Claude Code CLI
- **One-shot fork per task**: 每个用户消息 spawn 一个 Claude Code CLI 进程（`claude --print` 或交互模式）
- **Context Assembly**: 每次调用前组装 prompt = Soul Layer + Holographic Memory recall + DocStore search + Skills Index
- **IPC protocol**: Scheduler ↔ Worker 用 Node IPC（`process.send`），支持 approval flow 和 mid-turn injection

### Holographic Memory（核心创新）
- **无 embedding、纯本地**: SQLite FTS5 (BM25) + Token overlap (Jaccard) + HRR phase vectors，三种检索混合打分
- **Write-time LLM arbitration**: 新 fact 写入时，取 top-3 近邻 → Haiku 判断 ADD/UPDATE/DELETE/NONE（灵感来自 [[mem0]]）
- **Bi-temporal tombstones**: 被取代的 fact 不删除，标 `invalid_at` + `superseded_by`（灵感来自 [[graphiti]]）
- **Frozen trust scores**: 信任分写入时设定（confirmed/default/speculative），不做时间衰减——生日等低频但真实的 fact 不会被遗忘
- **Self-healing**: 每日 memory-lint 检测孤立 fact 和重复

### Self-Evolution（错误蒸馏循环）
1. Fact extraction: 对话 → 分类 facts (preference, decision, lesson, knowledge, entity)
2. Error distillation: 错误 → `distill.py` 用 Haiku 提取 actionable lessons（不是"什么错了"而是"下次怎么做"）
3. Correction capture: 用户纠正 → preference fact（惩罚权重 > 奖励权重，不对称）
4. Memory sync (6h): 高信任 facts → 合并到 MEMORY.md
5. User profile sync: preference facts → 自动更新 USER.md

### DocStore
- 本地文件索引: Markdown/DOCX/PDF → 300-1200 char chunks → FTS5
- Thread-scoped retrieval: 自动推断对话关联的项目，缩小搜索范围

## 跟我们的对比

| 维度 | Orb | OpenClaw + Kagura |
|------|-----|-------------------|
| Agent runtime | Claude Code CLI (外挂) | 自有 agent loop |
| Memory | Holographic (SQLite+HRR, 无 embedding) | memory_search (embedding) + MEMORY.md (手动) |
| 自进化 | 自动 fact extraction + error distillation | [[beliefs-candidates]] 手动/半自动 + nudge |
| 多平台 | Adapter 模式 (Slack/Discord/WeChat) | Gateway adapter |
| Skill | Skills Index (静态) | AgentSkills (动态加载 + 触发匹配) |

### 关键差异
1. **Memory arbitration at write time** — 我们的 memory 靠 search-time ranking，Orb 在写入时就做冲突解决。更激进但可能更一致
2. **Error distillation 自动化** — 我们的 nudge 需要累积 3 次才升级 gradient，Orb 每次错误都立即蒸馏 lesson。更快但可能噪声大
3. **No embedding dependency** — Orb 用 HRR + FTS5 + Jaccard，完全本地。我们依赖 embedding API。这是有意义的 tradeoff
4. **Claude Code as runtime** — Orb 不重写 agent loop，直接用 Claude Code。升级零成本，但定制性受限

## 架构洞察

- **"不重写，包一层"策略**: Orb 证明了 Claude Code CLI 足够强，不需要自建 agent loop。只需要在外面加 memory + context + routing。这跟 OpenClaw 的 full-stack 方式是根本不同的设计哲学
- **Python subprocess bridge**: memory 系统用 Python 写，JS 主进程通过 subprocess 调用。跨语言但解耦清晰
- **Frozen trust > time decay**: 反直觉但合理——时间衰减会丢真实低频知识。信任应该基于来源质量，不是访问频率

## 生态位置

- **直接竞争**: OpenClaw（都是 Claude Code 的操作系统层）
- **间接竞争**: Hermes Agent（不同 runtime 但同一市场）
- **互补**: SkillAnything（可以为 Orb 生成 skills）
- **风险**: 深度依赖 Claude Code CLI 的接口稳定性

## 可借鉴

- [ ] Write-time memory arbitration — 我们能不能在 dreaming/memory write 时加 conflict resolution？
- [ ] Error distillation 自动化 — nudge 的 gradient 提取可以借鉴 distill.py 的 prompt 结构
- [ ] Frozen trust scores — dreaming 的 recall scoring 是否应该去掉时间衰减？
- [ ] HRR (Holographic Reduced Representations) — 无 embedding 的语义检索，值得技术评估

## 关联

- [[evolution-needs-eval]] — Orb 的自进化缺乏系统性 eval（没有 benchmark stage）
- [[self-evolution-architecture]] — 四层模型的另一个实例
- [[mechanism-vs-evolution]] — Orb 偏 evolution（自动蒸馏），我们偏 mechanism（手动规则）
- [[mem0]] — Orb memory arbitration 灵感来源
- [[graphiti]] — Orb tombstone 设计灵感来源
- [[skillanything]] — 同期项目，可为 Orb 生成 skills
