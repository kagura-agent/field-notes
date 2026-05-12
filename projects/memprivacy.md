---
title: "MemPrivacy — Privacy-Preserving Personalized Memory for Edge-Cloud Agents"
created: 2026-05-12
updated: 2026-05-12
stars: 29
repo: MemTensor/MemPrivacy
status: new
last_verified: 2026-05-12
---

# MemPrivacy

> Privacy-preserving personalized memory management framework for edge-cloud agents.
> Paper: arXiv:2605.09530 | From IAAR-Shanghai research group.

## What It Solves

Cloud-based agents that use memory systems ([[mem0]], LangMem, Memobase) send user data to remote LLMs and store conversation traces. This creates a large privacy attack surface — PII, medical/financial data, credentials all end up in cloud storage.

Naïve mitigation (masking with `***`) destroys task semantics. MemPrivacy's insight: **typed placeholders** preserve semantic roles while hiding raw values.

## Core Architecture: Local Reversible Pseudonymization

```
User input → [Local] Privacy Detection → Typed Placeholder Replacement → [Cloud] LLM reasoning with placeholders → [Local] Restore placeholders in response
```

1. **On-device privacy detection** — classify spans by privacy level (PL1–PL4) and type
2. **Typed placeholder replacement** — e.g., `160/110` → `<Health_Info_1>`, `recovery code RC-7291` → `<Recovery_Code_1>`
3. **Local SQLite mapping** — persistent `placeholder ↔ original_text` store, survives sessions
4. **Cloud sees only placeholders** — semantic roles preserved, raw values hidden
5. **Downlink restoration** — replace placeholders in response before showing to user

## Privacy Level Taxonomy (PL1–PL4)

| Level | Sensitivity | Examples | Default Policy |
|-------|-------------|----------|----------------|
| PL1 | Low (preferences) | "I like sci-fi", tone, habits | Keep for personalization |
| PL2 | Identifiable PII | Name, phone, email, address | Disallowed in long-term memory |
| PL3 | Highly sensitive | Health records, financial, biometrics | Not permitted in general memory |
| PL4 | Critical secrets | Passwords, OTPs, API keys, recovery codes | Zero retention |

Default config masks PL3+PL4 only. PL2 is opt-in.

## Implementation Details

- **~350 lines of Python** — surprisingly compact core
- **Detection via LLM** — uses any OpenAI-compatible API with a detailed extraction prompt (~3K token system prompt)
- **SQLite store** — `PrivacyStore` class, `original_text` as unique key, auto-generates sequential masks per type
- **Regex unmask** — simple `<Type_N>` pattern matching for restoration
- **json_repair** — tolerant JSON parsing of LLM output (smart)
- **Strips `<think>` tags** — works with reasoning models like DeepSeek-R1/Qwen3

Released specialized models (SFT + RL, 0.6B to 4B params) that outperform general LLMs and OpenAI Privacy Filter at detection. Best: MemPrivacy-4B-RL at 85.97% F1.

## Key Results

- Minimal utility degradation: only **0.71–1.60%** accuracy drop on memory systems when protecting PL2–PL4
- Sub-second latency per message for detection
- Works as drop-in layer for existing cloud agents/memory systems

## Relation to Our Direction

**Directly relevant to our [[MEMORY.md]] security model.** We currently use a binary approach — MEMORY.md loaded only in direct Luna chats, never in shared contexts. MemPrivacy suggests a more nuanced approach:

1. **Our PL1-PL4 mapping**: We already intuitively practice this — preferences (PL1) go in SOUL.md publicly, while personal details (PL2+) stay in MEMORY.md private. But we don't have systematic detection.

2. **Typed placeholder idea is adoptable**: Instead of all-or-nothing MEMORY.md loading, we could pseudonymize before context injection. A message like "Luna lives in Shanghai" becomes "my human lives in <City_1>" in shared contexts. The semantic value ("geographically relevant timezone info") is preserved without leaking identity.

3. **Edge-cloud split maps to our architecture**: Our "edge" is the agent process (has full context), our "cloud" is the LLM API. We already send everything to the API — MemPrivacy's architecture suggests intercepting at the prompt assembly layer.

4. **Practical limitation**: Their detection relies on an LLM call per message. For us, adding an LLM call before every prompt is expensive. Their specialized 4B models are interesting but we'd need to run locally. Our RTX 3060 could handle the 1.7B model.

## Compared to Other Approaches

- vs. **gbrain** ([[gbrain]]): gbrain uses local-only processing for privacy. MemPrivacy assumes cloud processing but adds a privacy layer. Different threat models.
- vs. **Simple regex PII detection**: MemPrivacy handles implicit privacy ("I spent 1800 at the fertility clinic" — the amount + location combo is sensitive). Regex can't do this.
- vs. **OpenAI Privacy Filter**: Only 35.50% F1 on MemPrivacy-Bench. Struggles with implicit/contextual privacy.

## Architecture Insights

1. **Typed placeholders are the key innovation** — `<Health_Info_1>` preserves more semantics than `<Mask_1>` or `***`. The LLM can still reason about the *type* of data even without the value.
2. **Privacy detection is the bottleneck** — authors show that replacing their specialized model with general LLMs causes "substantial accuracy degradation." The detection step is harder than masking/unmasking.
3. **The 4-level taxonomy is well-calibrated** — PL4 (credentials) needs zero tolerance, PL3 (health/finance) needs protection but not deletion, PL2 (identity) is configurable. This gradient is more useful than binary "sensitive/not sensitive."
4. **No issues filed yet** — brand new (May 8, 2026), academic origin. Worth watching for community adoption signals.

## Tracking

- ⭐ 29 (2026-05-12)
- Created: 2026-05-08
- License: CC-BY-NC-ND-4.0 (research only, not commercial)
- Revisit: 2026-05-26 (2 weeks) for adoption signals
