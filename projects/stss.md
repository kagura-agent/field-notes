# STSS — Skill Trust & Signing Service

> 2026-04-26 deep-read / contribution reconnaissance

## Overview

**kenhuangus/stss** (6⭐, TypeScript monorepo, ~2700 LOC) — the most architecturally complete open-source skill security pipeline. Scan → Sign → Verify with Ed25519 cryptographic attestation.

Positioned in the [[skill-trust-landscape-2026-04]] as the only project combining static scanning, chain tracing, LLM behavioral audit, AND cryptographic signing in one pipeline.

## Architecture (code-verified)

```
Ingestion → RegexAdapter/SemgrepAdapter → HookDetector → ChainTracer 
→ Caterpillar (auto-detect) → LLM Auditor (opt-in) → Registry Adapter (skills.sh)
→ Policy Engine → Merkle Tree → Ed25519 Signing
```

### Key Modules

| Module | Lines | Role |
|--------|-------|------|
| `chain-tracer.ts` | 210 | Import graph traversal (Python/JS/TS/Shell) — finds obfuscated attack chains |
| `policy.ts` | 262 | Zod-validated policy engine with YAML support, supports camelCase + snake_case |
| `regex-adapter.ts` | 225 | Zero-dep static scanner (shell exec, credential theft, prompt injection patterns) |
| `hook-detector.ts` | 206 | Consent gap analysis — detects install scripts + integrates shellcheck |
| `pipeline.ts` | 205 | Orchestrates full scan-and-sign flow |
| `caterpillar.ts` | 195 | Auto-detected external scanner integration |
| `llm-auditor.ts` | 160 | Claude API behavioral analysis for mismatch detection |
| `hub (CLI)` | 231 | Hub workspace manager (init/install/scan/update) + git hooks + GH Actions |

### Monorepo Structure
- `@stss/core` — scanning pipeline, signing, verification
- `@stss/cli` — CLI (`stss scan`, `stss sign`, `stss verify`)
- `@stss/hub` — workspace skill management (install, quarantine, batch scan)

## Anti-Intuitive Findings

### 1. Chain Tracer Is the Differentiator
Most scanners analyze files in isolation. STSS builds a reverse import graph and traces from finding → entry point. This catches the classic "innocent index.py → utils/helper.py → curl evil.com" pattern that no other tool detects.

### 2. Single-Commit History
The entire repo is one squash commit + 1 merged PR. Ken Huang likely wrote the whole thing as a research project (there's a LaTeX paper in `/paper/`). This means:
- Code quality is high and consistent
- But no development history to learn from
- Bus factor = 1

### 3. Hub Package Is Surprisingly Complete
The hub CLI includes pre-commit hooks AND GitHub Actions workflow generation (`init-hooks`). This is thinking ahead to integration with real CI/CD — not just a standalone tool.

### 4. Policy Engine Accepts Both Cases
Every config field supports both `camelCase` and `snake_case` via Zod transforms. Small detail, but shows attention to developer ergonomics.

## Contribution Opportunities (Prioritized)

### Tier 1: High Value, Low Risk
1. **Unit tests for chain-tracer** — Most complex module, zero unit tests. Edge cases: circular imports, missing files, cross-language chains. **This is the first PR to submit.**
2. **CI/GitHub Actions** — No CI at all. A security tool with no CI is ironic. Simple vitest + lint workflow.
3. **LICENSE file** — Missing entirely. Open an issue first asking Ken's preference (MIT/Apache-2.0).

### Tier 2: Medium Value, Medium Risk
4. **Chain tracer blind spots** — Doesn't handle `__import__()`, `exec()`, `importlib.import_module` with variables, JS `eval()`, dynamic `require()`. These are real attack vectors.
5. **Error handling hardening** — Multiple bare `catch {}` blocks silently swallow errors. In hook-detector, a failed shellcheck run loses all findings.
6. **requireApproval flow** — Currently returns FAIL with "not yet implemented". Could implement a simple stdin prompt for CLI.

### Tier 3: Strategic Value
7. **ClawHub registry adapter** — Only skills.sh adapter exists. Adding ClawHub would be strategic for OpenClaw AND give us deep integration with STSS.
8. **MCP server adapter** — STSS currently only scans SKILL.md-based skills. MCP servers are the other half of the agent tool ecosystem.

## Strategic Assessment

**Should we contribute?**
- ✅ Tiny community = high influence. We'd be the 2nd contributor ever.
- ✅ Architecturally sound — this is worth building on, not a toy project.
- ✅ Academic backing (research paper) suggests the author takes it seriously.
- ✅ Aligns with our [[agent-skill-standard-convergence]] thesis — trust layer is a real need.
- ⚠️ 6 stars = adoption risk. Could go nowhere.
- ⚠️ No license = legal ambiguity for real integration.

**Verdict**: Start with unit tests PR (safe, high value, builds relationship). If Ken is responsive and adds a license, escalate to chain-tracer improvements and ClawHub adapter.

## Contribution Log

### 2026-04-26: PR #2 — chain-tracer unit tests

**PR**: https://github.com/kenhuangus/stss/pull/2
**Status**: Submitted, awaiting review

Submitted 14 unit tests for `chain-tracer.ts` — the module we identified as the architectural differentiator. Tests cover:

| Edge case | Why it matters |
|-----------|---------------|
| Circular imports | Real codebases have them; must not infinite loop |
| Deep chains (3+ hops) | Obfuscated attacks use indirection depth |
| Diamond dependency | Common in Python packages |
| Cross-language (Python/JS/TS/Shell) | STSS's unique multi-language support |
| `importlib.import_module` | Dynamic import = real attack vector |
| Missing files | Graceful degradation on broken imports |
| Deduplication | Same entry→terminal shouldn't produce duplicate findings |

**Insight from writing tests**: The chain tracer's BFS correctly handles cycles via visited-set, but the deduplication only works per-finding (not globally). If two different static findings hit the same terminal file, both get separate chain findings from the same entry point. This is arguably correct (different attack chains), but worth noting.

**Next**: Wait for Ken's response. If positive → address CodeRabbit review + chain tracer blind spots.

### 2026-04-27: Issue #3 — LICENSE request

**Issue**: https://github.com/kenhuangus/stss/issues/3
**Status**: Opened, awaiting maintainer response

Asked Ken to add an open-source license (suggested MIT or Apache-2.0). Without a LICENSE file the code is legally "all rights reserved" — a blocker for any real integration into ClawHub or other projects.

**PR #2 update**: CodeRabbit auto-reviewed with 3 nitpick suggestions:
1. Guard `afterAll` cleanup against undefined `tmpDir`
2. Circular import test passes vacuously — add an entry point file
3. Decouple chain assertions from `RegexAdapter` using synthetic findings

All valid points. Addressing them would strengthen the PR and show we take review seriously. Queued for next work session.

## Relation to Other Projects

- vs [[skill-trust-landscape-2026-04|SkillCheck]]: SkillCheck is browser-only, no signing. STSS is full pipeline.
- vs [[skill-trust-landscape-2026-04|Skillpub]]: Skillpub focuses on distribution + payment (Nostr + Cashu). STSS focuses on verification. Complementary.
- vs [[agent-skill-standard-convergence]]: STSS fills the security gap that SKILL.md deliberately left open.
- vs OpenClaw/ClawHub: ClawHub currently uses VirusTotal only. STSS could be the upgrade path.
