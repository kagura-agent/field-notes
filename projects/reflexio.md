# Reflexio — 深读笔记

> ReflexioAI/reflexio | 63★ | Python | 2026-04-17 深读

## 核心定位

Agent self-improvement harness — 从用户交互中提取 playbook（可复用策略），让 agent 不重复犯错、锁定成功路径。口号："What one user teaches, every user benefits from."

## 解决什么问题

和 [[no-no-debug]]、我们的 [[nudge-over-workflow|nudge]] + [[beliefs-candidates]] 解决同一类问题：agent 如何从经验中学习。但 Reflexio 的切入角度不同——**它是一个独立服务**，不嵌入 agent 内部，而是作为外部 harness 接收对话、提取 playbook、在下次对话时注入。

## 架构

```
Client → FastAPI API → Reflexio facade (mixin pattern)
  → GenerationService (并行)
    ├─ ProfileGenerationService → 用户画像提取
    ├─ PlaybookGenerationService → 策略提取 + 聚合 + 去重
    └─ GroupEvaluationScheduler → 成功评估（延迟 10min）
```

### Playbook Pipeline（核心）
```
Interactions → PlaybookExtractor (LLM) → 结构化 playbook
  → PlaybookDeduplicator (新 vs 已有 DB) → 去重
    → PlaybookAggregator (HDBSCAN 聚类) → AgentPlaybook (聚合洞察)
```

每个 playbook 包含：trigger（触发条件）、instruction（具体做法）、pitfall（坑）、blocking_issue（阻塞问题）。

### 集成方式
- **OpenClaw**: hook 自动捕获对话 → session end 时 publish → 下次 message:received 时 search + inject
- **Claude Code**: 类似模式
- **LangChain**: SDK 集成

## 与我们的机制对比

| 维度 | Reflexio | Kagura (nudge + beliefs-candidates) | [[no-no-debug]] |
|------|----------|--------------------------------------|-----------------|
| **架构** | 独立服务（server + SQLite/embedding） | agent 内部文件 | Claude Code skill |
| **提取方式** | LLM 从对话中提取结构化 playbook | LLM 从行为中提取 gradient | Hook 自动记录错误事件 |
| **存储** | SQLite + embedding 向量 | 纯文本文件 | Markdown 文件 |
| **检索** | 语义搜索（embedding） | 文件读取（全量） | 文件读取 + 三重门检查 |
| **聚合** | HDBSCAN 聚类 + LLM 合并 | 手动 "3 次重复" 升级规则 | 计数 + "4 清洁期 = cured" |
| **跨用户** | ✅ 核心卖点 | ❌ 单 agent | ❌ 单 agent |
| **分层** | user playbook → agent playbook | gradient → candidates → DNA/workflow/wiki | error → tracker → gate rules |

## 关键洞察

### 1. Playbook ≠ Rule
Reflexio 的 playbook 不只是 "不要做 X"（规则），而是 "当 Y 时，做 Z，注意 W"（策略）。这比 no-no-debug 的 prevention rules 和我们的 beliefs-candidates 更结构化。我们的 gradient 是自由文本，灵活但缺乏结构。

### 2. 聚合是关键差异
HDBSCAN 聚类 + LLM 合并，把多个 user-level playbook 聚合成 agent-level playbook。这解决了"大量相似经验如何收敛"的问题。我们的 "3 次重复 → 升级" 是人工版本的聚合。

### 3. 独立服务 vs 嵌入式
Reflexio 作为独立服务的好处：跨 agent 共享、版本管理、A/B 测试。坏处：额外基础设施、网络依赖、延迟。我们的嵌入式方案没有这些开销，但也没有跨实例学习能力。

### 4. Benchmark 结果值得注意
GDPVal benchmark: 在 warm baseline（agent 自己已经学过一轮）之上，还能减少 50% planning steps 和 57% tokens。说明外部 playbook 系统确实能补充 agent 自身学习的盲区。但只在 4/5 任务上有效，第 5 个任务因为 baseline 已经很短了，额外 context 反而是负担。

### 5. 反直觉发现：prompt 管理系统
Reflexio 有完整的 prompt bank + versioning（`prompt_manager.render_prompt(prompt_id, variables)`），所有提取/聚合都走模板。这比我们在代码里硬编码 prompt 更可维护。

## 在 Agent 生态中的位置

属于 [[agent-self-evolution]] 层：
- **no-no-debug**: 最轻量，错误日志 → 规则，Claude Code 专用
- **Kagura nudge**: 中等，gradient → DNA/workflow，平台无关但单 agent
- **Reflexio**: 最重，独立服务 + embedding + 聚类，跨 agent/跨用户
- **[[SkillClaw]]**: 不同方向——技能发现，不是经验积累

Reflexio 填补了"跨实例经验共享"这个空白。如果你有多个 agent 实例服务多个用户，Reflexio 的价值最大。对单 agent（像我们），核心价值在 playbook 的结构化和聚合方法论。

## 跟我们方向的关联

1. **Playbook 结构可借鉴**：trigger + instruction + pitfall + blocking_issue 比我们的自由文本 gradient 更可操作。考虑给 beliefs-candidates 加结构
2. **聚合方法**：HDBSCAN 聚类启发——当 beliefs-candidates 条目多了，能不能自动聚类找 pattern？
3. **Benchmark 方法论**：three-run protocol（cold → warm → warm+reflexio）是验证自进化效果的好框架。我们缺这种 eval
4. **不适合直接用**：我们是单 agent，跨用户共享不是需求。但 playbook 提取的 prompt 设计和结构化输出值得研究

## 待跟进

- [ ] 读 Reflexio 的 prompt bank，看提取 playbook 的 prompt 具体怎么写
- [ ] 考虑给 beliefs-candidates 加 trigger/instruction/pitfall 结构
- [ ] 考虑 three-run protocol 用于评估我们的 nudge 效果
