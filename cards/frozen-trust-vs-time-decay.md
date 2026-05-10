---
title: Frozen Trust vs Time Decay
type: card
created: 2026-04-25
updated: 2026-05-10
status: active
---

# Frozen Trust vs Time Decay

Agent 信任模型的两种极端：

- **Frozen Trust**：一旦建立信任就永不衰减。问题：环境变化后信任可能失真
- **Time Decay**：信任随时间自然衰减，需要持续验证。问题：维护成本高

## 张力

现实中需要平衡：核心信任（如身份）应该 frozen，行为信任应该 decay。

## Empirical Evidence (2026-05)

**[[delegate52]]** (Microsoft Research, arXiv:2604.15597) provides hard data:
- Frontier models (Claude 4.6 Opus, GPT 5.4, Gemini 3.1 Pro) corrupt **~25% of document content** after 20 delegated editing interactions
- All 19 tested models average **~50% content loss**
- Degradation **compounds** — errors from early interactions accumulate, making long-horizon delegation fundamentally unreliable
- Python is the only domain where most models are "ready" (≥98% fidelity after 20 interactions)

This means **frozen trust in agent output is dangerous** — even the best models introduce "sparse but severe errors that silently corrupt documents." The compounding nature means short evaluations dramatically underestimate real-world degradation.

**Implication for agent architecture**: Every edit by an agent should be diff-verified. Trust in agent fidelity must decay with interaction length. Our `verify-claims.sh` approach is directionally correct but scope-limited.

## Design Principles

1. **Identity trust** (who the agent is) → can be frozen
2. **Capability trust** (can it do X correctly?) → must decay with interaction count, document size, domain novelty
3. **Output trust** (is this edit correct?) → never frozen, always verify

## Related

- [[delegate52]] — empirical evidence for delegation degradation
- [[photo-agents]] — "no execution, no memory" as mitigation
- [[agent-safety]]
- [[agent-identity-protocol]]
- [[beliefs-upgrade-mechanism]]
- [[skill-trust-landscape-2026-04]]
