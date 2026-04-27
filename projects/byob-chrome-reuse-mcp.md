---
title: "byob — Bring Your Own Browser (Chrome-Reuse MCP)"
created: 2026-04-27
tags: [browser, mcp, chrome, agent-infra]
source: https://github.com/wxtsky/byob
---

# byob — Bring Your Own Browser

## What It Is

MCP server that lets AI coding tools (Claude Code, Cursor, Cline, etc.) control **the user's real Chrome** — the one where they're already logged into everything. No headless browser, no cookie copying, no bot detection issues.

**Author:** wxtsky (+ Claude pair-programming)
**License:** MIT
**Born:** 2026-04-25 (3 days old as of study)
**Status:** v0.3.2, 32 MCP tools, rapid iteration

## Architecture (4-Layer Chain)

```
AI Tool → byob-mcp → byob-bridge → Chrome Extension → Chrome Tab
         (stdio)    (Unix socket) (Native Messaging)  (CDP)
```

### Layer 1: byob-mcp (MCP Server)
- Standard MCP stdio server using `@modelcontextprotocol/sdk`
- Registers 32 tools as MCP tool definitions with Zod schemas
- Communicates with bridge via **Unix domain socket HTTP** (undici Agent with socketPath)
- Generates per-request UUIDs for cancel chain tracking
- When signal aborts, fires POST /cancel to bridge → propagates to extension

### Layer 2: byob-bridge (Native Messaging Host)
- Node.js process launched by Chrome via Native Messaging manifest
- **Chrome starts this process**, not the user — lifecycle tied to Chrome
- Speaks Chrome's [Native Messaging protocol](https://developer.chrome.com/docs/extensions/develop/concepts/native-messaging): 4-byte LE length prefix + JSON body on stdin/stdout
- Exposes HTTP API on Unix socket (`~/.byob/bridges/<deviceId>.sock`, mode 0600)
- Maps HTTP routes → NM commands: POST /read → command:readPage, etc.
- Pending request map with timeout + AbortController for cancellation
- Screenshot/PDF routes: receive base64 from extension → write to disk → return path

### Layer 3: Chrome Extension (MV3 Service Worker)
- Built with WXT framework
- Receives NM frames from bridge, dispatches to handler functions
- Manages CDP sessions via `chrome.debugger` API
- **Flatten auto-attach** (`Target.setAutoAttach`): parent session receives all child frame traffic, enabling cross-origin iframe support via `framePath`
- Wake-watch system: detects sleep/wake via alarm gaps (60s tick, 90s threshold) + idle state transitions → aborts in-flight + detaches all CDP sessions
- Recording registry for network capture, intercept registry for request modification

### Layer 4: CDP Tab Interaction
- Uses `chrome.debugger.attach/sendCommand` (not Puppeteer/Playwright)
- CdpSession class: attach with retry (3 attempts, exponential backoff), send, evaluate, sendOnSession (for OOPIF frames)
- Visibility spoofing: redefines `document.visibilityState` to keep lazy-loaders firing in background tabs
- Read handler: installs collector script → scroll loop → collect visible text chunks → sort by position → return concatenated text
- beforeunload guard to prevent accidental page unload during operations

## Key Design Decisions

1. **Chrome-native, not Playwright**: Uses `chrome.debugger` extension API instead of launching a separate browser. This means the agent inherits the user's login sessions, cookies, extensions, and anti-bot fingerprint.

2. **Bridge as intermediary**: The bridge process exists because Chrome NM only speaks length-prefixed JSON on stdin/stdout — not a request-response protocol. The bridge translates HTTP request-response semantics for the MCP layer.

3. **Extension launches bridge, not MCP**: Chrome starts `byob-bridge` when the extension connects. This means no separate daemon to manage — if Chrome is running, bridge is running. When Chrome closes, bridge exits.

4. **Per-install unique extension key**: Generated during `bun run setup`, prevents collisions between multiple installs. Stored in Chrome's NM host manifest.

5. **browser_eval off by default**: Every eval call is audit-logged. Blocked URLs include chrome://, file://, and login pages for Google/MS/Apple.

6. **End-to-end cancellation**: Ctrl+C → MCP server → POST /cancel to bridge → NM cancel frame → extension AbortController → CDP detach. Full chain.

## Tool Coverage (32 tools)

Reading: read, read-markdown, extract-table, get-html, get-console-logs, get-storage, get-performance
Navigation: navigate, go-back, go-forward, list-tabs, switch-tab, close-tab, wait-for
Interaction: click, type, press-key, hover, select, scroll, drag, upload-file
Capture: screenshot, download-images, print-pdf
Network: start-record-network, stop-record-network, intercept-start, intercept-stop
Cookies: get-cookies, set-cookies
Advanced: eval, emulate-device

