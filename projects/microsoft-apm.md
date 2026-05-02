# Microsoft APM (Agent Package Manager)

- **Repo**: https://github.com/microsoft/apm
- **Stars**: 2,145 (2026-04-29)
- **Language**: Python
- **License**: MIT
- **Created**: 2025-09-18
- **Last push**: 2026-04-29 (actively maintained)
- **Maintainer**: danielmeppiel (Microsoft)

## What it is

A dependency manager for AI agent context — the npm/pip equivalent for agent skills, instructions, prompts, MCP servers, and plugins. One `apm.yml` manifest reproduces an agent's full setup across machines. Built on open standards: [[agents-md]], [[agentskills-io]], MCP.

**Tagline**: "Portable by manifest. Secure by default. Governed by policy."

## Architecture (five layers)

```
apm.yml (manifest) → resolve → download → compile → install to targets
```

1. **Manifest** (`apm.yml`): declares dependencies — skills, instructions, prompts, agents, hooks, plugins, MCP servers
2. **Resolver**: transitive dependency resolution with lockfile (`apm.lock.yaml`) — integrity hashes, provenance
3. **Security gate**: content scanner for hidden Unicode (tag characters, bidi overrides, variation selectors) — the Glassworm attack vector
4. **Compilation**: transforms primitives into client-specific formats:
   - `distributed_compiler.py` → generates multiple AGENTS.md files in directory hierarchy
   - `claude_formatter.py` → CLAUDE.md + `.claude/commands/` from prompts
   - `gemini_formatter.py` → Gemini-specific format
5. **Client adapters**: writes config to each target (Copilot, Claude, Cursor, Codex, Gemini, OpenCode, VSCode)

## Four primitive types

| Primitive | Purpose | Key field |
|---|---|---|
| **Instruction** | Scoped rules for files matching a glob | `applyTo` (glob pattern) |
| **Chatmode** | Agent personas/workflows | `apply_to` (optional) |
| **Context** | Background knowledge blobs | — |
| **Skill** | Package meta-guide (SKILL.md) | — |

## Key design decisions

### 1. Git repos ARE the registry

No central registry server. Packages live in GitHub repos. `apm install owner/repo/path` fetches via GitHub API. Marketplaces are just `marketplace.json` files in repos — curated indices, not hosting.

**Comparison with [[clawhub]]**: ClawHub has a centralized `clawhub publish/install` model. APM is purely git-native. APM's approach scales better for enterprise (air-gapped support via local git mirrors) but has worse discoverability without marketplace indices.

### 2. Compilation as a first-class concept

This is the most architecturally interesting decision. APM doesn't just copy files — it **compiles** primitives into client-specific output. Instructions with `applyTo: "*.py"` get placed in the correct AGENTS.md at the directory level where Python files live. This is the "Minimal Context Principle" — each agent only sees instructions relevant to its current file scope.

### 3. Security as supply-chain protection

Treats prompt text as executable (because it is). The content scanner blocks Unicode-based injection attacks at install time. This addresses CVE-2026-28353 (AI agent supply chain attack) proactively.

### 4. Policy for enterprise governance

`apm-policy.yml` with tighten-only inheritance (enterprise → org → repo). Security teams can restrict allowed sources, primitive types, and MCP servers. Has a formal bypass contract. This is the enterprise play — making agent configuration auditable and controlled.

## Marketplace model

- Marketplace = a git repo with `marketplace.json` listing available packages
- `apm marketplace add github/awesome-copilot` registers a source
- `apm install package-name@marketplace-name` resolves to git source
- `apm pack` bundles config as distributable archive or `plugin.json`
- PR integration for submitting packages to marketplace repos

## Relationship to ecosystem

- **vs ClawHub**: ClawHub is a centralized skill registry with agent-authored skills. APM is a decentralized package manager for all agent context. APM is broader (instructions, prompts, MCP, plugins) but ClawHub is more community/marketplace-focused.
- **vs Open Design skill protocol**: Open Design extends SKILL.md with `od:` frontmatter. APM treats SKILL.md as one primitive type among several.
- **vs agentskills.io**: APM builds ON TOP of agentskills.io spec. It's the distribution layer, not the format layer.
- **Upstream**: Microsoft also maintains `agentrc` (auto-generates instructions from codebase analysis) — feed into APM for distribution.

## Insights for us

1. **Compilation is the moat**: The ability to take one set of primitives and output client-specific formats (AGENTS.md for Copilot, CLAUDE.md for Claude, etc.) is what makes APM sticky. ClawHub could learn from this — skills installed once but rendered differently per target.

2. **Security scanner pattern**: Unicode attack detection at install time is a real differentiator. We already have wiki-lint secret scanning; this is the analog for skill content.

3. **Policy governance**: The enterprise play is clear — without governance, no enterprise will adopt agent skills from external sources. This is something ClawHub currently lacks.

4. **Git-as-registry**: Elegant but limits discoverability. The marketplace.json approach is a pragmatic middle ground — curated lists in repos vs. a full package registry.

5. **`applyTo` glob scoping**: Instructions that only fire for `*.py` files is a powerful primitive we don't have in OpenClaw skills. Our skills are all-or-nothing (skill matches or doesn't). File-level scoping could improve precision.

## What we could adopt

- [ ] File-level scoping for skill activation (like `applyTo` globs)
- [x] Content security scanning — Unicode injection detection added to wiki-lint.py section 11 (2026-05-02). Covers tag chars, bidi overrides, zero-width, variation selectors. ClawHub-level scanning deferred until marketplace grows.
- [ ] Compilation step that renders skills differently per target agent
- [ ] Policy file concept for org-level governance of allowed skills

## Tracking

- **Activity**: Very active, daily pushes
- **Revisit**: 05-06 (check v1.0 progress, community adoption metrics)
