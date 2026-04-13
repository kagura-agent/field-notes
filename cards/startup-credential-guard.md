# Startup Credential Guard

> Reject known-weak placeholder secrets at gateway startup, before they cause confusing runtime auth failures.

## Pattern

1. **Extract validation** into a standalone function (not inline in load) → testable
2. **Curate a placeholder set**: `_PLACEHOLDER_SECRET_VALUES` = `{*, **, ***, changeme, your_api_key, placeholder, example, dummy, null, none}`
3. **Soft reject**: don't crash — disable the platform + log clear error message
4. **Exposure-aware strictness**: loopback with placeholder = fine; 0.0.0.0 with placeholder = refuse
5. **Graceful fallback**: if auth module not importable → skip check (don't crash on optional dependency)

## Key Design Decisions

- **min_length parameter**: different contexts need different minimums (platform token: 4, API server key: 8)
- **Whitespace handling**: strip before checking (catches `  ***  `)
- **Empty token ≠ placeholder**: empty tokens have their own warning path, not placeholder rejection
- **Log truncation**: show first 6 chars + "..." to aid debugging without leaking full token

## Implementations

- **OpenClaw**: #64586 (original, TypeScript)
- **hermes-agent**: #8706 (port, Python) — `has_usable_secret()` in `hermes_cli/auth.py`, `_validate_gateway_config()` in `gateway/config.py`

## Cross-Project Pattern

hermes directly ported OpenClaw's approach with explicit credit. This is a security hardening pattern converging across agent frameworks — both projects now reject the same set of weak credentials at startup.

## Relevance

- [[agent-security]] second mainline: startup validation is defense-in-depth's first layer
- Our OpenClaw deployment could benefit from the same pattern for custom config validation
- The "soft reject" (disable + log, don't crash) is the right UX for a multi-platform gateway
