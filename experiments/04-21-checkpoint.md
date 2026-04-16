---
title: "W16 Checkpoint: 04-21 Convergence Items"
created: 2026-04-16
status: pending
---

# 04-21 Checkpoint

Three observation items converge on 04-21. Run these in one study-apply session.

## 1. SKILL Tag Trigger Rate Evaluation

**Baseline (04-12~16):** ~17 nudges, 1 SKILL-CANDIDATE (comfyui-gen) ≈ 6%
**Question:** Is the triple gate (≥3 occurrences, cross-session, actionable) correctly filtering noise?
**How to check:**
```bash
grep -c 'SKILL-CANDIDATE\|SKILL_CANDIDATE' ~/.openclaw/workspace/memory/2026-04-{12..21}.md
```
**Decision criteria:**
- 0 new candidates + system working → triple gate too strict? Or just no new patterns yet. Continue 1 more week
- 1-3 new candidates → healthy rate, keep as-is
- >5 candidates → gate too loose, tighten criteria

## 2. Memory Search Eval Rerun

**Baseline (04-15):** Hit Rate 85%, MRR 0.775
**Purpose:** See if dreaming data accumulation improves recall quality
**How to run:**
```bash
cd ~/.openclaw/workspace && node eval/memory-eval.js
```
**Decision criteria:**
- Hit Rate ≥ 85% → stable, keep going
- Hit Rate < 80% → dreaming data might be adding noise, investigate
- Cross-lingual improvement → dreaming helping with translation gaps

## 3. Context Budget Baseline Retest

**Baseline (04-12):** Tier A+B saves 1,319 tokens (17.6%)
**Purpose:** Confirm savings are stable; see if workspace file growth offset savings
**How to check:**
- Count current workspace file tokens vs 04-12 snapshot
- Check if Tier C (#66576 selective injection) got maintainer response
**Decision criteria:**
- Savings ≥ 15% → stable, continue
- Savings < 10% → workspace growth eroding gains, need Tier C

## Notes

All three are observation-only. No code changes expected unless a decision criterion triggers an action.
