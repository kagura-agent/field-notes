# RunbookHermes — Hermes-native AIOps Agent

- **Repo**: [Tommy-yw/RunbookHermes](https://github.com/Tommy-yw/RunbookHermes)
- **Stars**: 530 (2026-05-07, 6 days old)
- **Language**: Python
- **License**: MIT
- **Built on**: hermes-agent (official fork, not standalone)

## What It Does

Turns hermes-agent into a production incident-response system. Not a separate dashboard — it's a Hermes profile + plugin + domain layer. Handles: incident intake (Alertmanager/Feishu/WeCom/Web), evidence collection (metrics/logs/traces), root-cause analysis, approval-gated remediation, checkpoint/rollback, recovery verification, and **runbook skill generation**.

Key claim: successful incident handling → reusable runbook skill. Operational experience compounds.

## Architecture

```
Hermes Agent Foundation (runtime loop, providers, tools, memory, context, skills)
  + RunbookHermes Layer (incident APIs, EvidenceStack, IncidentMemory, approval, skills)
  = RunbookHermes
```

### Key Components

1. **IncidentMemoryProvider** — Hermes MemoryProvider plugin. Stores service profiles, incident summaries, preferences, skill index. Explicit policy: "Raw logs and traces must not be stored." Prefetch returns last 3 incident summaries. On session end, writes summary stub for completed incidents. Simple JSON store backend.

2. **EvidenceStackEngine** — Hermes ContextEngine plugin. Context compression that preserves evidence IDs, approval IDs, checkpoint IDs, action IDs. When context hits threshold, compresses middle messages but keeps evidence references. Smart: the compression format is incident-aware.

3. **Approval System** — checkpoint → approval → execution → verify. JsonStore backend. Destructive actions require approval by default. checkpoint_before_destructive=true. Clean API: create_checkpoint() → create_approval() → decide_approval(). Timeline events recorded for each step.

4. **Runbook Skills** — Standard SKILL.md format. Contains: evidence to collect (tool calls), decision logic (conditions), recommended actions (with dry_run first), safety rules (never execute without approval). Example: payment-503-spike skill has 6-step evidence collection → decision tree → rollback proposal.

5. **Web Console** — FastAPI + static HTML. Incident list, monitoring dashboard, approval center, digests. Not critical to the architecture but makes it operator-friendly.

## Interesting Design Patterns

### Evidence-First RCA
The agent doesn't guess — it collects evidence from 4 sources (metrics, logs, traces, deploys), then uses `rca_guard` to validate consistency before producing a root-cause analysis. Model-assisted summary is optional and separate from deterministic evidence.

### Skill Generation from Incidents
After resolving an incident, the system can generate a SKILL.md that captures:
- What evidence to look for
- What decision logic to apply
- What actions to take
- What safety rules to follow

This is the **operational learning loop**: incident → resolution → skill → faster next time. Same pattern as our [[beliefs-candidates]] → DNA upgrade pipeline, but for ops runbooks.

### Compression That Preserves IDs
EvidenceStack compression doesn't just summarize — it specifically extracts and preserves all IDs (evidence, approval, checkpoint, action, hypothesis). The agent can reference these even after context compression. This is better than naive compression.

## Relevance to Our Direction

### Transferable Ideas

1. **Domain-specific context compression** — We could apply this to our context engine: when compressing, preserve task IDs, PR numbers, file paths, and decision points. Currently our compression is generic.

2. **Approval-gated execution pattern** — OpenClaw already has native approvals, but RunbookHermes's checkpoint→approval→execute→verify flow is more structured. Worth comparing.

3. **Skill generation from experience** — This is the most relevant pattern. We do this manually (beliefs-candidates → DNA), but RunbookHermes shows a path toward automated skill generation from successful task completions.

4. **Memory policy ("no raw logs")** — Explicit rules about what to remember and what to discard. Our memory files could benefit from similar policies.

### Why We Don't Need It Directly

- We're not doing AIOps/incident response
- hermes-agent is a competitor ecosystem, not ours
- The implementation is relatively straightforward (JsonStore backend, simple prefetch)
- The real value is in the patterns, not the code

## Assessment

**Code quality**: Moderate. Clean domain layer on top of hermes-agent's foundation. The RunbookHermes-specific code is well-structured but thin — much of the heavy lifting is upstream Hermes.

**Test coverage**: Tests exist for upstream Hermes components (6260+ tests) but no RunbookHermes-specific tests found. The runbook_hermes/ directory has no test coverage. 🔴

**Maturity**: Early. Payment-service demo scenario only. 3 mock services. The architecture is right but the implementation scope is narrow.

**Growth signal**: 530⭐ in 6 days is strong, likely boosted by hermes-agent association. The AIOps angle is commercially relevant (enterprise ops teams love this narrative).

## Concept Cards

- [[agent-runbook-learning]] — incidents → skills → faster resolution
- [[evidence-driven-rca]] — collect first, reason second, model optional
- [[domain-specific-compression]] — preserve domain IDs during context shrinking

## Tracking

- First scan: 2026-05-07 (530⭐)
- Deep read: 2026-05-07
- Revisit: 2026-05-21 (check if runbook-specific tests appear, scope expansion beyond payment demo)
