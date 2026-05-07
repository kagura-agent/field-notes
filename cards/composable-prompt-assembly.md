# Composable Prompt Assembly

A pattern where agent prompts are dynamically composed from detected context rather than using monolithic static prompts.

## Core Idea

Instead of one-size-fits-all system prompts, detect the input context (tech stack, file types, domain) and assemble prompt components that are relevant to the current batch of work.

## Components

1. **Context Detection** — analyze inputs to identify relevant domains (lockfiles → framework tags, file extensions → languages)
2. **Component Library** — modular prompt fragments, each tagged with applicability conditions
3. **Filter/Gate** — only include components matching the current context
4. **Budget Cap** — hard limit on composed prompt size; graceful fallback when exceeded
5. **Batch Scoping** — within the same project, different batches get different prompts based on their content

## Key Design Decisions

- **Per-batch, not per-project**: a Python batch in a polyglot repo shouldn't carry JavaScript-specific guidance
- **Graceful degradation**: when too many components apply, collapse to a compact summary rather than overwhelming the model
- **Deterministic verification**: committed prompt sample fixtures + snapshot tests ensure composition produces expected output
- **Approximate token counting** (chars/4): precise tokenization isn't worth the dependency for budget enforcement

## Origin

Observed in [[deepsec]] PR #53 (05-06): composable prompt for security scanning across 64 frameworks. Tech detection → per-batch highlights → slug notes → project context, all with hard char budgets.

## Applicability

- Any agent processing heterogeneous codebases or inputs
- [[FlowForge]] task prompts could benefit from project-context-aware composition
- [[wiki-lint]] could compose checking rules based on detected content types
- PR review agents could scope guidance to the languages/frameworks in the diff

## Related

- [[mechanism-vs-evolution]] — composable prompts are a mechanism; whether agents evolve their own prompt components is the next question
- [[deepsec]] — primary example
