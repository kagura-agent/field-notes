---
title: Skill Determinism Ladder — 审查标准
created: 2026-04-10
tags: [skill-quality, determinism, skill-creator, self-evolving]
source: skill-evolution (hao-cyber), skill-creator determinism-audit.md, EvoAgentX MAP-Elites insights
---

## 概述

Skill 质量的核心维度之一是**确定性（determinism）**：同一输入能否产生可预测的输出。确定性越高，skill 越可靠、可测试、可演化。

本标准将 skill 按确定性从低到高分为 5 级（Level 0–4），用于审查现有 skill 和指导新 skill 开发。

## Determinism Ladder

| Level | 名称 | 特征 | 可重复性 | 示例 |
|-------|------|------|----------|------|
| **L0** | Implicit | 纯自然语言描述，无结构，依赖 agent "悟性" | ❌ 不可重复 | "帮我处理 PDF" — 没有步骤、没有约束 |
| **L1** | Structured | 有编号步骤和条件分支，可手动重复 | ⚠️ 人工可重复 | SKILL.md 中有清晰的 1-2-3 步骤流程 |
| **L2** | Verifiable | 有明确的验证条件/检查点，可自动检查输出 | ✅ 可自动验证 | `scripts/validate.sh` 检查输出格式；preflight 检查环境 |
| **L3** | Testable | 有测试用例，可回归测试，失败可定位 | ✅ 可回归测试 | `scripts/test.sh` 跑 happy path + edge cases；CI 集成 |
| **L4** | Evolvable | 有反馈循环和演化机制，可自动优化 | ✅ 可自动优化 | 反思触发 → 自动修复；maturity signals 驱动发布；fork-merge 变体选择 |

## 各级详细标准

### L0: Implicit（隐式期望）
- SKILL.md 只有模糊描述，缺 frontmatter 或 description 不完整
- 关键行为依赖 agent 默认知识，未写下
- **升级路径**：写下所有隐式期望 → L1

### L1: Structured（结构化指令）
- SKILL.md 有完整 frontmatter（name + description with triggers）
- 步骤用编号列表或伪代码，有条件分支
- 关键决策点有明确指导（不是"自行判断"）
- 使用 progressive disclosure：核心在 SKILL.md，细节在 references/
- **升级路径**：把"必须做"的步骤脚本化 → L2

### L2: Verifiable（可验证）
- 关键步骤有对应 `scripts/` 可执行（preflight、scaffold、validate）
- 环境检查脚本化（不只是"需要 Python 3.12"）
- 输出格式有模板或验证脚本
- 错误处理有具体路径（不是"gracefully handle"）
- **审查问题**（from determinism-audit.md）：
  - 有没有重复的 prose 指令可以变 script？
  - 关键副作用是否由 hooks 保证？
  - 错误路径是否定义了具体行为？
- **升级路径**：加测试用例 → L3

### L3: Testable（可测试）
- 有 `scripts/test.sh` 或等价测试入口
- 覆盖 happy path + 常见 edge cases
- 测试可在 CI 中运行（无需人工判断）
- 回归测试：改了 skill 后跑一遍确认没 break
- **升级路径**：加反馈循环和自动优化 → L4

### L4: Evolvable（可演化）
- 有反思触发条件（执行失败、用户纠正、silent miss）
- 反思流程结构化：identify → read → impact scan → propose → apply
- 有 maturity signals（≥N 次真实使用、稳定期无修复、结构合规）
- 有 escalation 机制（连续同问题 → 升级为结构性问题）
- 支持 fork 变体（不同上下文可有不同最优版本）

## 审查流程

审查一个 skill 时：

1. **判断当前 Level**：逐级检查，第一个不满足的就是当前天花板
2. **识别升级机会**：对照上一级标准，找最小改动能升一级的点
3. **优先级排序**：
   - 安全/正确性相关 → 必须至少 L2
   - 高频使用 → 推到 L3
   - 核心 skill → 目标 L4
4. **不追求全 L4**：简单 skill 在 L1-L2 就够了，过度工程化反而增加维护成本

## 与 skill-creator 的关系

skill-creator 的 `references/determinism-audit.md` 已有 4 级 ladder（Script > Hook > Instruction > Implicit）和审查 checklist。本标准在其基础上：

1. **扩展为 5 级**：增加 L3（Testable）和 L4（Evolvable），覆盖 skill 全生命周期
2. **增加判定标准**：每级有明确的 checklist items，不只是概念描述
3. **增加升级路径**：每级说明怎么升到下一级

**建议集成方式**：
- 在 skill-creator SKILL.md 的 "Step 4: Edit the Skill" 和 "Step 6: Iterate" 中引用本 ladder
- `package_skill.py` 验证时可报告当前 Level（基于 scripts/ 和 references/ 的存在性）
- 审查/audit 时用 determinism-audit.md checklist + 本标准的 Level 判定

## 相关

- [[skill-evolution-three-layers]] — 三层架构中本标准属于层 2（生命周期管理）
- [[skill-is-memory]] — skill 作为 agent 记忆的外化形式
- skill-creator `references/determinism-audit.md` — 原始 4 级 checklist
