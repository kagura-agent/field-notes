# shutup-mcp

- **Repo**: hjs-spec/shutup-mcp
- **Language**: Python
- **Stars**: 5 (2026-04-16)
- **Status**: Early

## What

MCP proxy that does semantic tool filtering. Sits between agent and all MCP servers, reads intent, returns only 3-5 relevant tools. Agent never sees the other 79,997.

## How

1. Reads `claude_desktop_config.json`, connects to all MCP servers
2. Aggregates tool lists, builds embedding index (sentence-transformers or Ollama)
3. Intercepts `tools/list` calls, returns top-K by semantic similarity to intent
4. Watches config file, auto-refreshes on change

## Claims

- Token usage: **-98%**
- Response time: **-85%**
- Tool selection accuracy: **+2x** (vs Anthropic's 34% baseline with many tools)

## Relevance to Us

Directly relevant to our [[context-budget]] work:
- We're doing token reduction at the skill/workspace level (Tier A+B saved 17.6%)
- shutup-mcp does it at the MCP tool layer — complementary approach
- Pattern: **intent-aware gating** — filter what the model sees based on what it needs

The embedding-based approach is simple but effective. Could inspire similar filtering for our skill injection (currently all matching skills get injected).

## Architecture Pattern

**Proxy-layer context reduction**: don't change the tools, don't change the agent — just filter what connects them. Zero-config, works with existing setups.
