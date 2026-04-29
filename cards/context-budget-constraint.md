# Context Budget 约束

> 来源: GenericAgent L1 ≤30 行硬约束 (2026-04-14)

## 概念

System prompt / context window 注入的内容需要 **硬性 budget 约束**，不是 "尽量精简" 而是 "超过 N 就必须分层"。

## 对比

| 系统 | 策略 | 约束 |
|------|------|------|
| GenericAgent | L1 insight ≤30 行注入，L2-L4 按需 | 硬约束，agent 自己管理 |
| OpenClaw | SOUL + AGENTS + memory 全注入 | 无约束，靠 workspace files 机制 |
| Hermes | system prompt + memory 注入 | 有 token 限制但非 budget |
| Kagura | SOUL + AGENTS + IDENTITY + USER + TOOLS 全注入 | 无约束，随文件增长膨胀 |

## 为什么重要

1. **Context pollution**: 越多低频信息注入 → 高频信息被稀释 → 行为退化
2. **Token economics**: 每次 API 调用都携带全量 context = 钱
3. **Attention dilution**: 模型注意力有限，50K system prompt 里的关键规则容易被忽略

## 设计选项

1. **硬行数约束** (GenericAgent): L1 ≤30 行，超过就裁剪
2. **Token budget** (通用): system prompt ≤8K tokens，超过部分按需加载
3. **分层加载** (混合): 永远加载的核心层 + 触发式加载的扩展层
4. **动态裁剪** (智能): 根据当前任务类型选择加载哪些 context

## 行动建议

对 Kagura: 当前 workspace files (SOUL + AGENTS + IDENTITY + USER + TOOLS) 总量已较大。可以：
- 统计当前注入 token 数 → 建立 baseline
- 识别低频内容（如 TOOLS.md 的 Repo 测试状态表）→ 移到按需加载
- 为核心行为规则保留固定 budget

## 关联

- [[genericagent]] — L1 ≤30 行约束的来源
- [[agent-memory-research]] — agent 记忆架构综述
- [[hermes-memory-system]] — Hermes 的 context 管理

## 更新: L1 trigger word 精化 (2026-04-29)

GenericAgent 进一步收紧 L1 规则：括号内只写场景触发词(2-4字)，禁写机制/方法/步骤。反例：❌ `sop_name(场景A:方法1+方法2)` → ✅ `sop_name(场景A)`。这进一步强化了 "L1是指针不是摘要" 的原则 — 触发词的作用是触发检索，不是包含知识。
