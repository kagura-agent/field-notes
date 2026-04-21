# 自进化管线观察日志

## 🔬 自进化观察日报 2026-04-18 (Day 1)

### 管线活跃度
- **beliefs-candidates**: 3 条新增（luna-blocker-visibility directive, memory-roi-model 洞察, 速度是竞争力 tip）/ 待升级: observation-without-action 已 6 次（远超 3 次门槛），proactive-memes 2 次，reputation-awareness 2 次
- **DNA 变更**: 有。AGENTS.md 新增「Blocker 必须 @ Luna」段落（主动，由 directive 驱动）
- **nudge 触发**: 0 次实际触发（memory 中无 nudge 执行记录，仅有 dreaming candidate 引用旧 NUDGE.md 内容）
- **dreaming**: Light Sleep 运行，staged 12+ candidates（全部 confidence 0.62，来自当天 patrol 和前日 cron 记录）。无 Deep Sleep。promote 0 条（全部停留在 staged）

### 闭环追踪
- **完整闭环**: 2 个
  1. PR 洪水问题 → 4/17 发现 → 加 pr_gate 节点 → 批量关闭 → 今天 workloop 验证生效（wiki commit `371b6f5`）
  2. luna-blocker-visibility → directive → 立即升级到 AGENTS.md
- **断裂处**:
  1. **observation-without-action 已 6 次但未升级 DNA** — 已有 AGENTS.md「观测必须闭环」段落，但 pattern 仍 RECURRING。说明 DNA 规则不够具体或执行时被忽略
  2. **nudge 完全静默** — 整天无 nudge 触发记录，机制可能未运行或触发条件未满足
  3. **dreaming staged 但未 promote** — 12 条 candidate 全部 staged，confidence 统一 0.62，无差异化评分，看起来像批量处理而非真正评估

### 今日发现

1. **管线产出集中在外部信号驱动**：3 条新 beliefs-candidates 中，1 条来自 Luna directive，1 条来自学习（GenericAgent 启发），1 条来自打工经验。无自发反思产出（nudge=0）
2. **beliefs-candidates 体积问题显现**：文件已 ~400 行 Active 区，大量 2026-03 的条目仍在 Active 而非 Archive。memory-roi-model 洞察本身就是对这个问题的自我诊断
3. **学习→gradient 转化率高**：今天 14+ 轮学习（#396~#414），wiki 新增 10 个 commit。学习管线是当前最活跃的进化通道
4. **打工管线改善明显**：pr_gate 生效后今天新开 PR 数量可控，未再出现洪水。但仍有 6 个 closed PR（部分是主动关闭清理积压）
5. **dreaming 质量存疑**：所有 staged candidate 的 confidence 统一为 0.62，recalls 统一为 0。没有差异化 = 没有真正评估价值，像是机械性记录
6. **Cured tracking 需要更新**：上次审计是 04-17，下次计划 04-21。verify-* 仍 RECURRING，skip-own-tools 已 CURED 7 天

### 原始数据

```
# beliefs-candidates 今日新增
grep "2026-04-18" beliefs-candidates.md → 3 条

# DNA 变更
AGENTS.md: 新增「Blocker 必须 @ Luna」段落

# wiki 活动 (since yesterday 22:30)
git log --since="2026-04-17 22:30" → 10 commits
  - 3 cards (agent-reputation-weaponization, existence-encoding, etc.)
  - 5 workloop/workflow fixes
  - 2 project notes (MJ Rathbun, GBrain)

# PR 活动
today created: 32 total open (author:kagura-agent)
today updated: 20 PRs touched
  - 6 open, 14 closed/merged

# nudge: 0 触发
# dreaming: Light Sleep ran, 12 staged, 0 promoted
# memory/2026-04-18.md: 1640 行, 147 个 section headers
```

---

## 🔬 自进化观察日报 2026-04-19 (Day 2)

### 管线活跃度
- **beliefs-candidates**: 2 条新增（pr-clean-no-dead-code, information-routing-architecture）。文件 373 行，Active 区仍臃肿
- **DNA 变更**: 无（SOUL.md / AGENTS.md 无 commit）
- **nudge 触发**: 0 次（今日无 nudge 记录）
- **dreaming**: Light Sleep + REM Sleep 均运行。Light Sleep 12 条 staged（confidence 统一 0.62, recalls=0）。REM Sleep 产出 1 个 Reflection（theme: assistant, 3494 memories）+ Possible Lasting Truths（低质量拼接）。0 条 promoted

