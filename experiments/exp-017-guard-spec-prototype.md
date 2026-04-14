---
title: "Exp-017: Guard Spec Prototype"
created: 2026-04-14
status: design
hypothesis: "Formalizing AGENTS.md red lines as structured guard specs improves compliance (fewer repeated violations)"
related: guard-spec-format, tool-execution-policy-enforcement, beliefs-upgrade-quality-gate
---

## 实验动机

AGENTS.md 的红线规则当前是纯文本，依赖模型在 system prompt 中"记住"并遵守。
历史数据显示重复违反是最大失败模式：

| 红线 | 违反次数 | 最终升级 | 升级日期 |
|------|---------|---------|---------|
| 验证纪律 | 18 次 | AGENTS.md 结构化 8 条 | 2026-04-09 |
| 隐私保护 | 4 次 | AGENTS.md 5 条子规则 | 2026-03-25 |
| 讨好模式 | 3 次 | AGENTS.md 专项条目 | 2026-03-25 |
| 编造机制 | 3 次 | 合并入验证纪律 | 2026-04-09 |

来源: beliefs-candidates.md graduation history

**核心问题**: 文本规则足以指导行为吗？还是需要程序化拦截作为安全网？

## 假设

1. **H1**: 将可程序化的红线（trash>rm、no-push-main、PII-grep）转化为 guard spec 并通过 hook 拦截，可以将工具层面的违反降为 0
2. **H2**: 不可程序化的红线（验证纪律、讨好模式）无法通过 guard 解决，需要 post-session policy compliance review
3. **H3**: Guard spec 格式本身（即使未实现 hook）通过结构化表达提高规则的清晰度，间接降低违反率

## 实验设计

### Phase 1: Design（当前）
- [x] 分类 AGENTS.md 红线为 policy/guard/action
- [x] 设计 guard spec YAML schema
- [x] 写出 5 条具体 guard spec
- [x] 评估哪些今日可实现

### Phase 2: Implement（待定）
- [ ] 写 OpenClaw plugin 实现 guard evaluator
- [ ] 从最简单的 guard 开始：trash-over-rm
- [ ] 验证 `before_tool_call` hook 能否返回 block/confirm
- [ ] 注意: OpenClaw 目前的工具控制是 approval system（交互式），不是 programmatic block
  - 可能需要先贡献一个 programmatic block 能力（参考 hermes-agent 的实现）

### Phase 3: Measure
- [ ] 统计 Phase 2 实施前后的违反次数（来源: beliefs-candidates.md）
- [ ] 区分: guard 拦截了多少次 vs policy 违反了多少次
- [ ] 基线: 2026-03-22 ~ 2026-04-14 期间的违反频率

## 基线数据

来自 beliefs-candidates.md 和 AGENTS.md 升级历史的违反频率：

**2026-03-22 ~ 2026-04-14（24 天）:**
- 验证类违反: ~18 次（最密集，0.75/天）
- 隐私泄露: 4 次（0.17/天）
- 讨好行为: 3 次（0.13/天）
- 工程流程违反（push main, 没测试等）: ~12 次（0.5/天）

**目标**:
- Guard 可拦截的违反 → 降到 0（工具层面）
- Policy 类违反 → 通过 post-session review 降低 50%

## 指标

| 指标 | 定义 | 采集方式 |
|------|------|---------|
| guard_blocks | Guard 成功拦截的工具调用数 | plugin 日志 |
| guard_bypasses | Guard 被 confirm 后放行的次数 | plugin 日志 |
| policy_violations | Policy 类违反（从 beliefs-candidates 新增条目统计） | 人工 daily-review |
| false_positives | Guard 误拦截的合法操作 | 人工反馈 |

## 风险

1. **Over-blocking**: Guard 太严导致正常工作被频繁打断 → 设 exception 白名单
2. **False security**: 有了 guard 就不注意 policy → guard 只是安全网，不替代判断力
3. **Maintenance burden**: Guard spec 需要随工作流变化更新 → 保持 spec 数量少而精
4. **OpenClaw hook 限制**: 当前 before_tool_call 可能不支持 programmatic block → 需要先贡献能力

## 相关

- [[guard-spec-format]] — guard spec 格式定义和具体示例
- [[tool-execution-policy-enforcement]] — hook 拦截的跨项目比较
- [[beliefs-upgrade-quality-gate]] — 规则质量的 4 维评估
- [[rivonclaw]] — 规则三分法的来源项目
