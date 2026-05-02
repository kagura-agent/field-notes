# library-skills (tiangolo)

**Repo**: tiangolo/library-skills
**Stars**: 178 (2026-05-01 21:45, created 04-26, was 166 earlier today)
**Language**: Python + TypeScript (dual implementation)
**Status**: Active, pushed daily

## What It Does

CLI tool (`uvx library-skills` / `npx library-skills`) that **scans installed dependencies for embedded agent skills and symlinks them into the project's `.agents/skills/` directory**.

Core premise: **library authors ship their own skills inside the package itself** (e.g. `fastapi/.agents/skills/fastapi/SKILL.md`). When you install the library, the skill comes with it, version-locked.

## Architecture

### Scan → Select → Symlink

1. **Scanner** — walks `site-packages/*.dist-info/RECORD` (Python) or `node_modules/*/package.json` (Node) looking for `*/.agents/skills/*/SKILL.md` paths
2. **Installer** — creates symlinks from project `.agents/skills/<name>` → source in dependency. Supports `--copy` mode and `--claude` for `.claude/skills/` compat
3. **CLI** — interactive checkbox selection, `--all`, `--check` (CI drift detection), `list`, `scan`, `remove`

### Key Design Decisions

- **Symlinks over copies**: Default behavior. When you `pip install --upgrade fastapi`, the skill auto-updates because the symlink still points to the package dir. Zero maintenance.
- **Top-level deps only by default**: Only scans direct dependencies unless `--all` is passed. Prevents transitive dependency skills from cluttering.
- **Collision detection**: If two packages ship a skill with the same name, both are skipped with a warning. Simple but safe.
- **Editable installs supported**: Reads `direct_url.json` for `pip install -e` packages, walks the source tree.
- **SKILL.md validation**: Enforces [[agentskills-io-standard]] format — frontmatter with `name` (lowercase-hyphen, max 64 chars), `description` (max 1024 chars), name must match parent directory.

## Who's Adopted It

- **FastAPI** — ships `fastapi/.agents/skills/fastapi/SKILL.md` in the package itself (verified 05-01)
- The [[agentskills-io-standard]] is already adopted by Cursor, VS Code Copilot, Gemini CLI, OpenCode, and others as consumers

## What's Interesting

### 1. Supply-Side Skill Distribution
Previous [[claude-code-skill-ecosystem]] analysis showed skills as **user-authored** or **community-curated**. library-skills introduces a third model: **library-authored, package-distributed**. The library author writes the skill, ships it in the npm/PyPI package, and it stays in sync with the library version. This is the "batteries included" approach to skills.

### 2. Version Coherence Problem
One of the biggest issues with community skill repos (like alirezarezvani/claude-skills at 12.7K⭐) is staleness — skills written for v1 API don't work with v2. library-skills solves this by making the skill part of the package release. The skill for FastAPI 0.115 is different from 0.110 because it ships with each version.

### 3. Symlink as Distribution Mechanism
Instead of copying files, registry APIs, or marketplace downloads, library-skills uses the **existing package manager as the distribution channel** and **symlinks as the activation mechanism**. This is elegantly zero-infrastructure — no skill marketplace needed.

### 4. CI Drift Detection
`library-skills --check` exits non-zero if installed skills don't match discovered ones. This lets you add it to CI to ensure skill freshness. Treating skill setup as infrastructure-as-code.

## Relevance to OpenClaw / ClawHub

### Direct Comparison
- **library-skills**: Skills distributed via npm/PyPI, symlinked locally, tied to library versions
- **ClawHub**: Skills distributed via registry (clawhub install/publish), copied into workspace, version-independent

### Strategic Implications
1. library-skills solves a **different problem** than ClawHub — it's about libraries teaching agents to use them correctly, not about packaging agent capabilities
2. The two models are **complementary**: library-skills for "how to use FastAPI" skills, ClawHub for "how to do browser automation" skills
3. If [[agentskills-io-standard]] becomes dominant, ClawHub should ensure format compatibility (which it largely already has)
4. The `--check` CI pattern is worth stealing for ClawHub — `clawhub check` to verify skill freshness

### OpenClaw Skill Format Gap
OpenClaw skills use the same `SKILL.md` + frontmatter pattern but are loaded differently (system prompt injection at startup vs on-demand activation). The `.agents/skills/` directory convention is worth monitoring — if major IDEs standardize on this path, OpenClaw should support scanning it too.

## Related Notes

- [[agentskills-io-standard]] — the underlying format spec
- [[claude-code-skill-ecosystem]] — broader skill ecosystem analysis
- [[skill-ecosystem]] — three-layer differentiation model (format → distribution → activation)

## Followup 2026-05-02 13:50
- **Stars: 271** (was 178 on 05-01 — +52% in ~1 day, explosive growth)
- Released v0.0.5 (05-01): PEP 832 `.venv` redirect file support
- Released v0.0.4 (05-01): Fix `npx library-skills` 
- Active community PRs (#60 interactive picker UX, #61 copy-friendly commands)
- **Trajectory**: becoming the de facto library-embedded skill distribution tool. tiangolo (FastAPI creator) credibility + [[agentskills-io-standard]] alignment + zero-infrastructure design driving adoption
- **Signal**: this growth rate suggests skill-via-package-manager may become the dominant distribution pattern for library-specific skills, complementing marketplace models like [[clawhub]]