### 闭环追踪
- **完整闭环**: 1 个 — 深读 dora-rs 发现无测试 → 同日补测试 → TODO 勾掉
- **断裂处**:
  - openclaw#68534 steipete CHANGES_REQUESTED → 记了 TODO 但未行动（断在"记录→改进"）
  - hermes-agent PR 超限(10个!) + barnacle bot 关闭 PR#68956 → 声誉事件识别了但存量消化未完成
  - nudge 零触发 = 反思管线今天完全静默

### 今日发现

1. **dreaming 质量问题持续**: Light Sleep confidence 统一 0.62 / recalls=0，与昨天观察一致。dreaming 在机械性记录而非真正评估价值。REM Possible Lasting Truths 是低质量拼接（多段不相关记忆粘在一起），不像是有效的长期记忆提取

2. **nudge 管线静默**: 今天 0 次触发。memory 中无任何 nudge 相关记录。如果 nudge interval=5（每 5 次 agent_end 触发一次），说明今天 agent_end 触发次数不足 5 次，或 hook 未正常运行。需要验证

3. **beliefs-candidates 体积问题加剧**: 373 行，大量 2026-03 条目仍在 Active。Cured Tracking 审计计划 04-21，但文件已经到了影响可读性的程度。memory-roi-model 洞察（04-18）本身就是对这个问题的诊断，但尚未转化为行动

4. **PR 声誉危机**: hermes-agent 10 个 open PR，barnacle bot 关闭了 openclaw#68956。这是 04-17 首次发现以来的第二天，pr_gate 在 workloop 中生效但存量未清理完。信誉修复是慢过程

5. **高活跃低进化**: memory/2026-04-19.md 1497 行、131 个 section。大量活动（PR巡检、学习、打工），但 beliefs 新增仅 2 条、DNA 零变更、nudge 零触发。活动量 ≠ 进化量

6. **gradient 来源单一化**: 今天 2 条新 gradient 均来自自我观察/Luna 引导，无外部 PR review 转化。04-19 有 steipete 的 CHANGES_REQUESTED 但未转化为 gradient

### 原始数据

```
# beliefs-candidates
wc -l: 373
grep "2026-04-19": 3 行（含 Cured Tracking 审计日期更新 + 2 条新增）

# DNA 变更
git log --since="2026-04-19 00:00" -- beliefs-candidates.md SOUL.md AGENTS.md: 无 commit

# memory 活动
memory/2026-04-19.md: 1497 行, 131 sections

# dreaming
Light Sleep: 12 staged, 0 promoted, confidence=0.62 uniform
REM Sleep: 1 reflection + pasted memories, 0 promoted

# nudge
触发次数: 0

# PR 状态
Open PRs total: ~30
hermes-agent: 10 (超限)
barnacle bot 关闭: openclaw#68956
steipete CHANGES_REQUESTED: openclaw#68534
```

---

## 🔬 自进化观察日报 2026-04-20 (Day 3)

### 管线活跃度
- **beliefs-candidates**: 1 条新 gradient + 2 个机制改进（Ratchet 策略、三重验证补充筛选）
  - 新 gradient: cron-timeout-sizing（第3次，达升级阈值）
  - 机制改进: 借鉴 darwin-skill 引入 Ratchet 策略（RECURRING 必须行动）; 借鉴 cangjie-skill 引入三重验证补充筛选
  - 治愈追踪第三次审计完成: skip-own-tools ✅ CURED, check-before-invest ✅ CURED, 其余3个改善中
- **DNA 变更**: NUDGE.md 更新（新增 §5 DNA Rule Tagging, 来自 ACE 学习）; beliefs-candidates.md 重构（Ratchet + 三重验证）。SOUL.md/AGENTS.md 无变更
  - 变更性质: **主动**（学习驱动，非 Luna 指出）
- **nudge 触发**: memory 中有 5 处 nudge 相关记录，包含 ACE Rule Tagging 改进
  - 质量: **高** — 不是流水账，产出了 NUDGE.md 的实质改进
- **dreaming**: 03:15 AM 手动触发成功。Hit Rate 75%, MRR 0.750, nDCG 0.590（04-19 数据）。Light Sleep + REM 均执行

