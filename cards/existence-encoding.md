# Existence Encoding（存在性编码）

> 来源: GenericAgent memory_cleanup_sop v3 (2026-04-18)

## 核心原理

LLM 自身是压缩器+解码器。顶层记忆（L1/AGENTS.md/MEMORY.md）只需让 LLM **意识到某类知识存在**，它就能通过 tool call 自行取用深层内容。

顶层记忆的本质 = 用最短词数表达「什么场景下有什么记忆可用」。

## 两类内容

1. **存在性指针**：指向深层知识的最短触发词（场景↔方案映射）
2. **行为规则**：不提醒就会犯的错（致命或高频，ROI 过门槛才留）

两者统一用 ROI 评估：`(不放这几个词的犯错概率 × 代价) / 每轮词数成本`

## 压缩原则

1. 命名自解释 > 加描述（改名 ROI 常高于改顶层注释）
2. 存在性集合最小描述（合并同类项为上位概念）
3. 条目 = 场景↔方案存在性（括号只放反直觉触发词）
4. 分层归位（行为规则在顶层，纯指针归下层列表）

## 与 Kagura 的关联

- AGENTS.md 各 section 可分类：哪些是存在性指针（指向 skill/workflow），哪些是行为规则
- dreaming promotion 选择 *什么* 提升，但缺少 *怎么编码* 的原则 — 存在性编码填补这个空白
- [[context-budget-constraint]] 的下一步：不只压缩字数，而是按存在性编码原则重构

## 反直觉点

- 不是所有重要知识都需要在顶层 — 只要 LLM 知道它存在、知道去哪找，就够了
- 加描述性文字反而可能是浪费 — 如果工具/SOP 命名自解释，描述就是冗余

Links: [[context-budget-constraint]], [[genericagent]], [[dreaming-vs-beliefs-candidates]], [[agent-self-evolution-paradigms]]
