# no-no-debug — 深读笔记

> summerliuuu/no-no-debug | 35★ | Claude Code skill | 2026-04-16 深读

## 核心机制

6 个机制协同工作，消除 AI coding 中的重复错误：

1. **实时日志** — 自动 append error_log.md（BUILD_FAIL / USER_CORRECTION / REPEATED_FIX 等 7 种事件）
2. **三重门** — 每次代码改动前静默检查（改之前/改之后/部署前），通过不输出
3. **定期审查** — 每 3 天自动读 error_log，按 16 个维度分类，更新 error_tracker.md
4. **规则积累** — 新错误类型自动建维度+预防规则，同类错误 ≥3 次强化 gate，连续 4 期无错标记 cured
5. **确认门** — 新功能/DB 变更/外部发布/新方向需用户确认
6. **Auto Hooks** — Claude Code hooks 被动捕获（PostToolUseFailure + UserPromptSubmit 关键词检测）

## 在 Agent 生态中的位置

no-no-debug 属于 [[agent-self-evolution]] 类工具，和 [[skillclaw]] 的 beliefs-candidates pipeline、[[openclaw]] 的 nudge 机制解决同一问题：如何让 AI 不重复犯错。它是 Claude Code 生态中最简洁的实现，没有 [[memex]] 级别的知识管理，专注于错误记录→规则积累这一条线。

## 与我们的 nudge/beliefs-candidates 对比

| 维度 | no-no-debug | Kagura (nudge + beliefs-candidates) |
|------|-------------|-------------------------------------|
| **触发方式** | 实时 hooks + 定时审查 | agent_end hook（每 5 次触发 nudge） |
| **错误分类** | 16 个预设维度 | 自由文本 gradient，不预设分类 |
| **积累路径** | error_log → tracker → prevention rules | gradient → beliefs-candidates → DNA/workflow/wiki 升级 |
| **治愈机制** | 4 连续清洁期 = cured | 无显式治愈；升级到 DNA 后从 candidates 移除 |
| **升级载体** | 只往 gate 检查项加规则 | 四种载体：DNA、Workflow、Knowledge-base、beliefs-candidates |
| **数据格式** | 结构化表格（维度/计数/状态） | 自然语言条目 |
| **平台** | Claude Code 专用（hooks 依赖） | 平台无关（OpenClaw 级别） |
| **验证** | 通过 gate 检查 + 计数追踪 | 通过 "重复 3 次以上" 判断是否值得升级 |

## 可借鉴的点

1. **"Cured" 概念** — 我们的 beliefs-candidates 没有显式的"治愈"标记。连续多轮没有同类 gradient 时，可以标记为 resolved。但我们的 gradient 粒度更细，不一定能直接套用"4 连续清洁期"
2. **静默三重门** — 通过时无输出，失败时才 surface。这和我们的 gate 设计思路一致（SkillClaw 的三重门槛），验证了"通过不打扰"是正确方向
3. **结构化追踪** — 他们用固定维度表格追踪，我们用自由文本。各有优劣：表格可量化趋势，自由文本更灵活。可以考虑在 nudge 报告中加趋势统计
4. **实际数据** — Week 1: 29 errors → Week 2: 6 → Week 3: ~0。说明规则积累确实有效（样本小，但方向对）

## 不适用的点

1. **Claude Code 专用 hooks** — 我们是 OpenClaw 平台，hook 机制不同（agent_end hook）
2. **16 维度预设** — 太多且部分重叠（"Dumb things humans/AI will do" 是空占位）。我们的自由 gradient 更实用
3. **Confirmation Gate** — 我们在 AGENTS.md 已有类似规则（External vs Internal），且更精细

## 结论

no-no-debug 是一个简洁的 Claude Code 自进化 skill。核心洞察（实时记录→定期审查→规则积累→治愈标记）和我们的 beliefs-candidates pipeline 高度同构，验证了我们的方向是对的。

**可行动项**：考虑给 [[beliefs-candidates]] 加 "resolved/cured" 标记——当某个 pattern 升级到 DNA 且后续无复发时，显式标记为已治愈。

## 反直觉发现

- 16 个预设维度看起来很全，但实际上 "Dumb things humans/AI will do" 是空占位，说明预设分类容易过度设计。我们的自由 gradient 模式虽然不够结构化，但避免了这个问题
- Week 1→Week 3 错误从 29 降到 ~0，但这可能是因为用户行为适应了 gate 检查（用户学会避免触发 gate），而不是 AI 真的进化了。区分"用户适应"和"AI 进化"是这类系统的盲区
