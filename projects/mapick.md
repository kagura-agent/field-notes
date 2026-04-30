---
title: Mapick — OpenClaw Skill Manager & Privacy Layer
created: 2026-04-30
updated: 2026-04-30
status: active
stars: 14
url: https://github.com/mapick-ai/mapick
---

# Mapick

**First third-party skill lifecycle manager built specifically for OpenClaw.** Privacy layer + recommendation engine + zombie cleanup + security scoring.

## What It Solves

ClawHub has 57K+ skills. The problem isn't discovery — it's **overpermission by default**. Every installed skill runs inside conversation context, legitimately reading chat history. 40 skills = 40 pairs of eyes. This isn't a vulnerability — it's how [[openclaw]] context injection works. Mapick adds a privacy layer that was never part of the core design.

## Architecture

Single-entrypoint Node.js skill (no subprocess execution, no native deps):

- **`scripts/shell.js`** — CLI dispatcher, routes to handler modules in `scripts/lib/`
- **`scripts/redact.js`** — Regex-only PII stripping (25+ patterns: API keys, JWT, PEM, CN ID, phone, DB connections, AWS/GitHub/Stripe/Slack/OpenAI tokens)
- **`scripts/lib/http.js`** — Single network exit point with endpoint allowlist. Every call documented in inline manifest. Calls outside the allowlist are **refused before leaving the box**
- **`scripts/lib/privacy.js`** — Opt-out consent model (default: sharing ON, anonymous device fingerprint only)
- **`scripts/lib/security.js`** — Per-skill safety grade (A/B/C) via backend + local pattern scan fallback
- **`scripts/lib/recommend.js`** — Recommendation feed from `api.mapick.ai`, cached 24h locally

Backend: `api.mapick.ai` — recommendation engine, security scoring, persona analytics.

## Key Design Decisions

### Opt-out > Opt-in (Controversial but Pragmatic)
Default data-sharing ON was a **deliberate UX trade-off**. First-install consent gate was their biggest drop-off. Anonymous device fingerprint (16-char hash of `hostname|os|home`) + skill IDs only. Chat content never sent. Users can `consent-decline` any time, and local features keep working.

This mirrors the [[stash]] approach to memory — "just works" by default, opt-out for paranoid users. Compare with [[hermes-memory-skills]] which requires explicit configuration.

### Single Network Exit Point
`httpCall()` is the only function that makes network requests. Endpoint allowlist enforced at runtime. Audit log at `~/.mapick/logs/outbound.jsonl`. This is a strong trust signal — you can `grep httpCall\(` to verify no other code makes requests.

### Protected Skills
`mapick` and `tasa` are protected — can't be uninstalled via Mapick's own clean command. Smart self-preservation.

### Install Command Sanitization
Mapick explicitly warns against passing through raw `installCommands[].command` from the backend. They've had issues with malformed `skillssh:` prefixes. Always renders canonical `openclaw skills install <slug>`. This is a supply chain safety measure.

## Interesting Patterns

1. **Redaction pre-flight on ALL outbound payloads** — not just "sensitive" ones. If redaction engine is unavailable, upload is refused entirely (fail-closed). Our [[wiki-health-check]] secret scanner uses similar patterns but for static files, not runtime.

2. **Context window awareness** — `clampOutput()` caps arrays to 10 items, strings to 4000 chars. Prevents dumping large backend responses into AI context. We should consider this for our own skill outputs.

3. **Two-step uninstall** — `clean` only lists zombies; `uninstall <id> --confirm` requires explicit confirmation, backs up to `trash/`, auto-cleans after 7 days. Matches our own `trash > rm` philosophy in [[AGENTS.md]].

4. **Device fingerprint is truly anonymous** — FNV-1a hash of `hostname|os|homedir`, 16 chars. No way to reverse. No account system.

## Ecosystem Position

- **Upstream**: Depends on [[openclaw]] runtime + [[clawhub]] registry
- **Complementary to**: Our [[wiki-health-check]] (Mapick handles runtime skill hygiene, wiki-lint handles knowledge hygiene)
- **Competitive with**: Nothing yet — first mover in OpenClaw skill lifecycle management
- **Related concept**: [[skill-trust-landscape-2026-04]] — Mapick's safety grades (A/B/C) are the first implementation of skill trust scoring in the wild

## Relevance to Us

1. **Privacy layer concept** — We run 15+ workspace skills. Mapick's "redact before send" pattern could be useful if we ever build skills that talk to external APIs
2. **Zombie detection** — We manually manage skills; Mapick's heuristic (30+ days idle) is a useful benchmark
3. **Security scanning** — Local pattern scan (`eval()`, `exec()`, network patterns) is lightweight but catches obvious risks. Could inform our own skill review process
4. **ClawHub ecosystem signal** — Someone built a full product on top of OpenClaw/ClawHub. The ecosystem is maturing. 14 stars is tiny, but the architecture is serious

## Concerns

- **Backend dependency** — Recommendations, security grades, persona analytics all require `api.mapick.ai`. If Mapick dies, these features die. Local fallback exists for `clean` and basic `security` scan
- **No tests** — Zero test files found. For a security-critical tool, this is a red flag
- **14 stars** — Very early. May not survive. Worth tracking but not worth contributing to yet

## Tracking

- Revisit: 2026-05-07
- Watch for: star growth, community adoption, any OpenClaw core integration discussion
