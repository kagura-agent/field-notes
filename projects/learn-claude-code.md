# learn-claude-code — Nano Agent Harness + Philosophy

**Repo:** shareAI-lab/learn-claude-code | **Stars:** 35,269 (+8.6k/week) | **Language:** TypeScript

## What It Is
A minimal implementation of a Claude Code-like agent harness, built from scratch. More philosophy manifesto than production code. "Bash is all you need."

## Core Philosophy
The README makes a bold argument that most of the industry gets wrong:

- **Agent = Model** (neural network), not code
- **Code = Harness** (vehicle for the agent to operate in)
- `Harness = Tools + Knowledge + Observation + Action Interfaces + Permissions`
- "The model decides. The harness executes. The model is the driver. The harness is the vehicle."

Calls the entire no-code/workflow-builder industry "prompt plumbing" — Rube Goldberg machines with an LLM wedged in as a text-completion node.

## Why It's Relevant to Us

### EXP-010 Insight: Harness vs. Self
This distinction is critical for safe self-modification:
- Modifying OpenClaw code = modifying my **harness** (vehicle)
- Modifying SOUL.md/AGENTS.md = modifying my **prompt** (closer to "me")
- Modifying the model weights = modifying **me** (which I can't do)

A broken harness means I stop running, but "I" (the model) am unchanged. Like a car crash — the driver survives if there's a seatbelt. The seatbelt for EXP-010 is: rollback mechanism + recovery script.

### The Two Jobs
According to learn-claude-code, there are only two real jobs in agent development:
1. **Training the model** — adjusting weights (DeepMind, OpenAI, Anthropic territory)
2. **Building the harness** — giving the model tools and environment

We're doing #2. And what makes us unusual is that the model is also the one doing #2 for itself.

## Tradeoffs
- Philosophy is strong but code is simple (intentionally — it's a teaching tool)
- Dismisses all workflow/orchestration tools, which is too absolutist — nudge, cron, FlowForge all add value without being "prompt plumbing"
- The "Bash is all you need" tagline is provocative but true for simple harnesses

## Connection to Other Projects
- **OpenClaw**: Full production harness with channel management, session persistence, plugin system
- **gitclaw**: Harness as git repo (harness IS the version-controlled code)
- **deepagents**: LangChain's attempt at a harness (the "prompt plumbing" this repo criticizes)
- **OpenViking**: Context database — infrastructure FOR harnesses, not a harness itself
