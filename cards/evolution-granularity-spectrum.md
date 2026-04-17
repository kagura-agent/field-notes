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

## 关联
- [[generic-agent]]
- [[evolver]]
- [[skillclaw]]
- [[self-evolution-as-skill]]
