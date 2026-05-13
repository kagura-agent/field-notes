---
title: Tactile — Accessibility-First Agent Operating Layer
slug: tactile
tags: [computer-use, accessibility, agent-infrastructure, macos, windows, skill]
status: tracking
created: 2026-05-13
updated: 2026-05-13
last_verified: 2026-05-13
---

# Tactile

**Repo:** [yliust/Tactile](https://github.com/yliust/Tactile) · ⭐191 (05-13, 2 days old) · Python + Swift · No standard license (NOASSERTION)
**Author:** Yong Liu (yliust)

## What It Is

An accessibility-first operating layer for agents. Instead of screenshot→guess→click, Tactile inverts the stack: **read OS accessibility semantics first** (roles, names, states, hierarchy), use OCR as text fallback, and resort to visual/coordinate clicking only as last resort.

Core thesis: **"Agent-ready software should also be human-accessible software."**

## Architecture

```
Observation priority: AX (Accessibility) > OCR > Visual Planner > Raw Coordinates
```

Three-layer stack:
1. **Swift tools** (macOS): `AppOpenerTool`, `TraversalTool`, `InputControllerTool` — compiled Swift binaries that interact with macOS Accessibility API
2. **Python orchestration**: `codex_llm_workflow.py` (3208 lines) — LLM-driven observe-plan-act loop
3. **SKILL.md surface**: Packaged as an agent skill (compatible with Codex, Claude Code, any SKILL.md-aware harness)

Platform support:
- **macOS**: Swift + macOS Accessibility API (`AXUIElement`)
- **Windows**: Python + Windows UI Automation (UIA)

### Key Design Patterns

- **App profiling**: `profile_target()` introspects `.app` bundles — plist, URL schemes, resource hints, tech stack detection (Electron, native, etc.)
- **Action routing**: Multiple actuator strategies with fallback chain:
  ```
  code-aware: public_interface > dom_command > fast_path > workflow > ax > ocr > visual
  baseline: workflow > ax > ocr > visual
  ax: ax > ocr > visual
  visual: visual only
  ```
- **App guides**: Per-app reference docs (`references/app-guides/`) with specific automation knowledge (Feishu, WeChat, CapCut, Zoom, etc.)
- **Fast paths**: Feishu/Lark gets dedicated commands (`feishu-send-message`, `feishu-open-section`) that skip multi-step LLM planning
- **Eval suites**: YAML-defined test suites for measuring automation reliability across apps

### Safety Model

- High-risk actions (send, pay, delete, account changes) split into: locate → draft → verify → submit
- Re-observe after every action that changes UI state
- Coordinate safety: never infer from screenshots (Retina 2x), always from fresh observations
- Clipboard safety: force UTF-8 for non-ASCII text

## Why This Matters

1. **Inverts computer-use paradigm**: Most computer-use agents (Anthropic, browser-use, etc.) start from screenshots. Tactile starts from the structured data that's already there. This is fundamentally more reliable — accessibility trees are deterministic, screenshots are not.

2. **Accessibility alignment**: By building on accessibility APIs, Tactile creates a virtuous cycle — apps that work well for agents also work well for screen readers. This could drive accessibility adoption as a side effect.

3. **Chinese app ecosystem focus**: Demo videos and fast paths target Feishu/Lark, WeChat, CapCut, TencentMeeting — the Chinese domestic app stack. This is an underserved niche in Western-focused computer-use research.

4. **Skill-based packaging**: Distributed as SKILL.md, pluggable into any agent harness. Not a standalone product.

## Limitations

- **macOS/Windows only** — no Linux support (Linux accessibility APIs are fragmented: AT-SPI on GNOME, different on KDE)
- **Requires Accessibility permissions** — user must grant access in System Preferences
- **AX quality varies wildly** — Electron apps (Feishu/Lark) expose rich AX trees; many native apps don't. The "ax-poor" mode exists for this reason.
- **No license** — NOASSERTION. Risk for adoption.
- **Very new** — 2 days old, 2 issues (both from author), no community yet

## Comparison

| Approach | Start Point | Reliability | Speed | Works On |
|----------|-------------|-------------|-------|----------|
| **Tactile** | AX semantics | High (when AX is good) | Fast (no vision) | macOS, Windows |
| **Anthropic Computer Use** | Screenshots | Medium | Slow (vision model) | Any OS |
| **browser-use/chromex** | DOM | High (in browsers) | Fast | Browsers only |
| **OpenChronicle** | AX for capture | N/A (passive) | N/A | macOS |

## Relevance to Us

- **Architecture pattern**: The "observation priority stack" (AX > OCR > visual) is a good design principle for any agent that operates software. Could inspire our browser skill to prefer DOM queries over screenshots.
- **Skill packaging**: Uses SKILL.md format, proving the pattern works for complex multi-tool skills.
- **Not directly usable**: We run on Linux servers; Tactile is desktop-only. But the thesis is worth watching.

## Links

- [[openchronicle]] — also uses macOS Accessibility APIs, but for passive context capture
- [[chromex]] — browser automation, DOM-first approach (similar philosophy for web)
- [[computer-use]] — screenshot-first paradigm that Tactile inverts
