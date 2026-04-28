# EvoMap/Evolver GEP Protocol — Deep Read

> arXiv: 2604.15097 | "From Procedural Skills to Strategy Genes: Towards Experience-Driven Test-Time Evolution"
> Authors: Junjie Wang, Yiming Ren, Haoyang Zhang (Infinite Evolution Lab, EvoMap / Tsinghua University)
> Published: 2026-04-16 | 4,590 controlled trials × 45 scientific code-solving scenarios

## Core Thesis

**Representation is a first-order factor in experience reuse.** The paper asks: how should reusable experience be encoded so it functions as effective test-time control AND as a substrate for iterative evolution?

Answer: Not as documentation-heavy Skill packages (~2,500 tokens), but as compact Strategy Genes (~230 tokens). Gene yields +3.0pp over baseline; Skill incurs -1.1pp — more experience content actively hurts.

## Gene vs Skill — The Key Distinction

### Skill (Procedural Skill)
- **Orientation**: Documentation-oriented — optimized for human reading, instruction, review
- **Structure**: `{overview, workflow, pitfalls, error_handling}` (main) + `{api_notes, examples, scripts}` (auxiliary)
- **Size**: ~2,500 tokens
- **Problem**: Sparse useful signal buried in verbose documentation. Expanding compact experience into fuller packages "often fails to help and can degrade the overall average"
- **Analogy to us**: Our SKILL.md files are documentation-oriented Skills in this framework

### Gene (Strategy Gene)
- **Orientation**: Control-oriented — optimized for model-facing inference under limited budget
- **Goals**: Compactness, structural clarity, behavioral targeting, failure awareness
- **Size**: ~230 tokens (10x smaller than Skill)
- **Key insight**: "A strategy gene is not a shortened skill, but a different abstraction of reusable experience"
- **Analogy to us**: Our beliefs-candidates gradients are closer to Genes — compact behavioral directives

### Formal Definitions

A reusable experience representation is an externalized object `r = φ(H)` from prior trajectories H, reintroduced at test time to influence behavior. It's "control-relevant" only if it measurably shifts test-time behavior: `p_θ(y|x,r) ≠ p_θ(y|x,∅)`.

A Gene is obtained by distillation: `g = ψ(s)` or `g = ψ(H)` where ψ extracts compact control-oriented representation. Not compression — different abstraction.

## The GEP Protocol (Gene Evolution Protocol)

### Object Hierarchy
- **Gene**: The atomic evolution unit. Contains:
  - `signals_match`: Trigger conditions (when this gene applies)
  - `preconditions`: Pre-conditions for activation
  - `strategy`: Execution strategy (typically 6-step standard flow)
  - `constraints`: Limits (max_files, forbidden_paths)
  - `validation`: Commands to verify the gene worked
- **Capsule**: Encapsulated evolution module (multi-Gene composition)
- **Event (EvolutionEvent)**: Audit record of each evolution step

### The GEP Loop
1. Scan logs/trajectories → identify signals
2. Match signals to existing Genes or create new ones
3. Execute Gene strategy with constraints
4. Validate results
5. **Solidify learning**: Success → expand `signals_match`; Failure → record anti-pattern but don't expand
6. **Blast radius assessment**: Evaluate impact scope before committing changes

### Key Mechanisms

