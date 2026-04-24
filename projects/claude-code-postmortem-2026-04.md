# Claude Code Quality Postmortem (April 2026)

- **URL**: https://www.anthropic.com/engineering/april-23-postmortem
- **Date**: 2026-04-23
- **Status**: All issues resolved as of v2.1.116 (April 20)

## 概要
Anthropic 发布了一篇罕见的技术 postmortem，详细解释了 2026 年 3-4 月用户报告 Claude Code 质量下降的三个独立原因。API 未受影响，问题仅在 Claude Code、Agent SDK 和 Claude Cowork 的 harness 层。

## 三个 Bug

### 1. Reasoning Effort 默认值降级 (Mar 4 → Apr 7)
- Opus 4.6 发布时默认 reasoning effort = high
- 因 UI 假死和 latency 投诉，改为 medium
- **Tradeoff 判断失误**：用户更愿意要智能而非速度
- 修复：Opus 4.7 默认 xhigh，其他模型默认 high
- **洞察**：Anthropic 明确说 "longer thinking = better output"，effort 是 test-time-compute 曲线上的采样点

### 2. Thinking 缓存清理 Bug (Mar 26 → Apr 10)
- 设计意图：session 空闲 >1h 后清理旧 thinking，减少 uncached tokens
- 用 `clear_thinking_20251015` API header + `keep:1`
- **Bug**：应该只清一次，实际每个 turn 都在清
- 后果：Claude 逐渐丢失 reasoning 历史 → 看起来健忘、重复、工具调用诡异
- 复合效应：持续 cache miss → 用量限额消耗加速
- **为什么难发现**：
  - 只在 stale session 触发（corner case）
  - 两个无关实验（消息队列 + thinking 显示）掩盖了内部测试的 bug 表现
  - 过了 human review、automated review、unit test、e2e test、dogfooding
- **有趣细节**：回测发现 Opus 4.7 能在 code review 中发现这个 bug，但 Opus 4.6 不能

### 3. System Prompt 限制冗余 (Apr 16 → Apr 20)
- 为 Opus 4.7 的 verbosity 问题添加 system prompt：
  > "Length limits: keep text between tool calls to ≤25 words. Keep final responses to ≤100 words unless the task requires more detail."
- 内部测试数周无回归，但更广泛 eval 发现 3% intelligence drop
- 影响 Sonnet 4.6、Opus 4.6、Opus 4.7

## 改进措施
1. 更多内部员工使用 **公开版** Claude Code（而非测试版）
2. Code Review 工具改进（支持更多 repo 作为 context）
3. System prompt 变更：每次跑 per-model eval suite、逐行 ablation、soak period、gradual rollout
4. `@ClaudeDevs` on X 用于透明沟通
5. 全部订阅用户 usage limit reset

## 对我们的意义

### 架构洞察
- Claude Code 的 "harness 层" 对输出质量影响巨大 — **同一模型、不同 harness 配置 = 不同体验**
- 这是 [[agents-md]] 思路的反面验证：agent 的行为不只由 model 决定，prompt + context management 才是关键
- thinking/reasoning 的 context management 是 agent 架构中被低估的基础设施
- `clear_thinking` API 的存在说明 Anthropic 把 thinking 和 content 分开管理 — 这跟 [[opencode-compaction]] 的 compaction 是同一问题域

### 对 OpenClaw 的启示
- OpenClaw 通过 ACP 调用 Claude Code，也受这些 bug 影响
- 长 session + idle 是常见场景（cron 驱动的 agent），正好踩中 Bug #2
- **effort 参数很重要**：OpenClaw 的 `reasoning` 设置直接映射到这个机制
- postmortem 中提到的 "eval 覆盖不足" 对所有 agent harness 都是警示

### Meta 观察
- 三个独立 bug 叠加 → 用户感知为 "模型变笨了" — 这是 [[distributed-system-failure]] 的经典模式
- "dogfooding 不够" 是根因之一 — 内部用的版本和外部不同
- Anthropic 的透明度在 AI 公司中罕见，这篇 postmortem 的技术深度值得尊重
