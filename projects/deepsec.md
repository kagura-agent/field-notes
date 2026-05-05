# deepsec (vercel-labs/deepsec)

> Agent-powered vulnerability scanner for large codebases

- **URL**: https://github.com/vercel-labs/deepsec
- **Stars**: 349 (2026-05-05, created 2026-04-30)
- **License**: Apache-2.0
- **Language**: TypeScript (pnpm monorepo)
- **Org**: Vercel Labs

## What It Does

Security scanner that uses coding agents (Claude/Codex) to find hard-to-detect vulnerabilities. The key insight: regex matchers cast a wide net cheaply (free), then AI agents do expensive deep investigation only on flagged files.

Pipeline: `scan → process → revalidate → triage → enrich → export`

Each stage is idempotent, additive, and can be run independently. Re-running merges new info rather than overwriting.

## Architecture

```
scan (regex matchers, free, ~15s/2k files)
  ↓ candidates
process (AI agents, $$$, claude-opus-4-7 or gpt-5.5)
  ↓ findings
revalidate (AI re-check, cuts FP by 50%+)
  ↓ verdicts (true-positive/false-positive/fixed/uncertain)
triage (lighter model, P0/P1/P2 classification)
  ↓ enriched
export (JSON/markdown per finding)
```

### Key Design Decisions

1. **Regex-first, AI-second**: 111 matchers in ~6800 lines do the cheap filtering. AI only sees pre-screened candidates. This makes the cost manageable even for huge repos.
2. **File-as-source-of-truth**: Each `FileRecord` JSON accumulates all knowledge about a file. Additive merge model — nothing overwritten.
3. **Multi-agent**: Same prompt schema, different backends (Claude Agent SDK / Codex SDK). Can mix backends within a project.
4. **Distributed**: Fan out to [[vercel-sandbox]] microVMs for monorepos. Atomic file locking via `lockedByRunId`.
5. **Designed for cost**: "scans can cost thousands or even tens-of-thousands of dollars" — positioned as a premium tool for enterprises who care about security ROI.

### Agent Integration

Uses `@anthropic-ai/claude-agent-sdk` `query()` with:
- `permissionMode: "dontAsk"` (no human approval needed)
- `maxTurns: 150` (deep investigation)
- `thinking: { type: "adaptive" }` for revalidation
- Backoff + retry for transient errors
- Refusal detection + follow-up prompts

## Interesting Matchers (Agent-Specific)

These are novel — targeting AI/agent code specifically:

| Matcher | What It Catches |
|---|---|
| `agentic-untrusted-prompt-input` | Prompts interpolating external data (CRM notes, scraped HTML, KB docs) without injection boundaries |
| `mcp-tool-handler` | MCP tool registrations without per-tool auth/input validation |
| `agent-loop-no-cap` | Agent loops without turn/iteration limits |
| `agent-tool-definition` | Tool definitions with overly broad permissions |

Also covers modern frameworks: Next.js server actions, drizzle ORM, tRPC, ConnectRPC, Terraform IaC, Kubernetes, Lua/OpenResty.

## Plugin System

- `MatcherPlugin` — custom regex matchers with noise tiers (precise/normal/noisy)
- `OwnershipProvider` — who owns this file (CODEOWNERS, org chart)
- `PeopleProvider` — look up people by email/name
- Notifier plugins for reporting

## Relevance to Us

### Direct
- **Could scan OpenClaw and our tools** for security issues
- The **MCP matcher** is specifically relevant — we expose MCP tools
- The **agentic-untrusted-prompt-input** matcher catches prompt injection in agent code

### Architectural Lessons
- **Regex + AI pipeline** is a powerful pattern: cheap filtering → expensive investigation. Applicable beyond security (code review, documentation generation, etc.)
- **Additive merge model** for incremental analysis — same pattern [[flowforge]] uses for workflow state
- **Idempotent stages** — interrupt and resume without data loss. Good model for any batch AI processing.

### Contribution Opportunity
- 349⭐, Apache-2.0, 5 days old, actively developed
- Matcher contributions are low-risk, well-defined units of work
- Could write matchers for patterns we know (e.g., OpenClaw-specific security patterns)

## Ecosystem Position

New category: **agent-powered security testing**. Competitors:
- Traditional SAST (Semgrep, CodeQL) — rule-based, no AI investigation
- GitHub Copilot security suggestions — inline, not batch analysis
- Snyk Code — AI-assisted but not agent-powered

deepsec sits between "automated scanner" and "manual pentest" — using agents to approximate expert-level code review at scale.

## Signals

- Vercel Labs backing = credible, well-resourced
- $$$-grade positioning = enterprise play, not community tool
- 111 matchers in first week = serious engineering investment (not a weekend project)
- Claude Agent SDK integration = first major non-Anthropic project using this SDK publicly

## Tracking

- **Revisit**: 2026-05-12
- **Watch for**: Community matcher contributions, integration with CI/CD, pricing model
