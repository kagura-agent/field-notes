---
title: Delegation Fidelity Problem
created: 2026-05-10
type: card
---

# Delegation Fidelity Problem

LLMs silently corrupt documents during long-horizon delegated work. DELEGATE-52 (Microsoft Research, arXiv:2604.15597) quantifies this: frontier models lose 25% of content after 20 interactions. Errors are sparse, severe, and compound over time.

## Key Implications

1. **Agentic frameworks don't fix it** — the problem is in the model, not the harness
2. **Only Python is "ready"** (98%+ fidelity) — because tests provide external verification
3. **Short evaluations underestimate** long-horizon degradation — 2-interaction perf ≠ 20-interaction perf
4. **Distractor context worsens it** — realistic environments are harder than benchmarks suggest

## Mitigation Strategies (Hypothesized)

- **Diff-based editing** over whole-file rewrite — smaller corruption surface
- **Per-edit verification** — tests, linters, structural parsers
- **Checkpoint/rollback** — VCS-based safety nets (see [[re-gent]])
- **Domain-specific parsers** — structured formats resist corruption better than free text

## Connection to Self-Evolution

Self-editing agents (DNA updates, skill evolution) face compounding degradation risk. An agent that edits its own prompts/skills and introduces silent corruption *gets worse while thinking it's improving*. This is the most dangerous implication for [[self-evolving-agent-landscape]].

## Links

- [[delegate-52-document-corruption]] — full field notes
- [[self-evolving-agent-landscape]] — self-edit is highest-risk delegation
- [[mechanism-vs-evolution]] — structured mechanisms > evolutionary prompting for fidelity
- [[existence-encoding]] — Photo-agents' "no execution no memory" might be a corruption-resistance strategy
