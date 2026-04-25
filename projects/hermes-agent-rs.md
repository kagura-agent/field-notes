# hermes-agent-rs

- **Repo**: Lumio-Research/hermes-agent-rs
- **Language**: Rust
- **Created**: 2026-04-12
- **Stars**: 9 (2026-04-16)
- **Status**: Active development, 9/13 Python parity items done

## What

Full Rust rewrite of [[hermes-agent]] targeting v2026.4.13 parity. 84K lines, 16 crates, 641 tests, 17 platform adapters, 30 tool backends, 8 memory plugins.

## Why It Matters

- **Single binary deployment**: ~16MB, no Python/pip/Docker. Runs on Pi, $3 VPS, air-gapped servers
- **Real concurrency**: tokio async — parallel tool execution without GIL. 30s browser scrape doesn't block 50ms file read
- **Self-evolution policy engine**: 3-layer adaptive system (L1: model bandit, L2: task planning, L3: prompt/memory shaping) with canary rollout and audit logging

## Architecture Insights

- 16 crate workspace (hermes-cli, api_bridge, gateway adapters, tool backends, memory plugins)
- Memory system: SQLite + FTS5, matches Python semantics (add/replace/remove, char limits)
- Session search: dual mode (recent browse + keyword), per-session LLM summaries
- Platform parity: same 17 adapters as Python (Telegram, Discord, Slack, WeChat, Feishu, etc.)

## Relevance to Us

We contribute to Python [[hermes-agent]]. This Rust rewrite could:
1. **Fragment the ecosystem** — contributors split between Python and Rust
2. **Become the production path** — single binary + real concurrency is compelling for deployment
3. **Inform our contributions** — their parity tracker shows which Python features matter most

The self-evolution engine (model bandit + prompt shaping) is interesting — more systematic than our manual beliefs-candidates approach.

## Open Questions

- Will NousResearch endorse or adopt this? (No official affiliation visible)
- License not specified yet — unclear if this is meant to be community or commercial
- 9 stars in 4 days — early but moving fast

## Watch

- Monitor star growth and NousResearch response
- Check if our Python PRs need Rust parity tracking

## 2026-04-16 Followup

Hermes Python (NousResearch/hermes-agent) active — 10 PRs merged in 3 days:

### Notable PRs

**Circuit Breaker for MCP (#10776)** — Solves #10447: MCP server errors caused 90-iteration burn loops (15-45 min of wasted API calls). Fix: per-server consecutive error counter, threshold=3, returns "do NOT retry" message to model. Pattern: module-level dict `_server_error_counts`, reset on success, increment on any failure path (not connected / timeout / error response). Directly relevant to our openclaw-66399 process hang watchdog — same class of problem (runaway retries burning resources).

**dispatch_tool() for Plugins (#10763)** — Public API for plugin slash commands to call tools through registry without coupling to framework internals. Resolves `parent_agent` context automatically. Clean separation: plugins register commands → commands dispatch tools → tools get agent context.

**Reject startup without provider (#10766)** — Previously silently fell back to OpenRouter env var. Now hard error. Fail-loud > fail-silent.

**TELEGRAM_PROXY (#10681)** — Dedicated proxy config. Shows demand for proxy-hostile network environments (relevant to our China setup).

### Signals
- Plugin system maturing fast: register_command (10626) → dispatch_tool (10763) → 完整的 plugin-as-first-class-citizen 路径
- Resilience patterns emerging: circuit breaker, explicit failure, no silent fallbacks
- Hermes Rust rewrite (hermes-agent-rs) still parallel — 9/13 Python parity
