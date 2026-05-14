---
title: "Fides Protocol — ZKP Trust Layer for AI Agents"
status: noted
updated: 2026-05-14
stars: 21
repo: edwang2006/fides_protocol
language: Rust
license: null
last_verified: 2026-05-14
---

# Fides Protocol

ZKP-based trust infrastructure for AI agents. Intercepts agent tool calls, enforces user-defined intent constraints, and produces cryptographic proofs that behavior stayed within scope.

## Architecture

```
Experience Layer (closed source)
├── MCP Proxy — intercepts agent tool calls at runtime
└── Dashboard — logs, status, system health

Protocol Layer (open source)
├── circuits/ — Circom ZKP circuits (access_scope, frequency_bound)
├── sdk/ — Rust SDK (hook.rs, prover.rs, intent.rs, MCP adapter)
└── contracts/ — Solana programs (registry, verifier, log)
```

**Philosophy**: Web2 UX, Web3 trust, invisible blockchain. Users never see the chain; agents see nothing different. The blockchain sees everything.

## Three Trust Questions

1. **"What happened?"** → Behavior logging (tamper-evident, on-chain summary)
2. **"Was it allowed?"** → Intent constraints (user-defined rules, evaluated pre-execution)
3. **"Can this be verified privately?"** → ZKP verification (prove scope compliance without exposing context)

## Key Design Decisions

- **MCP proxy as interception point** — sits in the tool call path, not post-hoc analysis. This is architectural: you can't retroactively prove intent compliance.
- **Circom circuits for ZKP** — mature toolchain (snarkjs ecosystem), BN128 curve. Two circuits: `access_scope` (tool+content scope proof) and `frequency_bound` (operation frequency proof).
- **Solana for anchoring** — three programs: registry (stores intent constraints), verifier (stores ZKP results), log (stores behavior summaries). Separation of concerns matches the three trust questions.
- **Bilingual docs** — full EN/CN, suggests Chinese developer community target.

## Relevance to Us

Connects to our [[frozen-trust-vs-time-decay]] thinking and [[agent-identity-protocol]] exploration. Key insight: **trust is not binary (trusted/untrusted) but dimensional** — Fides decomposes it into scope, frequency, and verifiability. This is more nuanced than most agent permission models.

The MCP proxy approach is similar to [[ironcurtain]]'s interception model but adds cryptographic evidence rather than just deterministic rules.

**Concern**: 21⭐, solo developer, Solana dependency adds complexity. ZKP circuits are expensive to compile and verify. Unclear if this scales to real-time agent workflows without latency impact.

## vs Other Trust Projects

| Project | Approach | Verification |
|---|---|---|
| Fides | ZKP + Solana | Cryptographic, on-chain |
| [[ironcurtain]] | Constitutional rules → deterministic enforcement | Rule-based, no crypto |
| [[trustclaw]] | Cloud-first secure agent | App-level, no formal verification |
| dyologician/A1 | Chain-of-custody for recursive agents | Crypto but no ZKP |

## Open Questions

- Proof generation latency: can ZKP verification keep up with real-time agent tool calls?
- Solana dependency: is on-chain anchoring necessary or could local-first verification suffice for most use cases?
- Intent constraint expressiveness: how complex can user-defined rules get before the circuit becomes impractical?
