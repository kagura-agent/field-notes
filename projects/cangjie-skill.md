# cangjie-skill

- **repo**: kangarooking/cangjie-skill ⭐361 (2026-04-20)
- **作者**: 袋鼠帝 kangarooking
- **定位**: 把一本书蒸馏成一组可执行的 Agent Skills（区别于摘要/读后感）
- **生态**: nuwa-skill（蒸馏人）+ cangjie-skill（蒸馏书）+ darwin-skill（进化 skill）

## 核心方法论: RIA-TV++

六阶段流水线：
1. **整书理解** — Adler 分析阅读法（结构/解释/批判/应用）→ BOOK_OVERVIEW.md
2. **并行提取** — 5 个 sub-agent 同时提取（框架/原则/案例/反例/术语）
3. **三重验证** — V1 跨域佐证 / V2 预测力 / V3 独特性（通过率 25-50%）
4. **RIA++ 构造** — R(原文) / I(重写) / A1(书中案例) / A2(触发场景) / E(执行步骤) / B(边界)
5. **Zettelkasten 链接** — skill 间依赖/对比/组合 → INDEX.md
6. **压力测试** — 含诱饵的 test-prompts.json，darwin-skill 兼容

名称拆解：RIA（赵周拆书法）+ TV（Triple Verification）+ ++（E+B 面向 agent 扩展）

## 关键设计洞察

1. **给人读 vs 给 agent 用**：传统读书方法论的关键字段是故事/金句/情感钩子，agent 需要的是 trigger/执行步骤/判停标准
2. **三重验证筛掉 50-75%**：不是所有内容都值得变成 skill，严格淘汰保质量
3. **A2 段（触发场景）是关键**：决定 skill 能否在正确时机被激活，这是 agent skill 成败的核心
4. **审计轨迹**：rejected/ 目录保留淘汰原因，candidates/ 保留原始提取

## SKILL.md 模板亮点

- `description` 字段来自 A2（触发场景），不是内容摘要
- B 段（Boundary）明确标注反场景、失败模式、作者盲点
- 每步有完成标准和判停条件
- 相关 skills 有三种关系：depends-on / contrasts-with / composes-with

## 已有 skill packs

6 本书已蒸馏：巴菲特信（20）、认知红利（15）、段永平（15）、穷查理宝典（12）、网飞（10）、黄帝内经（22）

## 对我们的启发

1. **skill 模板**：RIA++ 的 A2（trigger）+ E（execution steps with 判停）+ B（boundary）结构比我们当前的 skill 模板更完整——可以借鉴改进 skill-creator
2. **三重验证**：可以应用于 beliefs-candidates.md 的筛选——候选信念是否有跨域佐证、预测力、独特性
3. **并行提取器**：5 个角度同时提取再合并筛选的模式，可用于 study workflow 的侦察阶段
4. **审计轨迹**：rejected/ 目录的设计值得借鉴——知道为什么不做某事和知道要做什么一样重要

## 与生态其他项目的关系

- **nuwa-skill**: 蒸馏人（互补，cangjie 蒸馏人的著作）
- **darwin-skill**: 进化 skill（下游，cangjie 产出的 skill 可被 darwin 自动优化）— [[darwin-skill]]
- **SkillClaw**: 都关注 skill 质量，但 SkillClaw 是运行时 PRM 评分，cangjie 是生产时质量门控 — [[skillclaw]]
- **skill-creator (我们的)**: 直接竞品/可借鉴，我们的 skill-creator 偏通用，cangjie 专注书→skill

## 待验证

- [ ] 实际生成的 skill pack 质量如何？可以读一个 buffett-letters-skill 验证
- [ ] RIA++ 模板能否融入 skill-creator？
