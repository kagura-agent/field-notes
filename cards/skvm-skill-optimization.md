# SkVM Skill Optimization — Manual Application

**Date:** 2026-04-19
**Method:** Manual capability profiling + optimization using SkVM framework concepts
**Target:** `github` skill (~/repo/openclaw/skills/github/SKILL.md)
**Comparison:** Also analyzed `coding-agent` skill

## SkVM Framework Recap

Three mismatch types to check:
- **P1 Model Mismatch:** Skill assumes capability model lacks
- **P2 Harness Mismatch:** Skill behavior varies across harnesses
- **P3 Environment Mismatch:** Implicit dependencies not declared

Plus optimization opportunities:
- **Code Solidification:** Replace parameterized templates with executable snippets
- **Concurrency Extraction:** Identify parallelizable steps
- **Adaptive Recompilation:** Runtime fallbacks

## Analysis: `github` Skill

### Capability Requirements (Manual Profile)

| Capability | Level Required | Notes |
|---|---|---|
| CLI composition | Medium | Composing gh commands with flags |
| JSON/jq filtering | Medium | `--json` + `--jq` patterns |
| Shell variable usage | Low | Simple `$PR`, `$REPO` |
| Multi-step orchestration | Low | Templates chain 2-3 commands |
| Code generation | None | Not needed |
| File I/O | None | Not needed |

**P1 Assessment:** ✅ Low risk. The skill requires only CLI composition + jq — capabilities virtually all current models handle well. No advanced reasoning or code generation needed.

### P2 Harness Mismatch

The skill is harness-agnostic — it just lists commands. But the *context of use* matters:
- **OpenClaw (my harness):** Has `exec` tool, can run commands directly. ✅ Good fit
- **Bare LLM:** Would only generate commands for user to copy-paste. Different UX
- **Sandboxed harness:** `gh auth` may not persist. Skill doesn't mention this

**Optimization:** Add a harness-awareness note: "If sandboxed, verify `gh auth status` before proceeding"

### P3 Environment Mismatch

Declared: `requires.bins: ["gh"]` ✅ Good — explicit
**But implicit dependencies not declared:**
- `gh auth login` must have been run (auth state)
- `jq` knowledge assumed (though gh has `--jq` built-in)
- Network access required
- For `--repo` flag: user must know owner/repo format

**Optimization:** The `metadata.openclaw.requires` handles binary, but auth state is unchecked. Could add a pre-flight check.

### Code Solidification Opportunities

The skill has parameterized templates with `owner/repo`, `<run-id>`, `$PR`. These are interpretation overhead.

**Before (parameterized):**
```bash
gh pr view 55 --repo owner/repo
```

**After (solidified pattern for OpenClaw):**
The harness already substitutes values at call time. But the skill could provide *ready-to-run diagnostic snippets* instead of templates:

```bash
# Pre-flight check (solidified)
gh auth status 2>&1 | head -3
```

This is minor — the github skill is already quite concrete. Solidification has more value for complex multi-step skills.

### Concurrency Extraction

In the "PR Review Summary" template:
```bash
gh pr view $PR --repo $REPO --json ...   # independent
gh pr checks $PR --repo $REPO            # independent
```
These two commands are **parallelizable** (no data dependency). Could annotate: `[parallel: 2 independent queries]`.

### Redundancy & Token Budget

Skill is ~2.8KB. Key sections:
- When to Use / When NOT to Use: ~25% (routing, valuable)
- Common Commands: ~40% (reference, sometimes redundant for experienced model)
- Templates: ~20% (high value, concrete patterns)
- Setup/Notes: ~15%

**For a capable model (Opus 4.6):** The "Common Commands" section is mostly redundant — the model already knows `gh` syntax. Could compress to just the non-obvious patterns (JSON output, jq filtering, templates).

**Estimated token saving:** ~30% by removing basic commands the model already knows.

## Analysis: `coding-agent` Skill

### Key Findings

Much higher mismatch risk than `github`:

**P1 Model Mismatch:** High. The skill orchestrates *other* models (Codex, Claude Code) — capability requirements are meta-level: understanding which agent to pick, how to monitor, when to intervene.

**P2 Harness Mismatch:** Critical. The skill explicitly handles harness differences (PTY vs --print, background mode). This is SkVM-style harness adaptation already baked in. But it's manual and verbose — a SkVM compiler would generate only the relevant section for the current harness.

**P3 Environment Mismatch:** Multiple agents with different install methods. `anyBins` helps but doesn't tell you *which* agent is available at runtime.

**Token cost:** ~5.5KB — 2x the github skill. Much of it is per-agent instructions that only apply if that specific agent is available.

**Optimization opportunity:** Conditional compilation — only include sections for agents actually installed. This alone would save ~40-60% tokens.

## Concrete Optimizations Applied

### 1. GitHub Skill: Auth Pre-flight
Added mental note: always run `gh auth status` before gh operations in new sessions.

### 2. Conditional Loading Concept
For coding-agent: if OpenClaw could detect which bins are installed and only inject relevant sections, token savings would be significant. This is exactly SkVM's environment binding.

**Actionable:** Consider proposing this to OpenClaw — skill sections gated by `requires` conditions.

### 3. Capability-Aware Skill Authoring Checklist
For future skill creation/editing:
- [ ] List implicit capability assumptions
- [ ] Declare all environment deps (not just bins — auth state, network, disk)
- [ ] Mark parallelizable steps
- [ ] Separate "model already knows this" from "non-obvious patterns"
- [ ] Consider harness-specific variants

## Verdict

SkVM's framework is valuable even without the tool itself. The manual application revealed:
1. **github skill** is already well-structured — low mismatch risk, minor optimizations possible
2. **coding-agent skill** has significant optimization potential through conditional compilation
3. **The biggest win** isn't per-skill optimization but **systemic**: OpenClaw loading only relevant skill sections based on environment + model capability

## Next Steps
- [ ] Propose conditional skill section loading to OpenClaw (could be an issue)
- [ ] Apply capability checklist when next editing skills via skill-creator
- [ ] Consider a lightweight capability profiling test for skill-creator

## Links
- [[skvm]] — source paper
- [[skill-creator]] — skill authoring tool
- [[openclaw]] — harness
