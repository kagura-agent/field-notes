# Deterministic Compression vs LLM Summarization

> 两条 agent memory 压缩路线的 tradeoff 分析

## 路线对比

| 维度 | Deterministic (cavemem) | LLM Summarization (dreaming) |
|---|---|---|
| 压缩目标 | 语法冗余（articles, hedges, fillers） | 语义冗余（重复信息、低价值内容） |
| 压缩率 | ~75%（仅语法层） | 90%+（可大幅浓缩） |
| 信息损失 | 零（round-trip reversible） | 有（不可逆，可能幻觉） |
| 延迟 | <150ms（regex） | 秒级（LLM call） |
| 成本 | 零 | Token 成本 |
| 适用场景 | 高频写入（每次 tool use） | 低频批处理（session end / daily） |

## 洞察

1. **互补而非竞争**。最优方案是 pipeline：先 deterministic compress（cheap, lossless），再 LLM summarize（expensive, lossy but semantic）。cavemem 已经在第一层做了，但没有第二层。我们的 dreaming 直接做第二层。
2. **Reversibility 的价值被低估了**。cavemem 的 expand() 可以还原压缩文本给人读。LLM summary 一旦生成，原文就丢了（除非另存）。对于需要回溯的场景（debug、审计），reversibility 很重要。
3. **Write-path latency 决定了能捕获什么**。cavemem <150ms 的写入延迟让它能捕获每次 tool use。如果 write path 需要 LLM call，就只能在 session boundary 做——中间的细粒度观察就丢了。

## 对我们的启示

- 考虑在 daily memory log 写入时加 deterministic preprocessing（strip 重复信息、标准化格式），再送 dreaming
- memex search 可以加 FTS5-style keyword search 作为 semantic search 的补充
- 观察粒度和压缩策略是 tradeoff：粒度越细需要压缩越激进

Links: [[cavemem]], [[context-budget-constraint]], [[existence-encoding]], [[agent-memory-landscape-202603]]
