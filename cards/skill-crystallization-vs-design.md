# Skill 固化 vs 设计

两种 agent skill 获取路径的对比。

## 自动固化（GenericAgent 模式）
- 每次任务执行后自动将执行路径晶化为 Skill
- **优势**: 覆盖面广、零人力成本、skill 与实际执行路径完全一致
- **劣势**: 质量不可控、可能固化坏路径、缺乏抽象（过度 specific）

## 人为设计（[[AgentSkills]] / OpenClaw 模式）
- 人写 SKILL.md，定义触发条件、步骤、引用
- **优势**: 质量高、抽象层次对、可维护
- **劣势**: 覆盖慢、依赖人力、可能与实际执行路径脱节

## 混合路径（假说）
自动提取 candidate skill → 人工 review → 提升为正式 skill。
类似 [[beliefs-candidates]] 的管线模式——积累 → 筛选 → 沉淀。

## 相关
- [[GenericAgent]] — 自动固化的代表
- [[AgentSkills]] — 人为设计的代表
- [[Evolver]] — GEP 进化也是一种自动路径

(2026-04-21)
