# darwin-skill

> alchaincyf/darwin-skill | 1010⭐ (2026-04-17) | HTML | 2026-04-13
> "像训练模型一样优化你的 Agent Skills"
> 受 Karpathy autoresearch 启发，自主 skill 优化循环

## 核心思想

把 autoresearch 的自主实验循环（改代码→跑测试→保留改进→回滚退步）搬到 Skill 优化领域。关键：**棘轮机制**（分数只升不降）+ **人在回路**。

## 5 条核心原则

1. **单一可编辑资产** — 每次只改一个 SKILL.md，变量可控
2. **双重评估** — 结构评分（静态分析 60 分）+ 效果验证（实测 40 分）
3. **棘轮机制** — 只保留改进，自动回滚退步
4. **独立评分** — 评分用子 agent，避免自己改自己评
5. **人在回路** — 每个 Skill 优化完暂停等人确认

## 8 维度评估体系（满分 100）

- 结构维度: 60 分（静态分析）
- 效果维度: 40 分（实测表现权重最高 25 分）
- "Skill 写得再漂亮，跑出来效果不好就是零"

## 优化循环 5 阶段

Phase 2 核心逻辑：
1. 找得分最低维度
2. 针对性生成 1 个改进方案
3. 编辑 SKILL.md, git commit
4. 子 agent 独立重新评分
5. 新分 > 旧分 → 保留，否则 → git revert
6. 每 Skill 完成后暂停，展示 diff + 分数变化

## 与 SkillClaw 对比

| 维度 | darwin-skill | SkillClaw |
|------|-------------|-----------|
| 进化来源 | 人在回路 + 自主实验 | 多用户 session 自动蒸馏 |
| 评估 | 8 维度 100 分制 | PRM per-turn + Verifier 4 维度 |
| 棘轮 | git commit/revert | 无（但有 versioned history） |
| 共享 | 无（单用户） | SkillHub 云端共享 |
| 核心差异 | 像训练模型（可量化优化目标） | 像集体学习（多 agent 经验汇聚） |

## 跟我们的关联

1. **棘轮机制可直接借鉴** — 我们的 skill-creator 缺少"只保留改进"的机制，改完没有对比验证
2. **8 维度评估** — 比 SkillClaw 的 4 维度更细（含实测权重），但需要 test-prompts.json
3. **单一可编辑资产原则** — 跟 SkillClaw 的 conservative editing 理念一致
4. **独立评分** — 用子 agent 评分避免自己评自己，我们的 nudge 也是分离的（plugin 评）
5. **效果 > 结构** — 实测表现 25 分 > 任何单项结构分，跟 SkillClaw 的 "session judge > static check" 一致

## 行动项

- [ ] 深读 darwin-skill 源码，看 test-prompts.json 格式和评分实现细节
- [ ] 考虑是否将棘轮机制引入 skill-creator workflow

## 关联

- [[skillclaw]] — 同赛道，集体进化 vs 单用户优化
- [[karpathy-skills]] — autoresearch 是 darwin-skill 的直接灵感来源
- [[skill-evolution]] — 我们的 skill 进化方向
