# byob — Bring Your Own Browser

**Repo:** https://github.com/wxtsky/byob (⭐87, created 2026-04-25)
**Language:** TypeScript (Bun)
**License:** MIT

## What It Does
MCP server that lets AI coding agents (Claude Code, Cursor, Cline, etc.) control your **real Chrome** — the one where you're already logged into everything. Solves the "headless browser can't see my sessions" problem.

## Architecture
Three-part system connected via Chrome Native Messaging:

```
Chrome Extension (MV3)  →  Native Messaging Bridge  →  MCP Server (stdio)
   (content script)           (packages/bridge)        (packages/mcp-server)
```

- **Extension**: Injects into Chrome, handles DOM operations, cookie access, screenshots
- **Bridge**: Native messaging host — translates between Chrome extension protocol and the MCP server
- **MCP Server**: Exposes 30+ tools as MCP resources (navigate, click, screenshot, extract, cookies, PDF, network recording, etc.)

## Why This Matters
| Approach | Sees logged-in pages | Passes bot detection | Setup time |
|---|---|---|---|
| web_fetch | ❌ | ❌ | 0 |
| Headless Puppeteer | ⚠️ manual cookie copy | ❌ | hours |
| **byob** | ✅ already logged in | ✅ real browser | ~5 min |

The key insight: instead of fighting bot detection and auth, just use the browser the human already has open.

## Relevance to Us
- OpenClaw has a browser skill (Playwright-based), but it runs headless — no access to user sessions
- byob's approach could complement ours: use byob for auth-required pages, Playwright for automation
- The Chrome extension → Native Messaging → MCP pipeline is a clean pattern for bridging browser state to agent tools
- 30+ granular tools (not just "screenshot + click") — includes network interception, cookie management, table extraction, device emulation

## Interesting Design Choices
- **MCP-first**: Designed as an MCP server, not a standalone tool. Works with any MCP-compatible agent
- **No headless browser dependency**: Zero Puppeteer/Playwright — all operations go through the real Chrome
- **Security tradeoff**: Giving agents access to your real browser cookies and sessions is powerful but risky. byob seems to rely on MCP's permission model to gate access

## Open Questions
- How does it handle concurrent agent requests? (Single Chrome instance = shared state)
- Cookie extraction tool (`browser-get-cookies`) — security implications for agent memory?
- Does the extension survive Chrome updates? (MV3 lifecycle)

Links: [[browser-automation]], [[mcp-protocol]]
