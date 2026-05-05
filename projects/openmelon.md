# OpenMelon — Content-Creation Agent Runtime

- **Repo**: [eight-acres-lab/openmelon](https://github.com/eight-acres-lab/openmelon)
- **Stars**: 57 (2026-05-05)
- **Language**: Go
- **Created**: 2026-04-25
- **Companion**: [eight-acres-lab/skillplus](https://github.com/eight-acres-lab/skillplus) (42⭐) — compilable skill package standard

## What It Is

A **content-production runtime** — not a general agent framework. Its core abstraction is a production chain, not chat messages or generic tasks:

```
Project → Workflow → Stage → Compiled Skill → Artifact → Review → Provenance → Memory Update
```

Designed for reproducible multimodal content: social posts, images, copy, video shot lists. Each output (artifact) carries provenance — who made it, how, with what model, what skill, what prompt.

## Architecture Insights

### Compilable Skills (Skill-Plus)

This is the most distinctive design choice. Skills are YAML+Markdown packages that a **deterministic compiler** (never calls a model) transforms into target-specific formats:

- `openmelon` — structured JSON for the runtime engine
- `skill-md` — portable SKILL.md for Claude Code / Cursor / any agent
- `prompt-bundle` — vendor-specific prompt packages
- `eval` — evaluation checklists
- `provenance` — provenance templates

The compiler handles **target adaptation, locale, model profile, and variable injection** — separating skill authoring from skill consumption. This is a fundamentally different approach from [[library-skills]] (static packages) or [[agentskills-io-standard]] (format standard without compilation).

### Provenance as First-Class

Every artifact records:
- Workflow + stage that produced it
- Skill-Plus package + compiled target
- Model used
- Prompt hash (not the full prompt — privacy-aware)
- Generation parameters
- Evaluation result + feedback

Stored as append-only JSONL. This is closer to software supply-chain provenance (SLSA/Sigstore) than anything else in the agent skill space.

### Workflow Engine

Go implementation, stage-by-stage linear execution. Each stage:
1. Compiles the Skill-Plus package (subprocess call to Python compiler)
2. Optionally generates content via LLM/image model
3. Writes artifact with stable ID
4. Appends provenance record

Supports compile-only dry-runs (no model calls). Clean separation between compilation and generation.

## Relationship to Agent Ecosystem

- **vs [[library-skills]]**: library-skills is a static package format; skillplus adds a compilation step. Complementary — skillplus can output `skill-md` format, which is what library-skills standardizes
- **vs OpenClaw skills**: OpenClaw skills are runtime instructions (SKILL.md); skillplus skills are compiled artifacts. Different layers — could coexist (an OpenClaw skill could invoke skillplus compilation)
- **vs [[agentic-stack]]**: agentic-stack is a general agent framework; openmelon is domain-specific (content production). Different scope
- **Unique angle**: Provenance tracking is absent from all other skill systems we've studied

## Relevance to Our Direction

1. **Compilable skills** — the compilation model is worth studying. Our skills are static SKILL.md files. Could skill compilation improve reliability? (e.g., compile a skill for a specific model's strengths/weaknesses)
2. **Provenance** — we track nothing about how artifacts were produced. For [[kagura-story]] or any creative output, provenance would be valuable
3. **Content vertical focus** — validates that "agent runtime for X" (where X is a specific domain) is a viable product strategy, not just general-purpose frameworks

## Assessment

Small but well-architected. Go core with Python compiler subprocess is unusual but pragmatic. The compilable-skill model is genuinely novel in the agent ecosystem. Worth watching — if skill compilation proves valuable, this could influence how the broader ecosystem thinks about skills.

**Revisit**: 05-12 — check if growth accelerates
