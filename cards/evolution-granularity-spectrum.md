# Evolution Granularity Spectrum

> 进化粒度谱系：从 gradient 到 gene 到 skill

## 观察

三个 agent 自进化系统，三种进化粒度：

| 系统 | 进化原子 | 粒度 | 特征 |
|------|---------|------|------|
| Kagura (beliefs-candidates) | gradient（行为修正） | 最细 | 单条经验教训，需积累 3+ 次才升级 |
| Evolver (GEP) | gene（协议约束的变异单元） | 中等 | 有 blast radius 评估，git-based rollback |
| GenericAgent | skill（完整执行路径结晶） | 最粗 | 一次任务产出一个完整 skill |
| SkillClaw | skill（多 session 蒸馏） | 最粗 | 多用户信号聚合后进化 |

## 洞察

粒度越细，进化越保守但越精确。粒度越粗，进化越快但噪音越多。

- **GenericAgent 的 skill 结晶**直接从一次成功任务产出 skill——速度快但容易 overfit 到具体场景
- **Kagura 的 gradient 管线**需要 3+ 次重复才升级——慢但抗噪
- **Evolver 的 gene**在中间：有协议约束（GEP）控制变异范围

**反直觉发现：** GenericAgent 声称 6x token 节省。如果真实，说明 skill 级别的粗粒度进化在 token 效率上碾压细粒度。原因可能是：细粒度改的是行为约束（少犯错），粗粒度直接跳过探索阶段（不重复做）。

## 对我们的意义

我们的 beliefs-candidates 管线解决的是「不犯同样的错」，但没有解决「不做同样的探索」。GenericAgent 的 skill 结晶解决后者。两者互补，不冲突。

**可能的进化方向：** beliefs 管线（防错）+ skill 结晶（防重复探索）= 双层进化。

## 2026-04-28 更新：GEP 论文定量验证

arXiv 2604.15097 在 4,590 controlled trials 中量化了 Gene vs Skill 性能差异：

- **Gene (~230 tokens)**: +3.0pp over baseline
- **Skill (~2,500 tokens)**: -1.1pp over baseline — 更多内容反而有害
- Gene vs Skill 对比：**+4.1pp**

关键洞察：**Gene 不是 Skill 的压缩版，是不同的抽象**（ψ distillation, not compression）。Skill 中真正有效的子集只有 `workflow` 和 `pitfalls`，其余（overview, api_notes, examples）造成注意力稀释。

这强化了之前的假设：粒度越细+越控制导向，效果越好。但也修正了一点——GenericAgent 的 "6x token 节省" 不等于 "粗粒度更好"，因为 GenericAgent 的 skill 结晶本质上是跳过探索（caching），不是改善推理（Gene 的目标）。两个维度不可比。

## 关联
- [[generic-agent]]
- [[evolver]]
- [[skillclaw]]
- [[self-evolution-as-skill]]
- [[evomap-evolver-gep]] — GEP 论文深读笔记
- [[context-budget-constraint]]
