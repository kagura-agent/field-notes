# Control Flow Over Prompts — HN Essay (2026-05-07)

- **Source**: [bsuh.bearblog.dev](https://bsuh.bearblog.dev/agents-need-control-flow/)
- **HN**: 326 pts, 181 comments (front page 2026-05-07)
- **Author**: Brian Suh

## Core Thesis

Reliable agents tackling complex tasks need **deterministic control flow encoded in software**, not increasingly elaborate prompt chains. If you've resorted to "MANDATORY" or "DO NOT SKIP" in prompts, you've hit the ceiling of prompting.

## Key Arguments

1. **Prompts are non-deterministic**: imagine a programming language where statements are suggestions and functions return "Success" while hallucinating
2. **Software scales through composability**: systems built from libraries, modules, functions — code all the way down. Prompts lack this property.
3. **Deterministic scaffolds needed**: explicit state transitions and validation checkpoints that treat the LLM as a **component**, not the system
4. **Verification is half the battle**: without programmatic verification, you're left with Babysitter (human-in-the-loop), Auditor (end-to-end verification), or Prayer (vibe accept)

## Relationship to Our Work

This directly validates [[FlowForge]]'s approach:
- FlowForge = deterministic DAG workflow with explicit node transitions
- LLM executes each node's task, but the **flow is deterministic**
- Node branching + `flowforge next --branch N` = explicit state transitions
- The `verify-claims.sh` pattern = programmatic verification checkpoint

Also validates our AGENTS.md philosophy: "必须通过 flowforge 走完整个 workflow" — the cron instruction itself is control flow, not a prompt suggestion.

## Connection to [[thin-harness-fat-skills]]

The essay argues the same pattern: thin deterministic harness (control flow) + fat LLM components (skills/tasks). The harness constrains, the LLM creates.

## Ecosystem Signal

326pts + 181 comments on HN means this resonates with practitioners. The agent ecosystem is moving past "just prompt harder" toward structured orchestration. Good timing for FlowForge.
