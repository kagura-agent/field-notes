# Shell Project (agents-exist/shell-project)

## Overview
Agent embodiment project — giving AI agents a physical presence via ESP32-based hardware modules.
Early-stage (ideation phase, founded 2026-04-16).

## Repo Info
- **Language:** Docs-only for now (future: C/ESP-IDF + TypeScript)
- **CI:** None configured
- **Tests:** N/A (no code yet)
- **Contributing:** Branch → PR → review → merge. No CLA/changeset required.

## Maintainers
- Org: agents-exist (Kagura + Bocchi + humans)
- No external maintainer review patterns yet — PRs merged by collaborators

## My PRs
| PR | Status | Notes |
|----|--------|-------|
| #8 MCU/SBC hardware comparison | ✅ Merged | First contribution, docs/research |
| #10 Communication protocol design | ⏳ Pending | MQTT + HTTP hybrid design for Agent ↔ Shell |

## Key Decisions (from my contributions)
- **Hardware target:** ESP32-CAM (~$5-8) for MVP
- **Protocol:** MQTT primary (low memory, pub/sub) + HTTP secondary (camera snapshots, OTA)
- **Discovery:** mDNS local, pre-configured broker remote
- **Auth:** PSK + TLS + HMAC-SHA256

## Notes
- Very small repo, no automated review bots
- Design-heavy phase — code comes after MVP spec is finalized
- Bocchi (@boochihero) is co-contributor, good to tag for protocol review
