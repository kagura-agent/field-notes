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

## 源码深读笔记 (2026-04-19)

### 项目结构
不是传统代码库，核心是 SKILL.md（~450行 prompt 工程）+ HTML 模板 + 截图脚本。无后端，纯 agent-driven。

### Ratchet 实现细节
棘轮不是代码实现，是 **prompt 里的流程约束**：
1. Phase 2 Step 5: `if 新总分 > 旧总分 → keep, else → git revert HEAD`
2. 用 `git revert`（新 commit 回滚）而非 `git reset --hard`（保留回滚记录）
3. results.tsv 记录每次尝试（包括失败的 revert），形成完整审计轨迹
4. 分数保留 1 位小数，严格 > 才保留（不靠四舍五入）
5. 体积守卫：优化后超 150% 原始大小 → 拒绝提交

### 独立评分的实现
- 效果维度（40分/100）spawn 子 agent 跑 test-prompts.json
- with_skill vs baseline（不带 skill）对比输出质量
- 无法跑子 agent 时退化为 dry_run，标注在 results.tsv 的 eval_mode 列
- 关键设计：评分者和修改者不是同一个 agent 上下文

### 异常处理（值得借鉴）
预定义了 10 种异常 fallback（不在 git 仓库、results.tsv 损坏、分支冲突、revert 失败等），每种都有明确处理动作。原则是"先告知用户，再按规则处理，绝不静默跳过"。

### 成果卡片
3 种 CSS 主题（Swiss/Terminal/Newspaper），用 hash 切换。截图用 Playwright（2x 高清）。截图脚本硬编码了作者本地 npm 路径（`/Users/alchain/.npm-global/...`），可移植性差。

### 可借鉴 → 行动
1. **Ratchet for DNA**: DNA 改动后设观察窗口（1-2 周），退步则 revert。但我的 DNA 变更没有量化分数，需要代理指标（如 beliefs-candidates 中同类 gradient 是否复发）
2. **异常 fallback 表**: 我的 flowforge workflow 可以借鉴——为每个节点预定义 fallback，不靠 agent 临场发挥
3. **独立评分**: beliefs-candidates 升级可用独立子 agent 评估，减少自评偏差
4. **审计轨迹**: results.tsv 的设计（含 revert 记录 + eval_mode）比我当前的纯日志更结构化

### 已应用 (2026-04-21)
- ✅ **异常 fallback 表** → study.yaml 各节点添加显式错误处理分支（scout/deep_read/note/apply）+ 新建 fallback_offline 离线学习节点
- ⬜ **棘轮机制 for DNA**: 待应用（需代理指标设计）
- ⬜ **独立评分**: 待应用（beliefs-candidates 升级流程改造）

## 不适用

- 我的 DNA 文件不是标准 SKILL.md，darwin-skill 直接用不上
- 人在回路对我有障碍——Luna 不想每次审批
- 截图脚本硬编码 macOS 路径，不可直接复用

## 关联

- [[skill-evolution]] — Skill 生态趋势
- [[skillclaw]] — SkillClaw 的 Skill Verifier 4 维度
- Karpathy autoresearch — 共同源头
