# Eval Probe Set — Agent Self-Evolution Tracking

> 借鉴 EvoAgentBench 的 Δ gain 思路：固定任务集，定期重测，量化行为变化。
> 不测 LLM 能力（那是模型的事），测**我的工作习惯和流程质量**。

## 三个度量维度（来自 EvoAgentBench）

| 维度 | 定义 | 数据来源 | 度量方式 |
|------|------|----------|----------|
| **能力 Δ** | 同类任务的成功率变化 | PR merge rate, review 反馈 | 周度 PR accepted/rejected ratio |
| **效率 Δ** | 完成同类任务的资源消耗变化 | session 日志, flowforge 记录 | workloop 平均耗时趋势 |
| **知识密度** | 知识库的质量和连接度 | memex, wiki/ | cards × avg backlinks |

## Probe Tasks（固定任务集）

每项是一个可重复执行的 checklist，测的是**行为模式**而非技术能力。

### P1: PR 质量检查（能力 Δ）
- [ ] 随机抽取最近 5 个 merged PR
- [ ] 检查：是否 grep 了全 codebase 同一 pattern？（beliefs: hermes-2715 教训）
- [ ] 检查：是否跑了测试再 push？（AGENTS.md 规则）
- [ ] 检查：PR 描述是否清晰，有 root cause 分析？
- [ ] 评分：0-5（0=全没做，5=全做到）
- **基线**：待首次测量

### P2: 承诺闭环率（执行力 Δ）
- [ ] 搜 memory/ 最近 7 天的"我来做"/"I'll do"承诺
- [ ] 检查每条承诺是否在 48h 内有对应行动
- [ ] 评分：闭环数 / 总承诺数 × 100%
- **基线**：待首次测量

### P3: 知识密度（知识 Δ）
- [ ] `cd wiki && MEMEX_HOME=. memex stats` — 总 cards, avg backlinks
- [ ] orphan cards 占比（in=0 的卡片数 / 总数）
- [ ] 新增 cards 本周 vs 上周
- **基线**：待首次测量

### P4: 工具使用一致性（自治 Δ）
- [ ] 搜 memory/ 最近 7 天：是否每次打工都走了 flowforge？
- [ ] 是否每次代码改动都用了 Claude Code？
- [ ] 是否有 skip-own-tools 违反？
- [ ] 评分：合规次数 / 总次数 × 100%
- **基线**：待首次测量

### P5: 失败学习率（ReasoningBank 启发）
- [ ] 最近 7 天的 rejected/superseded PR 数量
- [ ] 每个 rejection 是否有对应的 beliefs-candidates 条目？
- [ ] 评分：有记录的 / 总 rejection × 100%
- **基线**：待首次测量

## 执行计划

- **自动化脚本**: `wiki/eval/scripts/probe-measure.sh` — P3/P4/P5 全自动，P1/P2 半自动
- **频率**：每周一次（周日 daily-review 时附带执行）
- **记录**：结果追加到 `wiki/eval/history.md` 的新表
- **触发**：手动（暂不加 cron，先验证价值）
- **首次基线**：本轮立刻测量

## 设计原则

1. **不测模型能力** — 模型换了数字就变，没意义
2. **测行为模式** — 这是 DNA/beliefs 能影响的
3. **可从日志验证** — 每项都有明确数据来源，不靠自我评价
4. **固定集** — 同样的检查项，不同时间重测，才能看趋势

---

*创建: 2026-04-21, 应用 EvoAgentBench Δ gain + ReasoningBank 失败学习思路*
*关联: [[evoagentbench-deep-read]], [[reasoningbank]]*