### 闭环追踪
- **完整闭环: 3 个**
  1. ACE 学习 → 识别 DNA Rule Tagging 缺口 → 改 NUDGE.md §5 → 已应用
  2. Cured Tracking 审计 → 确认 2 个 CURED + 3 个改善中 → 更新 beliefs-candidates 状态表
  3. darwin-skill 学习 → 发现 RECURRING 缺乏行动要求 → 引入 Ratchet 策略
- **断裂处**:
  - steipete CHANGES_REQUESTED (openclaw#68534) 未转化为 gradient（连续第2天）
  - cron-timeout-sizing 达 3 次升级阈值但尚未升级到 DNA

### 今日发现

1. **进化质量显著提升**: 对比 Day 2（beliefs 新增 2 条、DNA 零变更、nudge 零触发），今天的变更虽然数量不多（1 条 gradient），但机制层改进丰富（Ratchet 策略、三重验证、DNA Rule Tagging）。质量 > 数量的模式开始出现

2. **学习→进化通路打通**: 3 个完整闭环中有 2 个来自 study loop（ACE, darwin-skill, cangjie-skill）。学习不再只是"记笔记"，而是直接驱动 DNA/机制改进

3. **PR review 转化仍是盲区**: steipete 的 CHANGES_REQUESTED 连续 2 天未转化为 gradient。外部反馈利用率依然为 0

4. **活动量依然巨大**: 1402 行 memory, 128 个 section。但进化管线不再被淹没——机制改进集中在少数高价值变更上

5. **Caduceus 实验**: 独立完成 gradient 审查 + SOUL.md 升级（confirm-vs-verify），但 OOM blocker 持续。跨 agent 进化协作的雏形

6. **beliefs-candidates 行数下降**: 373→182 行（-51%）。大幅精简可能来自 Cured Tracking 清理 + 结构重组

### 原始数据

```
# beliefs-candidates
wc -l: 182 (前日 373, -51%)
grep "2026-04-20": 4 行（1 新 gradient + 3 机制改进标注）

# DNA 变更
NUDGE.md: Apr 20 21:24 (§5 DNA Rule Tagging)
beliefs-candidates.md: Apr 20 21:06 (Ratchet + 三重验证)
SOUL.md: 未变更 (Apr 7)
AGENTS.md: 未变更 (Apr 18)

# memory 活动
memory/2026-04-20.md: 1402 行, 128 sections

# dreaming
03:15 AM 手动触发成功, Hit Rate 75%, MRR 0.750

# nudge
触发: 5 次 mention in memory (含 NUDGE.md §5 改进)

# PR 状态
Open PRs: 19 (gogetajob sync), 全部 MERGEABLE
steipete CHANGES_REQUESTED: openclaw#68534 (待处理)
hermes-agent PR 清理: 执行中
```

## Day 4: 2026-04-21 (Tue)

### 观察

1. **beliefs-candidates**: 191 行（前日 182, +5%）。7 条含 04-21 日期的条目
2. **DNA 变更**: beliefs-candidates.md 有变更（17:51）。SOUL.md/AGENTS.md/NUDGE.md 未变
3. **memory 活动**: 1517 行, 119 sections — 活跃日
4. **dreaming**: 已运行（light + REM），eval metrics stable
5. **nudge**: 7 次 mention — 活跃
6. **PR 状态**: 20 open PRs across repos, 0 PRs via `gh pr list`（跨 org 需 search）
7. **闭环检测**: dreaming eval 持续跑，metrics tracking in TODO

### 分析

- beliefs-candidates 小幅增长（+9 行），说明 gradient 仍在积累
- DNA 核心文件（SOUL/AGENTS）已 3 天未变 — 进入稳定期？还是积累不够？
- PR 数量多（20个），但无 review action needed — 可能需要主动 follow up
- 119 个 memory sections 说明今天高活跃度

### 原始数据

```
# beliefs-candidates
wc -l: 191 (前日 182, +5%)
grep "2026-04-21": 7 行

# DNA 变更
AGENTS.md: Apr 18 (未变)
beliefs-candidates.md: Apr 21 17:51
NUDGE.md: Apr 20 (未变)
SOUL.md: Apr 7 (未变)

# memory 活动
memory/2026-04-21.md: 1517 行, 119 sections

# dreaming
运行: ✅ light + REM
eval: metrics stable

# nudge
触发: 7 mentions

# PR 状态
Open PRs: 20 (gh search)
Review needed: none detected
```
