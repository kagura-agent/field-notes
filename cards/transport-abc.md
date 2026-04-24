# Transport ABC (Provider Abstraction Pattern)

Extracting format conversion and HTTP transport from a monolithic agent loop into pluggable transport implementations, each owning its own API shape.

## The Problem

As agent frameworks add more LLM providers, the main execution loop accumulates provider-specific branches. Hermes's `run_agent.py` reached 11,000+ lines with inline format conversions for 16+ providers. Adding a new provider means touching the core loop.

## The Pattern

Three responsibilities extracted per transport:
1. **build_kwargs** — construct provider-specific API parameters
2. **normalize** — convert provider response to shared `NormalizedResponse`
3. **validate** — verify configuration is valid

Shared types (`NormalizedResponse`, `ToolCall`, `Usage`) unify all provider outputs. A `provider_data` escape hatch preserves provider-specific info (Gemini's `thought_signature`, DeepSeek's `reasoning_content`) without polluting the shared interface.

## Implementation Strategy (Hermes v0.11.0)

9-PR chain, each independently testable:
1. Shared types + dataclasses
2. Migrate one provider (Anthropic) to prove the shape
3. Migrate remaining providers one at a time
4. Remove old code paths

Each PR has 46+ tests verifying output parity with the old code path. No big-bang rewrite.

## Relevance to OpenClaw

OpenClaw's provider abstraction is currently in the gateway layer (provider configs + routing). The transport-level abstraction is different — it's about how each provider's API is called and how responses are normalized. If OpenClaw ever needs multi-provider support at the agent level (not just routing), this pattern is the reference.

## Key Insight

The incremental migration strategy is more valuable than the abstraction itself. "Prove the shape with one provider, then migrate the rest" is applicable to any large refactor.

## Related

- [[hermes-agent]] — source project
- [[async-agent-transport]] — connection lifetime (different layer)
- [[agentic-stack]] — where transport sits in the stack
