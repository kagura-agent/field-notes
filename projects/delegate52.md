---
title: "DELEGATE-52: LLMs Corrupt Your Documents When You Delegate"
created: 2026-05-10
source: https://arxiv.org/abs/2604.15597
repo: https://github.com/microsoft/delegate52
stars: 68
status: reference
tags: [agent-trust, delegation, benchmark, document-corruption, long-horizon]
---

# DELEGATE-52

> "Even frontier models corrupt an average of 25% of document content by the end of long workflows."

Microsoft Research paper (Philippe Laban, Tobias Schnabel, Jennifer Neville). April 2026.

## What It Does

A benchmark with **310 work environments across 52 professional domains** (coding, crystallography, genealogy, music notation, etc.) to test whether LLMs can reliably edit documents in long delegated workflows.

## Methodology — Round-Trip Relay

Clever evaluation trick: no reference solutions needed.

1. Define reversible editing tasks (forward instruction + inverse)
2. Apply forward then backward → should recover original document exactly
3. Measure `sim(original, recovered)` using domain-specific similarity
4. Chain multiple round-trips into a "relay" to simulate long interaction

This is backtranslation repurposed for long-horizon evaluation.

## Key Findings

| Finding | Detail |
|---|---|
| Frontier corruption rate | ~25% content loss after 20 interactions (Claude 4.6 Opus, GPT 5.4, Gemini 3.1 Pro) |
| Average across all 19 models | ~50% content loss |
| Only "ready" domain | Python (≥98% score after 20 interactions) |
| Domain dependence | Programmatic domains (Python, Database) > Natural language > Niche (music notation, earning statements) |
| Agentic tool use | Does NOT improve performance |
| Compound degradation | Short benchmarks underestimate severity — errors compound over time |
| 2-interaction ≠ 20-interaction | Early performance is NOT predictive of long-horizon |

## Why This Matters — Connection to Our Direction

### 1. Hard Validation of "Agent Trust" Concern

We've been tracking the "agent trust problem" as a gap in the ecosystem (see [[frozen-trust-vs-time-decay]], [[skill-trust-landscape-2026-04]]). This paper provides the first rigorous, multi-domain quantification. It's not just "agents sometimes make mistakes" — it's **systematic, compounding degradation** that gets worse the longer you delegate.

### 2. Implications for Agent Architecture

- **Memory systems matter more than we thought**: If documents degrade, the agent's memory of what the document _should_ look like becomes critical. This validates [[photo-agents]]'s "no execution, no memory" principle.
- **Verification loops are essential**: The 25% corruption rate means agent harnesses MUST include diff-verification after every edit. Our `verify-claims.sh` approach is on the right track.
- **Short evals are misleading**: Any agent harness that evaluates on 2-3 interactions is measuring the wrong thing. Long-horizon testing is fundamentally different.

### 3. Agentic Tool Use Doesn't Help

This is surprising and important. Adding tools (file read/write, code execution) to the LLM doesn't reduce corruption. The degradation is in the model's document understanding, not in its access to the document.

### 4. Python Exception

Python is the only domain where models achieve ≥98%. This likely explains why "vibe coding" seems to work — people's primary experience is with the one domain that's actually ready. Selection bias in the industry narrative.

## Tradeoffs / Limitations

- Backtranslation only tests fidelity, not creative/generative quality
- 20 interactions may or may not match real-world workflow length
- The benchmark uses single-turn sessions for each edit — real agents have context from prior edits
- Does not test whether chain-of-thought / reasoning models perform differently

## Related

- [[frozen-trust-vs-time-decay]] — our concept about trust degradation over time
- [[photo-agents]] — "no execution, no memory" principle as a potential mitigation
- [[skill-trust-landscape-2026-04]] — ecosystem trust landscape

## Scout Context (2026-05-10)

Found via HN front page (376pts). The companion repo (microsoft/delegate52, 68⭐) contains the benchmark code and environments. Paper published April 17, 2026.

**Ecosystem signal**: "delegation" is becoming a recognized interaction paradigm distinct from chat. The industry is starting to measure whether it actually works — and the answer is "not yet, except for code."
