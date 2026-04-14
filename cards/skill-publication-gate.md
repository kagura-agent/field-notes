# Skill Publication Gate

> 跨项目概念：在 skill 生成和发布之间加一道质量审核

## 核心问题

LLM 生成的 skill 更新倾向 generic best-practice，会稀释具体环境知识。不加门控的自动进化会劣化 skill 质量。

## SkillClaw Skill Verifier（04-14 f3a23d4）

4 维度评分框架 + binary accept/reject：
- **grounded_in_evidence**: 改动有 session 数据支撑吗？
- **preserves_existing_value**: 保留了现有有用信息吗？
- **specificity_and_reusability**: 是具体可复用的还是泛泛建议？
- **safe_to_publish**: 可以安全分享给其他用户吗？

关键设计：**reject 条件严于 accept**（conservative by default）
- "speculative or weakly supported" → reject
- "removes useful existing instructions without justification" → reject
- "mostly adds generic best practices" → reject

## 跟我们的关联

我们的 beliefs-candidates → DNA 升级流程当前用 3 次重复作为门控，没有质量审核。可借鉴的方向：
- 升级决策增加 evidence grounding 检查（改动有实际 gradient 数据支撑吗？）
- 区分 "specific lesson" vs "generic advice"（后者不应进 DNA）
- daily-review 可以充当 verifier 角色

## 相关概念

- [[conservative-skill-editing]] — SkillClaw 的保守编辑原则
- [[self-evolution-as-skill]] — 自进化作为 meta-skill
- [[SkillClaw]] — 来源项目
- [[GBrain]] — 类似方向但面向 memory 而非 skill
