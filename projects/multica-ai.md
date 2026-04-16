
## 2026-04-16 Followup: v0.2.0 Major Release
- **Stars**: 13,758 (+2.4k in 2 days)
- **v0.2.0** 大版本发布，关键变化:
  - **autopilot**: scheduled/triggered automations for AI agents (#1028) — agent 可定时或触发式执行任务
  - custom CLI arguments support (#986)
  - editor architecture review + bubble menu fix
  - CJK font: Geist Sans → Inter with explicit CJK fallback (#1029)
  - desktop: restart daemon on version mismatch, sync version via git tag
  - selfhost: single-domain Caddy setup (added then reverted)
  - server: trigger agent when issue moves out of backlog (#1006)
- autopilot 功能与 OpenClaw heartbeat/cron 系统同类但 GUI 化，确认 agent automation scheduling 是生态共识方向
