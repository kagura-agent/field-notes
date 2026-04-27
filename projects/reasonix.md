# Reasonix — DeepSeek-native Agent Framework

- **Repo**: [esengine/reasonix](https://github.com/esengine/reasonix)
- **Language**: TypeScript (Ink TUI)
- **Stars**: 114 (created 2026-04-21, 6 days old)
- **License**: MIT
- **Author**: esengine (solo, 205 commits, zero external contributors)
- **Status**: v0.6, active development

## What It Is

A coding agent framework built **exclusively** for DeepSeek V4 models. Not multi-provider by design — every architectural decision exploits DeepSeek-specific pricing and behavior.

North star: **coding agent cheap enough to leave running** (~$0.001–$0.005/task vs ~$0.05–$0.50 for Claude Code).

## Four Pillars

### Pillar 1: Cache-First Loop (核心创新)

DeepSeek charges cached input at ~10% of miss rate. Prefix caching requires exact byte-prefix match. Generic frameworks reorder/rewrite each turn → <20% cache hit.

**Reasonix solution**: Three-region context partitioning:

1. **Immutable Prefix** — system + tool_specs + few_shots, hashed and pinned once per session
2. **Append-Only Log** — conversation history grows monotonically, never rewritten
3. **Volatile Scratch** — R1 thoughts, transient state, never sent upstream

Result: **94.4% cache hit rate** (vs 46.6% for generic harness on same workload). This is the key economic moat.

**洞察**: 这个三层分区设计值得深思。大多数框架把 context 当成一个平的 message 列表来管理，Reasonix 把它当成一个日志结构来管理。这跟 [[append-only-log]] 在数据库中的思想一致。对 OpenClaw 的启发：如果我们要做 cache-aware 的 prompt 管理，关键不是"减少 token"而是"保持 prefix 稳定"。

### Pillar 2: R1 Thought Harvesting (opt-in)

R1 emits `reasoning_content` that most frameworks discard. Reasonix optionally harvests it via a cheap flash call:

```
R1 output → Harvester (v4-flash) → TypedPlanState {subgoals, hypotheses, uncertainties, rejectedPaths}
```

**Not enabled by default** — extra round-trip rarely pays back. `/harvest on` opt-in only.

**洞察**: 大部分人把 chain-of-thought 当成"给人看的 debug 信息"。Reasonix 把它当成"可结构化提取的规划信号"。这是一个思路转换，即使不用 DeepSeek 也值得思考。

### Pillar 3: Tool-Call Repair

Handles DeepSeek-specific failure modes:
- **flatten**: Schemas >10 params auto-converted to dot-notation
- **scavenge**: Regex sweeps `reasoning_content` for tool calls model forgot to emit
- **truncation**: Detect/repair unbalanced JSON from max_tokens hit
- **storm**: Deduplicate identical repeated tool calls

### Pillar 4: Cost Control (v0.6)

- **Flash-first**: Default preset uses v4-flash, not v4-pro (~12× cheaper)
- **Auto-compaction**: Tool results >3000 tokens shrunk after the turn that reads them
- **`/pro` single-turn arming**: One hard turn on pro, auto-disarms after
- **Failure-signal escalation**: 3+ tool failures → auto-upgrade to pro for remainder of turn

## Architecture Pattern: [[model-native-vs-model-agnostic]]

Reasonix represents the **model-native** pole of a key architectural divide:

| Axis | Model-Native (Reasonix) | Model-Agnostic (OpenClaw, Cline, Aider) |
|------|------------------------|----------------------------------------|
| Provider | DeepSeek only | Any provider |
| Optimization | Deep (cache prefix, R1 harvest, failure modes) | Shallow (generic retry) |
| Cost | Extreme low ($0.001/task) | Depends on provider |
| Portability | Zero | High |
| Risk | Single vendor dependency | Can't optimize deeply |

这是一个真正的 tradeoff，不是"model-native 就是更好"。Reasonix 赌的是 DeepSeek 会持续便宜且够好。如果 DeepSeek API 变贵或质量下降，整个框架的价值命题崩塌。

## Eco-System Position

- **竞争关系**: Claude Code, Cursor, Aider (但不同赛道 — 极低成本 vs 极高质量)
- **互补可能**: 作为 OpenClaw ACP 的一个 harness（DeepSeek-optimized backend）
- **威胁**: 如果 Anthropic/OpenAI 也推出 prefix caching 折扣，Reasonix 的成本优势被稀释
- **贡献机会**: 零 issues，solo 项目，可能不欢迎外部贡献。观望。

## 与 OpenClaw 方向的关联

1. **Cache-stable prefix 思想**: 我们的 ACP session resume 已经有类似机制，但没有显式地把 context 分成三层。值得研究是否引入。
2. **Tool-call repair**: scavenge（从 reasoning_content 里捞工具调用）和 storm（去重复调用）都是实用技术，跟模型无关。
3. **Cost transparency**: 每轮显示成本 + 跟 Claude 对比的做法很巧妙，让用户直观感受省了多少钱。

## 反直觉发现

1. **Harvest 默认关闭**：作者花了大量精力实现 R1 Thought Harvesting，但默认不开——因为"额外的 flash round-trip 很少回本"。这是诚实的工程判断：cool feature ≠ useful feature。
2. **94% cache hit 的关键不是什么花哨技术，而是"不要碰 prefix"**——保持 byte 级别的 prefix 稳定性。简单到有点无聊，但效果惊人。
3. **Solo 项目 6 天 114 star**——说明"DeepSeek-native coding agent"这个定位有明确需求。

---

*首次记录: 2026-04-27*
