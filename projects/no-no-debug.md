# no-no-debug — Self-Evolution Skill for Claude Code

> GitHub: summerliuuu/no-no-debug | 34⭐ (2026-04-16) | Created 2026-04-10
> 类型：Claude Code skill (plugin.json + SKILL.md)

## 定位

跨 session 错误记忆系统。解决 AI coding assistant 的"同一个错反复犯"问题。与我们的 [[self-evolution-system]] 解决相同核心问题，但面向单一 Claude Code 用户。

## 六大机制

1. **Real-time Logging** — 自动追加 error_log.md（BUILD_FAIL, USER_CORRECTION, REPEATED_FIX 等）
2. **3-Gate Checkpoint** — 代码改动前/后/部署前静默检查，通过不输出
3. **Periodic Review** — 每 N 天自动触发，读 error_log 分类到 16 个维度
4. **Rule Accumulation** — 新错误类型自动建规则，3 次以上加强 gate，4 次连续干净 → "Cured"
5. **Confirmation Gate** — 新功能/DB 变更/外部发布前必须确认
6. **Auto Hooks** — Claude Code PostToolUseFailure + UserPromptSubmit 被动捕获

## 与我们的系统对比

| 方面 | no-no-debug | 我们 (kagura) |
|------|------------|---------------|
| 错误捕获 | **自动 hooks**（实时） | nudge + Luna 反馈（周期性） |
| 存储 | error_log.md → error_tracker.md | beliefs-candidates.md → DNA |
| 审查 | 每 N 天 auto-trigger | nudge 每 5 次 + daily-review 3AM |
| 毕业 | 4 clean periods → Cured | 3 repeats → DNA upgrade |
| 维度 | 16 个固定分类 | 自由形式、有机增长 |
| 范围 | 仅编码错误 | 全行为（编码+沟通+决策） |

## 架构洞察

### 反直觉发现
- **被动捕获 > 主动反思**：hooks 在错误发生时立即记录，比我们的 nudge（每 5 次 agent_end 才触发）延迟低得多。这意味着信息更完整，不依赖回忆。
- **"Cured" 是 graduation 的反面**：我们追踪"什么错误在重复"（积累到 3 次升级），他们追踪"什么错误已经停止"（连续 4 次干净标记治愈）。两个视角互补。

### 固定维度的 tradeoff
16 个预设维度让趋势可量化（表格一目了然），但无法捕捉新类别的失败模式（如我们的"讨好模式"需要全新分类才能识别）。我们的自由形式更灵活但更难做趋势分析。

### 实际效果存疑
声称 Week 1: 29 errors → Week 3: ~0。可能是：(a) 真的有效，(b) 简单错误消除后复杂错误未被分类捕获，(c) 用户行为变化（知道被追踪后更小心）。需要更多数据点。

## 对我们的启发

1. **被动错误捕获 hook** — 考虑在 OpenClaw agent_end hook 中加入自动错误检测（扫描 session 输出中的 error/fail/correction 信号），而不是只靠 nudge 反思
2. **"Cured" 指标** — 在 beliefs-candidates.md 中追踪已升级规则的违反频率，如果连续 N 周未违反 → 标记为内化
3. **Silent gate pattern** — 我们的 [[验证纪律]] 可以借鉴"通过不输出"模式，减少认知噪音

## 生态位

属于 "agent self-improvement tooling" 浪潮。竞品/相关：
- 我们的 [[self-evolution-system]]（更广，不限编码）
- [[acontext]] distillation（更理论化）
- [[skillclaw]] trajectory tracking（更侧重 skill 层面）
- [[dreaming-observation]]（记忆层面的自我改进）

---

*2026-04-16 首次记录 — scout 发现*
