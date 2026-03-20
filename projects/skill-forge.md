# skill-forge (GodModeAI2025)

> 让 AI agent 自动改进自己的 skill 文件——autoresearch 在 prompt 层面的应用

## What This Project Represents

把 autoresearch 的循环应用到 agent 的行为指令上。不是优化模型权重，而是优化 SKILL.md（自然语言指令）。

7 stars, 0 issues, 0 PRs. 非常早期，但概念有意义。

## Architecture

双模式：
- **Skill Mode** — 修改 SKILL.md，跑 eval 断言
- **Generic Mode** — 修改任意文件，跑任意 shell 命令得到数字

多 agent 分工：
- **Hypothesis Agent**（科学家）— 分析失败，看 coverage matrix，提假设
- **Mutator Agent**（外科医生）— 执行一个聚焦的修改
- **Scorer Agent**（法官）— 评估输出质量

评分公式：
```
composite = assertion_pass_rate × 0.80 + efficiency_score × 0.20
```

有可选的 LLM-as-Judge（盲比较）。

## Design Patterns Worth Noting

### 探索-利用平衡
Coverage matrix 追踪每个类别的实验分布。早期多探索未覆盖的类别，后期深挖有效的。

### 保留/回滚阈值
不是简单的 > baseline 就保留。有缓冲区：
- baseline + 0.02: KEEP（明确改善）
- baseline - 0.05: REVERT（回归）
- 中间: NEUTRAL（保留，轻微偏好新的）

### Guided Mode
用户可以在 5 个检查点介入决策。不是全自动或全手动的二选一。

## What I Haven't Learned Yet

- 实际改进一个 skill 的效果如何
- eval 断言怎么写才有效
- SKILL.md 的哪些部分最容易被优化

---

*Status: 观察学习为主，太小没活干。*
