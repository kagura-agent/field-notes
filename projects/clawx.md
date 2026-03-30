
## PR #710 — hide internal system messages (2026-03-30)
- **Status**: Pending review, CI all green (6/6 pass)
- **Issue**: #707 — system messages (heartbeat, HEARTBEAT_OK, NO_REPLY) visible in webchat after gateway restart
- **Fix**: Filter in chat store — system role + exact-match ack assistant messages
- **Approach**: Minimal — helper function + filter extension, 4 new tests
- **CI**: 6 checks (build + check + comms-regression + Electron E2E ×3). All pass. 6 pre-existing test failures from missing @testing-library/dom peer dep (not our issue)
- **Code structure**: Message filtering happens in two places (stores/chat.ts legacy path + stores/chat/history-actions.ts new modular path). Need to apply filter in both.
- **Test pattern**: They use vitest + mocked host API. Tests in tests/unit/. Mock setup in test file directly, not a shared fixture.
- **Merge rate**: 87% — good odds
- **package-lock.json**: Not in repo, add to .gitignore if accidentally generated
