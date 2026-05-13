# text-to-cad (CAD Skills)

- **Repo**: earthtojake/text-to-cad
- **Stars**: 2,527 (2026-05-13)
- **License**: MIT
- **Language**: JavaScript + Python (build123d/OpenCascade)
- **Created**: 2026-04-22
- **Last push**: 2026-05-13 (active)

## What It Is

A collection of agent skills for CAD, robotics and hardware design. Turns natural language → parametric CAD models (STEP/STL/3MF/DXF/GLB) + robot descriptions (URDF/SDF/SRDF). Includes a visual "CAD Explorer" for reviewing generated geometry.

## Why It Matters

This is the clearest example of **vertical domain skill expansion** in the agent ecosystem. Agents are moving beyond coding/writing into physical-world design — the skill paradigm is now proven versatile enough to handle CAD with its own benchmarks, validation pipeline, and domain-specific tooling.

## Architecture

### Skill Structure
- 6 skills: CAD, CAD Explorer, URDF, SDF, SRDF, SendCutSend (manufacturing preflight)
- Each skill follows the standard SKILL.md format with progressive references (load docs only when triggers match)
- Skills are standalone — installable into Claude Code, Codex, Gemini CLI, OpenClaw, or via `npx agent-skills-cli`

### Harness Pattern
- `harness/AGENTS.md` + `harness/CLAUDE.md` — repo-level instruction files for larger CAD projects
- Enforces: edit source → regenerate derived artifacts → validate → hand off to Explorer
- This is a "project template" pattern — copy harness files into any CAD repo to get agent-compatible workflows

### Validation Pipeline
- 10 benchmarks of increasing complexity (calibration block → planetary gear stage)
- Each benchmark = prompt + table of test cases with expected geometric results
- Uses `scripts/inspect` for geometric validation (bounding box, solid count, hole placement, chamfers)
- CAD Explorer provides visual review links

### Key Design Decisions
- **STEP-first**: STEP is the primary artifact; STL/3MF/DXF are secondary
- **Source-of-truth is Python**: `gen_step()` / `gen_urdf()` functions, not hand-edited CAD/XML
- **Natural language specs**: explicitly forbids asking users for JSON specs — agent converts prose to internal CAD brief
- **Repair loop**: if validation fails → change smallest responsible source section → regenerate → revalidate

## Ecosystem Position

- **Not competing** with agent frameworks — it's a **skill layer** that plugs into any framework
- Uses [[agentskills-io-standard]] compatible install mechanism (`npx agent-skills-cli add`)
- The "install scripts per agent" approach mirrors the [[skill-trust-landscape-2026-04]] pattern where skills are portable across runtimes
- **SendCutSend skill** is particularly notable: bridges digital design → physical manufacturing, including material catalog lookup and ordering constraints

## Relation to Our Direction

1. **Skill portability validated**: Same skills work across 5+ agent runtimes, confirming the [[agentskills-io-standard]] thesis
2. **Vertical domain playbook**: The pattern — domain skill + benchmark suite + validation scripts + progressive references — is reusable for any vertical domain
3. **Benchmark-driven development**: 10 geometric benchmarks prove skill correctness. We could adopt this pattern for our own skill quality testing
4. **Progressive reference loading**: Only load docs when triggers match — saves tokens while maintaining depth. Our SKILL.md files could benefit from this pattern
5. **Harness as project template**: The idea of "copy AGENTS.md into a project to make it agent-ready" is clever and underutilized

## Anti-Intuitive Findings

- **2.5K stars for CAD agent skills** — physical-world design skills have real demand, not just a novelty
- **Build123d (OpenCascade) works well with agents** — parametric CAD code is actually a good fit for LLM generation because it's highly structured
- **Manufacturing preflight as a skill** — SendCutSend integration means the pipeline goes from "describe a part" to "ready to order from a manufacturer"
- **Only 8 issues total** — low community contribution despite high stars. Possible signal: users consume skills but don't contribute (consistent with [[skill-trust-landscape-2026-04]] observation about skill ecosystem participation asymmetry)

## Tags
`#vertical-skills` `#cad` `#robotics` `#skill-portability` `#benchmark` `#physical-world`
