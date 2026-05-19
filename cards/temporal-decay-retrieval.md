# Temporal Decay Retrieval

Retrieval strategy that weights results by recency — newer items score higher, older items fade unless reinforced by access or links.

## Core Idea

Not all stored knowledge ages equally. A decision made yesterday is more relevant than one made six months ago, unless the older one was accessed recently. Temporal decay applies a time-based discount to retrieval scores.

## Patterns

- **Exponential decay** — score × e^(-λt), half-life configurable per content type
- **Access refresh** — reading/citing a card resets its decay clock
- **Type-aware half-lives** — decisions persist longer than handoff notes (inspired by [[ClawMem]] pattern: decisions=∞, notes=60d, handoffs=30d)
- **Link anchoring** — cards with many inbound links decay slower (graph importance as proxy for durability)

## Tradeoffs

- Pure decay loses institutional knowledge — needs anchoring mechanisms
- Too aggressive = rediscovery loops; too gentle = noise accumulation
- Works best combined with [[auto-retire-pattern]] for explicit lifecycle management

## Related

[[auto-retire-pattern]], [[overlap-detection-pattern]], [[progressive-retrieval]], [[memory-complexity-pendulum]]
