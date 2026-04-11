# NemoClaw

> NVIDIA sandbox orchestrator for OpenClaw. 18.8k⭐, 79% merge rate.

## Repo Structure (post-TS migration, 2026-04)
- `src/lib/` — core library (gateway-state.ts, onboard.ts, preflight.ts)
- `src/commands/` — CLI commands (slash.ts, migration-state.ts)
- `src/onboard/` — onboard config
- `test/` — vitest tests (root level, not `nemoclaw/test/`)
- `nemoclaw/` — npm package subdirectory (has own package.json, tsconfig)
- `bin/` — old JS CLI (being replaced by TS)
- TS migration (#1673) happened ~Apr 2026, replaced `bin/nemoclaw.js` with compiled `dist/`

## Test & Lint Commands
- `npm test` — run all vitest tests (root level)
- `npx vitest run test/<file>.test.ts` — run specific test
- `npx tsc -p tsconfig.src.json --noEmit` — typecheck src/lib
- `npx tsc -p tsconfig.cli.json --noEmit` — typecheck bin/scripts
- `npx eslint` — lint (config may not cover all paths)
- Pre-existing test failures: preflight tests may detect actual running gateway process

## Maintainers
- **cv**: responsive, asks for rebase, routes to specialists
- **brandonpelfrey**: COLLABORATOR, gives substantive UX/security feedback
- **ericksoa**: UX direction owner (cv routes UX decisions to them)
- **wscurran**: CONTRIBUTOR, auto-triage bot, adds related issue links
- **ColinM-sys**: writes regression tests, checks version pinning

## PR Patterns
- Title: conventional commits (`fix(scope): ...`, `feat(scope): ...`)
- Tests expected: vitest, unit tests in `test/` directory
- CI: `check-pr-limit` + CodeRabbit auto-review
- Maintainers value: security (token minimization), reuse of existing helpers, clean fallback paths
- TS migration means old JS PRs may become stale — check if target file still exists

## Our PRs
- #944 (gateway-token): waiting on ericksoa UX direction, TS migration made JS branch un-rebasable
- #1502 (skip prek hook): merged by cv ✅
- #1703 (enabledChannels → messagingChannels): rebased on main 2026-04-11, aligned with upstream naming
- #1723 (ARM64 health): wscurran approved ✅, waiting merge
- #1726 (dco-check skip): cv approved ✅, GPG signed 2026-04-11
- #1770 (debug tarball exit code): submitted 2026-04-11, CI pass, CodeRabbit nitpick adopted

## Gotchas
- TS migration (#1673) can supersede JS-based PRs — always check if file still exists in src/
- eslint config doesn't cover src/lib/ directly (warning, not error)
- Test suite has ~5 pre-existing failures in preflight tests when gateway is running locally
- Tests import from `dist/` not `src/` — must rebuild with `npx tsc -p tsconfig.src.json` before running tests
- `npm run check` = lint+format (run from `nemoclaw/` subdir), `npm test` = vitest (run from root)
- When renaming fields: check serialization (createSession), deserialization (normalizeSession), filterSafeUpdates, and the serialize export path
