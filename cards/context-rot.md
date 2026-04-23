# Context Rot

When an LLM agent's context window fills past ~60% of capacity, coherence degrades — the model pays attention to the beginning (instructions) and end (recent turns) but loses the middle. Industry term: "lost in the middle."

## The Death Spiral

1. Context fills up → quality drops
2. Agent compacts/summarizes → loses working context
3. User re-explains → burns more tokens
4. Context fills up faster → repeat

[[auto-memory]] measured 68 min/day lost to this cycle.

## Quantified Budget (200K window)

- ~120K effective (60% threshold)
- -65K for MCP tools
- -10K for instruction files
- = **~45K actual working context**

## Mitigation Strategies

- **Progressive recall** ([[auto-memory]]): read prior session DB, inject only relevant fragments
- **Semantic memory** ([[memex]]): offload to external searchable store, retrieve on demand
- **Keyword memory** ([[mercury-agent]]): simple `.includes()` search over JSONL facts
- **File-based memory** (OpenClaw): MEMORY.md + daily logs, manually curated

## Implication for Long-Running Agents

24/7 agents (OpenClaw, Mercury) face this constantly. The key insight: **memory is not optional for agents that run longer than one session.** The question is what to externalize and when.

Related: [[agent-lifecycle-fsm]], [[mercury-agent]], [[auto-memory]]
