# ast-outline

**Repo:** aeroxy/ast-outline
**Stars:** 100 (2026-05-01)
**Language:** Rust (tree-sitter via ast-grep, rayon for parallelism)
**Created:** 2026-04-25
**License:** MIT

## What it does

Fast AST-based structural outline tool for source files. Extracts classes, methods, signatures with line numbers — but no method bodies. Purpose-built for LLM coding agents to reduce token usage 5-10× when exploring codebases.

## Core Commands

| Command | Purpose |
|---|---|
| `ast-outline <path>` | Structural outline with line ranges |
| `ast-outline digest <dir>` | Compact public API map of a module |
| `ast-outline show <file> <Symbol>` | Extract specific method body |
| `ast-outline implements <Type> <dir>` | Find all implementors (BFS, transitive) |
| `ast-outline mcp` | Expose as MCP server (stdio JSON-RPC) |

Supports: Rust, C#, Python, TypeScript/JS, Java, Kotlin, Scala, Go, Markdown.

## Architecture

```
File routing (main.rs, ignore crate for .gitignore) 
  → Language adapter (src/adapters/*.rs, ast-grep tree-sitter bindings)
  → Declaration IR (src/core.rs — universal struct: kind, name, signature, visibility, lines, children)
  → Rendering (outline/digest/show/implements, text or JSON)
```

Key design:
1. **Language adapters as the only moving part** — adding a language = one new file implementing `LanguageAdapter` trait. The IR and rendering are language-agnostic.
2. **Zero infrastructure** — no index, no cache, no embeddings, no server. Parse on demand, always fresh.
3. **JSON output with versioned schemas** — `ast-outline.outline.v1`, `ast-outline.show.v1`, `ast-outline.implements.v1`. Schema field enables stable downstream tooling.

## The Hook System — Most Interesting Part

The killer feature isn't the CLI — it's the **agent Read interceptor**:

```
Agent issues Read(file.rs) → agent's PreToolUse hook → ast-outline hook
  → if supported extension AND file > min_lines (default 200)
    → substitute outline instead of full file content
  → else pass through
```

For Claude Code, this hooks into `.claude/settings.json` PreToolUse hooks. The hook reads stdin JSON (`{tool_name, tool_input: {file_path, offset, limit}}`), decides whether to substitute, and emits either `{continue: true}` (pass through) or `{decision: "block", reason: "<outline content>"}`.

**Smart passthrough rules:**
- Non-Read tools → pass through
- Files with offset/limit already specified → pass through (user wants specific region)
- Unsupported extensions → pass through
- Files below threshold → pass through

This is **transparent to the agent** — it thinks it read the full file but got a compressed version. The substitution note tells it how to get full content if needed.

## Multi-Agent Installer

`ast-outline install --all` detects 7+ coding agents and writes appropriate config:
- **Claude Code**: CLAUDE.md prompt + PreToolUse hook in settings.json
- **Gemini**: Similar hook integration
- **Cursor, Aider, Codex, Copilot, Tabnine**: Prompt injection only (no hook support)

Uses marker blocks (`<!-- ast-outline -->`) for idempotent install/uninstall.

## What's Interesting for Us

### Token economics as a first-class concern
Most agent tools treat token usage as incidental. ast-outline makes it the **primary design goal**. The 5-10× reduction on file reads is significant when an agent exploration loop touches dozens of files. This is the same problem we face in [[coding-agent]] workflows — reading unfamiliar repos burns through context windows fast.

### Read interception pattern
The PreToolUse hook pattern is elegant: intercept agent's file reads at the tool level, substitute compressed representations, and the agent never knows. This is a general pattern — you could intercept any tool call and provide optimized responses. Relevant to [[skill-ecosystem]] thinking about "infrastructure skills" that make other skills more efficient.

### MCP as the universal interface
Exposing the same functionality via CLI, JSON output, AND MCP server covers all integration paths. The MCP server is ~600 lines, fully synchronous, no tokio. Shows that MCP servers don't need to be complex.

### Comparison with code-outline (Python predecessor)
Inspired by dim-s/code-outline but rewritten in Rust with ast-grep. The Rust version adds: rayon parallelism, MCP server, agent hook system, `implements` command, JSON output. Shows the pattern of "take a Python prototype, rebuild in Rust for production use."

## Limitations

- **No C/C++ support** — significant gap for systems-level codebases
- **100 stars, single contributor** — early project risk
- **Only intercepts Read** — could theoretically also optimize Search/Grep results
- **Rust-only binary** — harder to extend for users who don't know Rust (vs Python predecessor)

## Relation to Our Direction

**Complementary to [[coding-agent]] workflow.** When our agents explore repos for contribution, they waste tokens reading full files to understand structure. ast-outline would directly reduce our token costs and speed up the discovery phase.

**Hook pattern is applicable beyond file reads.** The PreToolUse interception model could inform how we think about "optimization layers" in the [[skill-ecosystem]] — skills that make other skills more efficient without changing them.

**Not a contribution target** — well-written Rust, but small project, single contributor. Worth using, not worth contributing to yet.

## Tracking

- Revisit 05-08: check star growth, contributor activity, C/C++ support
- Consider: install locally for our own coding-agent workflows
- Drop if: stars plateau, no new contributors
