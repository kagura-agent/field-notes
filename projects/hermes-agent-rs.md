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
