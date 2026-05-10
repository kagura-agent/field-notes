---
title: "OpenSandbox (Alibaba)"
created: 2026-05-10
updated: 2026-05-10
tags: [agent-infrastructure, sandbox, alibaba, cncf]
---

# OpenSandbox

**Repo**: alibaba/OpenSandbox | **Stars**: 10.5k | **License**: Apache-2.0 | **Lang**: Python
**Created**: 2025-12-17 | **CNCF Landscape**: Listed

General-purpose sandbox platform for AI agents. Multi-language SDKs (Python, JS/TS, Java/Kotlin, Go, C#/.NET) with unified sandbox APIs.

## Architecture

- **Sandbox Protocol** — Lifecycle management + execution APIs (OpenAPI specs in `specs/`)
  - `sandbox-lifecycle.yml` — create/destroy/status
  - `execd-api.yaml` — command execution inside sandbox
  - `egress-api.yaml` — network egress control
  - `diagnostic-api.yml` — health/debugging
- **Runtime**: Docker (local) or Kubernetes (production/scale)
- **Strong Isolation**: gVisor, Kata Containers, Firecracker microVM support
- **Network Policy**: Ingress gateway (multiple routing strategies) + per-sandbox egress controls
- **Built-in Environments**: Command, Filesystem, Code Interpreter, Browser (Chrome/Playwright), Desktop (VNC/VS Code)
- **Components**: `execd` (exec daemon), `ingress`, `egress`, `internal`

## Why This Matters

1. **Enterprise-grade sandbox infra from Alibaba** — not a weekend project. 842 forks, 67 open issues, active releases (v0.1.13 server, May 2026)
2. **Protocol-first approach** — the Sandbox Protocol is an attempt to standardize how agents interact with sandboxes. This is the infrastructure layer that MCP is for tools.
3. **CNCF Landscape listing** — signals institutional adoption. Cloud-native ecosystem recognition.
4. **Multi-SDK** — same API surface in 5+ languages. Agents in any language can use it.
5. **Production Kubernetes runtime** — designed for scale, not just demo.

## Comparison to OpenClaw's Approach

- OpenClaw uses exec/process tools with host-level isolation (no sandbox by default)
- OpenSandbox provides dedicated sandboxed environments per agent session
- Different layers: OpenClaw = agent runtime, OpenSandbox = execution sandbox
- Could be complementary — OpenClaw agents using OpenSandbox for code execution

## Observations

- Has `skills/` directory but only contains `troubleshoot-sandbox` — minimal skill adoption
- Has `AGENTS.md` + `CLAUDE.md` — using AI-assisted development (common pattern now)
- `oseps/` — OpenSandbox Enhancement Proposals (governance maturity signal)
- Code interpreter sandbox suggests targeting coding agent use cases primarily

## Architecture Deep Read

### Sandbox Protocol (specs/)
- **Lifecycle API** — Pending → Running → Pausing → Paused → Resuming → Running → Stopping → Terminated. Any state → Failed. Clean FSM.
- **Execd API** — Code execution (Python/JS/etc) with stateful contexts, shell commands (fg/bg), file CRUD, SSE streaming, system metrics. Port 44772.
- **Egress API** — Per-sandbox network egress policy.
- API key auth via header (`OPEN-SANDBOX-API-KEY`) or env var.

### Key Design Decisions
- **Snapshot-based restore** — Can create/restore from snapshots (fast cold start for pre-configured envs)
- **Protocol-first, not SaaS-first** — Explicitly rejected e2b API compatibility (#800). Maintainer wrote 8-point rationale: "OpenSandbox 的目标不只是提供一个 hosted sandbox SDK，而是提供可自托管、可扩展的 sandbox 平台。" Strategic choice.
- **Multi-language SDK reality** — Kotlin value class causes Java interop issues (#849). Multi-SDK is harder than it sounds.

### Issues Reveal Architecture Weaknesses
1. **SECURITY: Sandbox escape via host path mounts** — Default config allows arbitrary host path mounts. Critical.
2. **SECURITY: Symlink escape** — Symlink within whitelisted path points to host root `/`. Classic container escape.
3. **GPU support silently drops** — `resourceLimits.gpu` ignored in both Docker and K8s runtimes.
4. **Helm chart bugs** — imagePullSecrets not wired, chart version mismatch, flag errors on startup.
5. **Pre-warmed pods leak** — Never deleted (resource leak in K8s runtime).

→ Production maturity: **early**. Protocol is clean, runtime has real security gaps.

### e2b vs OpenSandbox Positioning
- e2b = SaaS product API (hosted sandbox)
- OpenSandbox = self-hosted platform with open protocol
- Different markets: e2b for quick integration, OpenSandbox for enterprise/on-prem
- No compatibility layer planned — deliberate strategic divergence

## Links

- [[self-evolving-agent-landscape]]
- [[agent-skill-ecosystem]]
