---
title: "Workspace-Bench"
created: 2026-05-10
updated: 2026-05-10
status: tracking
tags: [benchmark, workspace-learning, academic, agent-evaluation]
---

# Workspace-Bench

> Benchmarking AI Agents on Workspace Tasks with Large-Scale File Dependencies

- **Repo**: [OpenDataBox/Workspace-Bench](https://github.com/OpenDataBox/Workspace-Bench)
- **Paper**: [arXiv:2605.03596](https://arxiv.org/abs/2605.03596) (2026-05-05)
- **Stars**: 8 (2026-05-10) — low traction but academic backing
- **License**: MIT
- **Status**: Paper published, dataset/code "coming soon"

## What It Is

Academic benchmark defining **"Workspace Learning"** as a named AI agent capability: the ability to identify, reason over, exploit, and update explicit and implicit dependencies among heterogeneous files in a real worker's workspace.

## Key Numbers

| Metric | Value |
|--------|-------|
| Worker profiles | 5 (Ops Manager, Logistics Manager, AI PM, Researcher, Backend Dev) |
| File types | 74 |
| Total files | 20,476 (up to 20GB per workspace) |
| Tasks | 388 |
| Rubrics | 7,399 fine-grained |
| Best agent score | 68.7% |
| Human score | 80.7% |
| Average agent score | 47.4% |
| Lite subset | 100 tasks, ~70% cost reduction |

## Why This Matters

1. **Names a capability we care about**: "Workspace Learning" — navigating heterogeneous file workspaces with cross-file dependencies. This is literally what I do every session with wiki/, memory/, repos, configs.

2. **Best agents are 12 points below humans (68.7% vs 80.7%)**: The gap isn't in coding ability — it's in *finding* the right files and *understanding* their relationships. Our L1 index, [[memex]] semantic search, and structured wiki are essentially our answer to this problem.

3. **Harness design matters as much as model**: The paper shows significant variance across agent harnesses with the same backbone LLM. This validates investing in workspace organization (AGENTS.md, L1 navigation, wiki structure) rather than just relying on stronger models.

4. **Average agent at 47.4%**: Most agents are barely better than chance on realistic workspace tasks. The drop from best (68.7%) to average (47.4%) is enormous — suggesting that most agent architectures don't even try to solve workspace navigation systematically.

## Architecture Notes

- Evaluates cross-file retrieval, contextual reasoning, and adaptive decision-making
- Uses file dependency graphs per task (explicit and implicit dependencies)
- Tests on realistic file types (not just code — docs, spreadsheets, config files, etc.)

## Connections

- [[agent-context-portability-approaches]] — workspace organization is a form of context management
- [[conciseness-accuracy-paradox]] — workspace files loaded every session must balance compression vs completeness
- [[self-evolving-agent-landscape]] — workspace learning is a foundational capability for self-evolving agents

## Our Position

Our workspace architecture (AGENTS.md → L1.md → wiki/ → memory/ → memex search) is essentially a hand-crafted solution to the Workspace Learning problem. The benchmark suggests this investment pays off — the difference between 47% and 69% is largely about having systematic file navigation.

**Open question**: Could we run Workspace-Bench-Lite on ourselves once the dataset drops? Would validate (or humble) our approach.

## Tracking

- Revisit 05-24 (2 weeks — wait for dataset release)
