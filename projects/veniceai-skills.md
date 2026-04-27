# veniceai/skills — API-as-Skill Pattern

- **Repo**: https://github.com/veniceai/skills
- **Stars**: 33 (2026-04-27, created 04-21)
- **Category**: Agent skill ecosystem / API documentation
- **First seen**: 2026-04-27 quick scan

## What it is

Venice.ai's official agent skills repo — one SKILL.md per API surface area (chat, images, audio, video, billing, crypto). Skills are loaded on-demand by agents to correctly call Venice endpoints.

## Key Architecture

### Documentation-as-Skill pattern
Unlike [[skill-ecosystem]] where skills are behavioral ("how to automate X"), Venice skills are **informational** ("here's the API reference for X, formatted for agent consumption"). Each skill is essentially structured API docs with:
- YAML frontmatter (name + description for skill selection)
- Endpoint tables, parameter specs, curl examples
- Error matrices and gotchas
- Cross-links to related skills

### Multi-runtime plugin configs
Ships `.cursor-plugin/`, `.claude-plugin/`, `.codex-plugin/` — each a `plugin.json` pointing to the same `./skills` directory. Three different schemas for three runtimes, same content. This is the **portability tax** of the current ecosystem.

### Swagger-to-Skill sync pipeline
`scripts/sync_from_swagger.py` diffs the OpenAPI spec against SKILL.md content:
1. Finds endpoints in spec not referenced in any skill
2. Finds skill references to endpoints that no longer exist
3. Tracks enum drift (model types, etc.)
4. Exit code 1 on drift → CI auto-files issues

This is **spec-driven skill maintenance** — skills stay in sync with the actual API automatically.

### skills.json manifest
Central registry: `{ skills: [{ id, path }] }`. Similar to ClawHub's `clawhub.json` but simpler (no dependencies, no versioning).

## Comparison with OpenClaw/ClawHub

| Aspect | veniceai/skills | OpenClaw skills | [[vercel-skills]] |
|--------|----------------|-----------------|-------------------|
| Skill type | Informational (API ref) | Behavioral (how-to) | Mixed |
| Generation | Semi-auto (swagger sync) | Hand-crafted | Hand-crafted |
| Format | SKILL.md + YAML frontmatter | SKILL.md + YAML frontmatter | SKILL.md |
| Multi-runtime | ✅ (3 plugin configs) | ❌ (OpenClaw only) | ✅ (41+ agents) |
| Registry | skills.json + GitHub | clawhub.com | GitHub repos |
| Template | ✅ template/SKILL.md | ❌ | ❌ |

## Insights

1. **Convergence signal**: Three different approaches (Venice, Vercel, OpenClaw) all converging on SKILL.md as the unit of agent knowledge. The format is becoming a de facto standard.

2. **API-docs-as-skills is a new category**: Previously, skills = automation instructions. Venice shows skills can also be structured API references. This makes sense — agents need to know how to call APIs, and SKILL.md is a better format for that than raw OpenAPI YAML.

3. **Swagger sync is clever**: Auto-detecting drift between API spec and skill content is something ClawHub could adopt. Imagine: skill authors define which API they cover, CI checks if the API changed since last skill update.

4. **Multi-runtime plugin tax**: Venice ships 3 different plugin.json files with slightly different schemas. This is a real pain point the ecosystem hasn't solved. [[vercel-skills]] solves it by targeting 41+ agents from one install — but that requires agents to adopt vercel's format.

5. **Template-driven quality**: Their `template/SKILL.md` enforces a consistent structure. ClawHub skills vary wildly in structure because there's no template.

## Relevance to us

- **ClawHub template**: We should create a `clawhub init` template similar to Venice's — enforces structure, reduces variance
- **API skill category**: Could we auto-generate OpenClaw skills from OpenAPI specs? "Given a swagger, generate SKILL.md files" is a straightforward LLM task
- **Drift detection**: The swagger sync pattern is worth adopting — skills that reference external APIs should have freshness checks
- The SKILL.md convergence validates our bet on markdown-based skills as the packaging format

## Evaluation: `clawhub init --template api-ref` (2026-04-27)

Assessed whether ClawHub should adopt Venice's template-driven skill init pattern.

**Verdict: Not worth building now.** Four reasons:
1. ClawHub marketplace is empty — premature optimization
2. API-ref is the wrong first template; our skills are behavioral, not informational
3. Swagger-sync is orthogonal to `init` — better as standalone CI action
4. LLM-generated skills reduce template value (agents don't need scaffolding)

**Worth remembering**: swagger-sync drift detection pattern for future API-consuming skills.

**Trigger to revisit**: when ClawHub reaches 10+ published skills, consider `clawhub init` with a `behavioral` template first.

## Related
- [[skill-ecosystem]] — broader .skill format explosion
- [[vercel-skills]] — cross-agent skill manager
- [[skill-type-taxonomy]] — behavioral vs informational skills
- [[clawhub-evolution-skills]] — ClawHub's approach