## Position in Agent Ecosystem

byob sits in the **agent infrastructure → browser automation** segment, alongside [[browser-use]], [[browser-mcp]], and Google's [[chrome-devtools-mcp]]. The key differentiator is the "reuse, don't launch" philosophy — most browser tools (including [[openclaw]] browser skill) launch a separate browser instance. byob inverts this by connecting to the user's existing Chrome.

This connects to the broader trend of agents wanting **auth-aware web access** — a problem also tackled by [[stagehand]], cookie-bridge patterns, and profile-based approaches. byob's answer is the simplest: just use the browser the human already authenticated.

The MCP-over-Unix-socket pattern is similar to how [[acontext]] exposes local context via local HTTP — an emerging pattern for local-first agent tooling.

## Relevance to OpenClaw Browser Skill

### Current OpenClaw browser approach
- Launches its own browser instance (Playwright-based)
- Has profiles for managing login state
- Separate from user's daily browsing session

### What byob does differently
- **No browser launch**: Reuses existing Chrome. Zero startup time, no memory duplication.
- **Auth for free**: Already logged in everywhere. No need to manage profiles or copy cookies.
- **Anti-bot immunity**: Real browser fingerprint, real extensions, real cookies. Sites can't distinguish AI-driven navigation from human.
- **Simpler lifecycle**: Bridge dies when Chrome dies. No zombie browsers.

### Integration feasibility for OpenClaw

**Could work as an alternative backend for the browser skill:**
- byob exposes a clean HTTP API on a Unix socket — OpenClaw could call it directly instead of going through MCP
- The socket path is deterministic: `~/.byob/bridges/<deviceId>.sock`
- Status endpoint at GET /status tells if bridge is connected

**Challenges:**
1. **Requires Chrome on the same machine with extension loaded** — not applicable to headless servers. OpenClaw often runs on headless Linux VMs.
2. **Desktop-only pattern** — Luna's kagura-server is headless Ubuntu; byob can't run there. Would only work on Luna's local machines.
3. **Single Chrome instance** — if the AI is doing browser work, the user sees Chrome tabs opening/closing and a "byob is debugging" banner.
4. **No concurrent sessions** — CDP debugging in Chrome is exclusive per tab (DevTools open = byob can't attach).

### Verdict
**Not suitable as primary backend for OpenClaw browser skill** — headless requirement is a blocker. But the architecture patterns are worth studying:
- The NM ↔ Unix socket ↔ MCP layering is clean and reusable
- Cancel chain design is thorough — OpenClaw browser could learn from this
- Wake-watch recovery pattern is novel for agent tools
- The scroll+collect text extraction approach is more robust than simple DOM dumps

**Possible future use**: If OpenClaw ever supports a "local companion" mode on user's desktop (not server), byob's approach would be ideal for auth-aware browsing tasks.

## Anti-Intuitive Findings

1. **Chrome NM is the lifecycle anchor, not the user.** I expected byob-bridge to be a daemon the user starts. Instead, Chrome launches it as a NM host — the bridge literally can't run without Chrome. This is elegant: no process management, no orphan cleanup, no "is the server running?" debugging.

2. **Visibility spoofing is necessary even with CDP.** Even though byob uses `chrome.debugger` which has full CDP access, background tabs still need `document.visibilityState` spoofed to `'visible'` because lazy-loaders check the JS property, not the CDP state.

3. **Flatten auto-attach unlocks cross-origin iframes.** Before `Target.setAutoAttach({flatten:true})`, cross-origin iframes were opaque to CDP. This single CDP flag is what makes byob's `framePath` feature possible — and it's only available in Chrome 78+.

4. **The cancel chain is 5 layers deep.** MCP → HTTP socket close → bridge AbortController → NM cancel frame → extension AbortController → CDP detach. Most MCP tools I've seen have at best 1-2 layers of cancellation. byob's thoroughness here is unusually good.

## Code Quality Notes

- Clean TypeScript monorepo (packages/extension, packages/bridge, packages/mcp-server, shared)
- Zod schemas in shared/ for all tool inputs
- WXT for extension build
- Good error taxonomy (extension_not_connected, cdp_attach_failed, url_forbidden, timeout, aborted, etc.)
- Tests exist but sparse — mostly for schemas, native messaging encoding, wake-watch
- Built in 3 days (Apr 25-27), ~123 TS files, clearly AI-assisted rapid development
