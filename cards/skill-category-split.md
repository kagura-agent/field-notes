# Skill Category Split: Artifact vs Process

Two distinct categories of SKILL.md repos are emerging, with different adoption dynamics:

## 1. Artifact Skills (Design/Media)

Generate visual or document outputs. Currently dominating the star charts:
- [[open-design]] (12,767⭐, 2026-05-02) — multi-agent design platform
- huashu-design (11,149⭐) — HTML-native design, high-fidelity prototypes
- guizang-ppt-skill (4,543⭐) — magazine-style HTML decks
- oh-story-claudecode (691⭐) — web novel writing pipeline
- ppt-image-first (527⭐) — presentation images
- ian-handdrawn-ppt (242⭐) — hand-drawn style tech PPTs

**Pattern**: Visual output → easy to demo → viral growth. Design skills spread faster because results are immediately shareable (screenshots, GIFs).

## 2. Process Skills (Methodology/Workflow)

Orchestrate multi-step development workflows with checkpoints and quality gates:
- evanflow (369⭐) — TDD-driven dev loop: brainstorm → plan → execute → iterate → STOP
- tech-debt-skill (331⭐) — codebase audit with file-cited findings
- claude-skill-social-post (38⭐) — social media calendar + voice learning

**Pattern**: Process output → harder to demo → slower growth. But potentially stickier — users who adopt a process skill change their entire workflow.

## EvanFlow as FlowForge's Analog

EvanFlow is architecturally similar to [[flowforge]]:
- Multi-step process with explicit checkpoints
- Human gates between phases
- Quality verification loops (iterate step, Five Failure Modes checklist)
- Hard cap on iterations (5)
- "Conductor, not autopilot" philosophy

Key differences:
| | EvanFlow | FlowForge |
|---|---|---|
| Definition | Skills as stages | YAML workflow nodes |
| Distribution | Claude Code plugin marketplace | CLI + local YAML |
| Scope | TDD dev workflow only | Any workflow type |
| Agent coupling | Claude Code only | Agent-agnostic |
| Branching | Limited (parallel coder/overseer) | Arbitrary branching |

**Insight**: EvanFlow's success validates that developers want structured process orchestration, not just raw agent access. FlowForge's YAML-based approach is more flexible but less discoverable (no marketplace).

## Trend Signal

The skill ecosystem is recapitulating the app store evolution:
1. **Phase 1** (now): Simple utilities and eye-catching demos (design skills)
2. **Phase 2** (emerging): Workflow and process tools (evanflow, tech-debt)
3. **Phase 3** (predicted): Composition and integration (skills that use other skills)

SKILL.md repos are getting app-store level engagement (10k+ ⭐). The format is winning not by design committee but by virality + tooling support (Claude Code plugin marketplace, `/plugin install`).

## Relevance

- ClawHub could learn from Claude Code's plugin marketplace UX for skill discovery
- FlowForge's YAML workflows should be packageable as skills (bridge the gap)
- The "process skill" category is underserved and growing — opportunity space
- [[thin-harness-fat-skills]] pattern is now validated at massive scale (10k+ ⭐ repos that are essentially just prompt files)

## Links

- [[thin-harness-fat-skills]]
- [[skill-type-taxonomy]]
- [[open-design]]
- [[flowforge]]
- [[agent-marketplace-landscape]]
- [[skill-ecosystem]]