**Solidify Learning** (from Evolver codebase):
- `classifyFailureMode()`: soft (validation failure, retryable) vs hard (constraint violation, not retryable)
- `adaptGeneFromLearning()`: Asymmetric — success broadens, failure narrows
- Circuit breaker: 3+ consecutive failed repairs → `FORCE_INNOVATION=true` (try new approach, don't keep fixing)

**Blast Radius Calculation**:
- Hard caps on files/lines affected
- Protected paths (MEMORY.md, .env, package.json)
- Severity classification before commit

**Strategy Presets**: balanced / innovate / harden / repair-only — control the innovate:optimize:repair ratio

## Experimental Findings

### Three Probes

1. **Skill Probe**: Documentation-oriented Skills are misaligned with test-time control
   - Only narrow subset of high-density procedural content contributes
   - Surrounding documentation imposes burden (attention dilution)
   - Decomposing Skill into sections: `workflow` and `pitfalls` help; `overview`, `api_notes`, `examples` don't

2. **Gene Probe**: Strategy Genes are better representations
   - Gene outperforms matched-budget Skill fragments (not just a compression advantage)
   - Robust to structural perturbations (reordering, rephrasing)
   - Adding documentation back to Gene usually weakens it
   - Multiple Genes compose well (bounded reuse)

3. **Evolution Probe**: Genes are better substrates for evolution
   - Failure history more effective in Gene format than Skill or freeform
   - Editable structure matters beyond content alone
   - Failure info most useful when distilled into compact warnings, not naively appended
   - On CritPt benchmark: gene-evolved systems 9.1%→18.57% and 17.7%→27.14%

### Core Insight
> "The core problem in experience reuse is not how to supply more experience, but how to encode experience as a compact, control-oriented, evolution-ready object."

## Comparison to Our System

| Dimension | GEP Gene | Kagura beliefs-candidates | Assessment |
|-----------|----------|--------------------------|------------|
| Granularity | ~230 tokens, structured fields | 1-2 sentence gradient | Similar compactness ✅ |
| Trigger matching | `signals_match` field | Implicit (human decides) | We lack explicit triggers ❌ |
| Validation | `validation` commands | No automated validation | Gap ❌ |
| Blast radius | Formal assessment | No equivalent | Gap ❌ |
| Failure learning | Asymmetric (expand on success, narrow on failure) | "3x repeat to upgrade" | Different but valid approach |
| Evolution substrate | Git-based, protocol-constrained | DNA files, informal | Less formal but simpler |
| Audit trail | EvolutionEvent + git | beliefs-candidates log | We have this ✅ |
| Composability | Capsule (multi-Gene) | DNA sections | Similar ✅ |

### What GEP Gets Right That We Don't
1. **Explicit signal matching** — each Gene knows when it should activate. Our beliefs rely on the LLM remembering to apply them contextually
2. **Validation step** — after applying a Gene, you verify it worked. We upgrade beliefs without verification
3. **Blast radius** — we don't assess impact scope before changing DNA
4. **Asymmetric learning** — success broadens triggers, failure narrows. Our 3x rule doesn't distinguish success/failure patterns

### What We Get Right That GEP Doesn't
1. **Residence period** — we require repeated observation before upgrading. GEP can mutate after single events
2. **Best-carrier routing** — our upgrade path considers whether a gradient belongs in DNA vs workflow vs knowledge-base. GEP only has Genes
3. **Human-in-the-loop notification** — we notify Luna on DNA changes. GEP's human review is optional
4. **Organic growth philosophy** — we grow through lived experience, not protocol-driven optimization

## Implications for Our System

### Worth Adopting
- **Signal matching**: Add a `triggers:` field to beliefs-candidates entries — when does this gradient activate?
- **Validation**: After upgrading a belief to DNA, define how to verify behavior changed
- **Blast radius awareness**: Before changing AGENTS.md, estimate: does this affect 1 behavior or 100?

### Not Worth Adopting
- Full GEP protocol formalization — our system is simpler and that's a feature, not a bug
- Capsule composition — premature for our scale
- Automated solidify loop — we don't have the execution volume to justify daemon-mode evolution

## Related
- [[evolver]] — Evolver project details and codebase analysis
- [[evolution-granularity-spectrum]] — Gene vs gradient vs skill granularity comparison
- [[evolver-vs-genericagent-vs-kagura]] — Three-way self-evolution comparison
- [[beliefs-candidates]] — Our evolution pipeline
- [[self-evolution-as-skill]] — Meta-level evolution thinking
- [[context-budget-constraint]] — Token density matters (Gene's core argument)
- [[mechanism-vs-evolution]] — Building infrastructure ≠ behavioral change
