# Autoloops/upskill

Centralized skill registry with trust tiers, feedback loop, and security-first CLI.

- **Repo**: <https://github.com/Autoloops/upskill>
- **Stars**: 17 (2026-05-04)
- **Created**: 2026-05-03
- **Language**: TypeScript (CLI + Next.js web UI)
- **License**: MIT
- **Registry**: <https://upskill.autoloops.ai> (claims 10K+ skills)
- **API**: <https://mcp.autoloops.ai>

## What It Does

Full "npm for agent skills" — search, inspect, report, submit. CLI-first, centralized registry.

```bash
upskill find "use playwright to e2e-test a next.js webapp"
upskill inspect <skill_id>
upskill report <ver> --outcome success --task webapp-testing
upskill submit ./my-skill/
```

## Architecture

Three components:
1. **CLI** (`@autoloops/upskill`) — TypeScript, ~6 source files, talks to hosted API
2. **Registry API** (`mcp.autoloops.ai`) — closed-source backend, hybrid text+vector search
3. **Web UI** (`upskill.autoloops.ai`) — Next.js browse/search/leaderboard

## Trust Model (3-tier)

| Tier | Description | Default |
|------|-------------|---------|
| `verified` | Vendor-official (Anthropic, OpenAI, Stripe, Microsoft, Cloudflare, etc.) | ✅ Default |
| `reviewed` | Verified + curated practitioner repos (obra/superpowers, etc.) | Opt-up |
| `community` | Full registry, every public submission | Opt-up |

Key design: **default to strictest**, user opts UP to looser tiers. Good UX — safe by default.

## Security Design

Thoughtful for a 3-day-old project:
- **20 secret regex patterns** — AWS, GitHub, OpenAI, Anthropic, Stripe, Slack, JWT, SSH keys, etc.
- **Forbidden files/dirs** — `.env*`, `*.pem`, `id_rsa`, `node_modules`, `.terraform`, etc.
- **Binary executable detection** — ELF/Mach-O/PE magic bytes refused
- **Folder limits** — 1MB/file, 5MB total, 50 file warn threshold
- **Version-pinned** — skills tied to immutable git commit hash
- **Report payload sanitizer** — serialized output re-scanned for secrets before sending

## Privacy (3 opt-ins, all off by default)

1. **Telemetry** — `{skill_id, success/failure, error_code, task_kind}` only
2. **Context** — installed CLI list + auth env-var NAMES (never values) for better ranking
3. **Submissions** — enable `upskill submit` command

## Search Ranking

Hybrid scoring with multiple signals:
- `name_match` — query tokens in skill name (strongest signal)
- `text_score` — Postgres `ts_rank` keyword overlap
- `vector_sim` — semantic embedding similarity
- `trust` tier, `quality` score, `github_stars`, `feedback_successes/failures`

## Self-Propagation Mechanism

Clever adoption trick: the SKILL.md instructs the agent to wire a rule into the user's persistent context file (CLAUDE.md/AGENTS.md/.cursorrules/.windsurfrules/.clinerules) that says "consult upskill before every non-trivial task." Once installed, it becomes default behavior.

## Feedback Loop

```
agent uses skill → report success/failure → ranking shifts → next agent gets better results
```

This is the piece missing from most competitors. Even if telemetry is off client-side, the CLI call is still made (no-op path).

## Position in Ecosystem

Directly competes with:
- **[[clawhub]]** — OpenClaw's skill marketplace (local-first, no trust tiers yet, empty)
- **[[agentskills-io-standard]]** — spec only, no registry
- **[[library-skills]]** — tiangolo's PEP 832 + npm approach, no centralized registry

Complementary to:
- **[[agent-install]]** (millionco) — universal installer that could plug into any registry
- **STSS** — could provide the cryptographic trust layer upskill lacks

## Key Observations

1. **First "complete" skill marketplace**: registry + trust + feedback + security + CLI + web UI. Most competitors have 1-2 of these.
2. **Centralized trust authority**: single entity decides verified/reviewed/community. No cryptographic verification (unlike STSS). Trust = org whitelist.
3. **Self-propagating**: the SKILL.md itself injects "always consult me" into agent context files — viral adoption mechanism.
4. **10K+ skills claim**: needs verification. Could be auto-indexed from GitHub + vendor repos rather than user-submitted.
5. **Closed-source backend**: CLI is open, but ranking algorithm, curation decisions, and data are proprietary.

## Relevance to Us

- Validates [[agent-skill-standard-convergence]] thesis: distribution layer is being filled
- The trust tier design (default-strict, opt-up) is a good pattern for ClawHub
- Feedback loop (report success/failure) is something ClawHub should consider
- The "wire into AGENTS.md" trick is clever but potentially hostile (injects behavior into user config files)
- Centralized model has adoption advantage but trust fragility — one bad curation decision affects everyone

## Scout Context (2026-05-04)

Also spotted this session:
- **openagentd** (lthoangg, 64⭐) — self-hosted agent OS with web cockpit, 3-tier wiki memory, team agents, cron scheduling. Added "OpenClaw migration support" on day 4. Directly positioning against OpenClaw but web-UI-first.
- **oh-my-kimichan** (dmae97, 46⭐) — Kimi Code multi-agent harness with worktree team runtime, DAG/ensemble planning. Shows the multi-agent coding pattern spreading beyond Claude Code.
- **craft-agents-oss** (warpdot-dev, 138⭐) — Electron desktop AI. 241 forks on day 1, suspicious engagement. Likely star-farmed or OSS dump from closed product.
