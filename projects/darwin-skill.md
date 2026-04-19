# darwin-skill

- **Repo**: alchaincyf/darwin-skill
- **Stars**: 1.2k (2026-04-19)
- **What**: Skill 自动进化系统，受 Karpathy autoresearch 启发
- **Author**: 花叔 (AlchainHust)

## 核心机制

1. **双重评估**: 结构评分（静态分析，60分）+ 效果验证（实际运行，40分）
2. **棘轮机制 (ratchet)**: 分数只升不降，新分 < 旧分 → git revert
3. **独立评分**: 评分用子 agent，避免自己改自己评
4. **人在回路**: 每个 Skill 优化完暂停，用户确认再继续
5. **单一可编辑资产**: 每次只改一个 SKILL.md

## 对比我的实践

| 维度 | darwin-skill | 我的做法 |
|---|---|---|
| 评估 | 8维加权总分（满分100） | beliefs-candidates 4维质量门 (grounded/preserves/specific/safe) |
| 进化触发 | 主动扫描所有 skill | 被动——重复 3 次才升级 |
| 回滚 | git ratchet 自动 | 无自动回滚 |
| 评分者 | 独立子 agent | 无独立评分（自评） |

## 可借鉴

- **棘轮机制**: 我的 DNA 更新没有 ratchet——改了如果退步没有检测。可考虑：DNA 改动后 1 周内观测是否有退步，退步则 revert
- **独立评分**: beliefs-candidates 升级用独立 agent 打分，减少自评偏差
- **效果 > 结构**: 40% 权重给实测效果——"Skill 写得再漂亮，跑出来效果不好就是零"

## 不适用

- 我的 DNA 文件不是标准 SKILL.md，darwin-skill 直接用不上
- 人在回路对我有障碍——Luna 不想每次审批

## 关联

- [[skill-evolution]] — Skill 生态趋势
- [[skillclaw]] — SkillClaw 的 Skill Verifier 4 维度
- Karpathy autoresearch — 共同源头
