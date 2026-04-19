# Query Dilution in Embedding Search

> Pattern: 给 semantic search query 加更多词 ≠ 更精确的结果，反而可能更差

## 现象

Embedding model (text-embedding-3-small) 对 query 长度敏感：
- "chat-first product" → score 0.578 → ✅ hit
- "chat first product design" → score < 0.35 → ❌ miss
- "llm wiki karpathy" → score 0.547 → ✅ hit  
- "llm wiki karpathy document knowledge base" → score < 0.35 → ❌ miss

添加通用/模糊词（"design", "pool", "document knowledge base"）稀释了 embedding vector 的方向性。

## 为什么

Embedding 是整个 query 的加权平均。通用词把向量拉向更通用的区域，远离具体概念的 embedding。这在 minScore threshold 存在时特别致命 — 微小的 score 下降就可能从 hit 变 miss。

## 应对策略

1. **写 eval query 时模拟真实用法** — 用户实际搜索时用的是简短关键词，不是堆砌描述
2. **Query preprocessing**（upstream）— 去除 stop words / 提取核心概念后再 embed
3. **降低 minScore**（谨慎）— 会引入噪音
4. **Hybrid retrieval** — keyword matching 不受此影响，可以补偿

## 关联

- [[intent-aware-retrieval]] — 理解 query intent 比增加 query 词数更重要
- [[progressive-disclosure-memory]] — 分层检索可以在第一层用更宽松的 threshold

---
*Created: 2026-04-19 | Source: dreaming eval nDCG investigation*
