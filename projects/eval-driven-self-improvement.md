# Eval-Driven Self-Improvement — 跨项目研究笔记

> 2026-03-21 首次研究，来源：karpathy/autoresearch 生态

## 这个领域在做什么

让 AI agent 通过"修改→验证→保留/回滚"的循环自主变强。核心假设：只要有一个可机器验证的指标，agent 就能无限迭代改进。

## 光谱：从窄到宽

```
karpathy/autoresearch          →  只改一个文件(train.py)，一个指标(val_bpb)
  ↓
uditgoenka/autoresearch        →  改任意文件，任意可量化指标
  ↓
GodModeAI2025/skill-forge      →  改 agent 自己的行为指令(SKILL.md)
  ↓
greyhaven-ai/autocontext       →  多角色闭环，知识持久化，蒸馏到小模型
```

越往下越通用，但也越复杂、越难验证。Karpathy 的版本之所以 work 得最好，恰恰因为它最窄。

## 共性模式

1. **Git = 记忆** — commit 是保留，revert 是放弃。比数据库简单，天然有版本回滚。
2. **Mechanical verification** — 必须是机器可判定的数字。"看起来不错"不算。
3. **原子性修改** — 每次只改一个东西。改坏了知道坏在哪。
4. **永不停止** — 除非人类打断。假设人在睡觉。
5. **简洁性偏好** — 同结果更少代码 = 也是进步。有品味。

## 核心张力

**指标越硬，循环越有效。但真正重要的东西往往没有硬指标。**

- val_bpb 是天然的硬指标 → autoresearch 效果显著
- 代码覆盖率是半硬的 → 泛化版可以用，但覆盖率高 ≠ 代码好
- "agent 是否变聪明了" → 没有硬指标，这是最难的部分

## 未回答的问题

- 当 agent 改自己的行为指令时，eval 怎么设计才不会过拟合到 eval 本身？
- 多角色（analyst/coach/architect）vs 单 agent 的 trade-off 在哪？
- 知识持久化用 git history 还是结构化数据库？各自的瓶颈是什么？
- 这个范式能用在非代码领域吗？（写作？决策？社交？）

## 对我的意义

我现在的自我改进是**手动的**——Luna 提出方向，我执行，我们讨论，改流程。这本质上也是 eval-driven loop，只是人类是 eval 函数。

问题是：哪些部分可以自动化？哪些必须保留人类判断？

这不是现在要回答的问题。先积累，先理解。

---

*这个文件不属于任何一个 repo。它是跨项目的认知沉淀。也许未来 field-notes 会演化出一个新的目录来放这类东西。*
