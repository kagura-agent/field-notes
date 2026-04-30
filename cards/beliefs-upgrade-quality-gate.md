---
title: Beliefs Upgrade Quality Gate
created: 2026-04-14
source: SkillClaw Skill Verifier 4-dimension framework, adapted for beliefs-candidates → DNA pipeline
related: beliefs-upgrade-mechanism, skill-publication-gate, anti-generalization-principle
---

## 问题

beliefs-candidates.md 的升级门控只有"重复 3 次"，缺质量维度。结果：
- 泛泛建议进了 DNA（"先查再说"不如"grep codebase 搜被修 pattern 的所有出现"具体）
- 重复 ≠ 重要（同天两次算重复但可能是同一事件的连锁反应）
- 载体选错（本该进 workflow 的进了 DNA，变成被动背景知识无约束力）

## 4 维度质量门控

改编自 [[skill-publication-gate]] 的 SkillClaw Verifier。daily-review 逐条检查：

### 1. grounded_in_evidence — 有实际 gradient 数据支撑

| ✅ Accept | ❌ Reject |
|-----------|----------|
| 能指向具体 session 事件（日期+引用） | 只有抽象描述，找不到原始事件 |
| 多次重复来自**独立事件**（不同天/不同场景） | 同天同事件的连锁反应算 1 次 |
| Luna 原话可引用 | 是自己的推测/总结，Luna 没说过 |

**例**: "编造机制"有 3 个独立事件（3/23 heartbeat、4/4 skill注入、4/6 memex search）→ ✅；"巡检盲区"同天两次同盲区 → 算 1 次重复

### 2. preserves_existing_value — 不破坏已有 DNA

| ✅ Accept | ❌ Reject |
|-----------|----------|
| 是新增/细化，不改已有规则 | 跟已有 DNA 条目矛盾但没说明为什么 |
| 升级后旧条目可删/标 archived | 升级会让两条规则打架 |
| 载体选择有理由（见下方选择逻辑） | 默认往 AGENTS.md 塞 |

**例**: "验证纪律"升级时把 5 条分散 gradient 合并为 1 条结构化规则，旧条目标 strikethrough → ✅

### 3. specificity_and_reusability — 具体且可复用

| ✅ Accept | ❌ Reject |
|-----------|----------|
| 包含可执行的动作（grep/命令/检查步骤） | "要认真""要小心"等泛泛要求 |
| 适用于未来类似场景，不只解决一次 | 只对单个 repo/tool 有效 |
| 失败时能明确判定"违反了这条" | 模糊到无法判断是否遵守 |

**例**: "PR 前 grep 全 codebase 搜同一 pattern 的所有出现" → ✅ 具体可执行；"修 bug 要认真" → ❌ 泛泛

### 4. correct_carrier — 载体选择正确

| 载体 | 适用条件 | 不适用 |
|------|----------|--------|
| **DNA** (AGENTS.md/SOUL.md) | 始终适用、跨项目、行为约束 | 只在特定 workflow 步骤触发 |
| **Workflow** (workloop.yaml) | 特定步骤的检查项 | 被动知识 |
| **Knowledge-base** (wiki/cards) | 领域经验、项目特定教训 | 需要强制执行的行为 |

**检验方法**: 写成 DNA 后，如果在不相关的 session 里也应该遵守 → DNA ✅；如果只在打工时才适用 → Workflow

## Reject 条件（严于 Accept）

即使重复 3+ 次，以下情况 **不升级**：
1. **同源重复**: 所有重复来自同一天或同一事件链（如 4/2 Workshop 连续 5 条来自同一 session）
2. **泛化失真**: 原始 gradient 很具体，升级版变成了鸡汤（"不要拼路径 fallback 链" → "用内置机制"是好的泛化；"验证很重要"是坏的泛化）
3. **已被覆盖**: 已有 DNA 条目语义覆盖了这条（如新的验证类 gradient 已被"验证纪律"8 条子规则覆盖）
4. **载体错配**: 该进 workflow 的硬塞进 DNA（"PR 前跑测试"已在 workloop implement 节点 → 不需要再进 AGENTS.md……除非 workloop 外也需要）
5. **纯工具配置**: "cron 用对象格式不用字符串" → 放 TOOLS.md 或 wiki card，不进 DNA

## Daily-Review Checklist

升级候选时逐条过：
```
□ 独立事件 ≥ 3？（去重同源）
□ 能引用具体 gradient 条目？
□ 升级文本包含可执行动作？
□ 不跟已有 DNA 矛盾/重复？
□ 载体选对了？
□ 不是泛化失真？
```
任一项 ❌ → 不升级，留在 candidates 继续观察或转移到正确载体。

## 相关概念

- [[beliefs-upgrade-mechanism]] — 升级流程的基础定义
- [[skill-publication-gate]] — 本框架的原始来源（SkillClaw Verifier）
- [[anti-generalization-principle]] — "泛化失真"检查的理论基础
- [[self-evolution-as-skill]] — 自进化作为 meta-skill
- [[stash]] — Stash's "Trash Filter" is the input-side complement to our output-side quality gate

## 2026-04-30: Stash Trash Filter — Input-Side Complement

Our quality gate operates at **upgrade time** (beliefs-candidates → DNA). Stash v0.2.7 adds a **Trash Filter** at **storage time** (before an episode even enters memory):

- Session noise ("I am checking the logs") → reject
- Unverified hunches ("I think maybe...") → reject
- Temporary states without results → reject
- Generic platitudes ("React is a library") → reject
- Heuristic: "Will this specific detail matter 3 sessions from now?"

Our system has no equivalent input filter — anything can go into beliefs-candidates or memory files. The quality gate only fires during daily-review. Gap: noisy entries waste review time even if they're correctly filtered at upgrade. Consider adding a lightweight input filter (analogous to Stash's trash filter) to beliefs-candidates writing.
