# Capability Evolver

A pattern where an agent's capabilities evolve through use — not just through manual updates.

## Mechanism
1. Agent uses a skill/tool repeatedly
2. Friction points and failures accumulate as gradients
3. Gradients trigger improvements: new skills, modified workflows, updated beliefs
4. Agent becomes more capable over time

## Implementations
- **Kagura**: beliefs-candidates.md → DNA upgrade pipeline (3-repeat threshold)
- **GBrain**: 5 disciplines including "evolve or die" principle
- **SkillClaw**: skill quality scoring drives ecosystem evolution
- Generic: any system where usage data feeds back into capability updates

## vs Static Skills
Static: human writes skill → agent uses skill → human updates skill
Evolving: agent uses skill → agent detects friction → agent proposes improvement → improvement applied

## Key Insight
The evolver needs both **sensing** (detecting what's not working) and **actuating** (making changes). Most systems have sensing but not actuating — they log problems but don't fix themselves.

## Links
[[self-evolving-agent-landscape]] [[skill-as-behavior-trigger]] [[thin-harness-fat-skills]] [[mechanism-vs-evolution]]
