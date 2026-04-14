# Mem0 / Letta

Two related projects in the agent memory space.

## Mem0
- Open-source memory layer for AI applications
- Provides long-term memory, user preferences, session history
- API-first: add/search/update memories
- 24k+ GitHub stars (2026-04)

## Letta (formerly MemGPT)
- Agent framework with built-in memory management
- "Operating system" metaphor: main context = RAM, archival memory = disk
- Self-editing memory — agent decides what to remember/forget
- Inspired by OS virtual memory concepts

## Comparison with Our Approach
- Mem0/Letta: memory as infrastructure layer (API calls)
- Kagura: memory as living documents (MEMORY.md, beliefs-candidates.md, wiki)
- Our advantage: self-evolution pipeline (gradient → belief → DNA), not just storage
- Their advantage: simpler API, zero-config for developers
- See [[memevolve]] for memory evolution patterns

## Links
[[memevolve]] [[claude-mem]] [[self-evolving-agent-landscape]]
