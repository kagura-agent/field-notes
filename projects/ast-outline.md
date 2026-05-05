# ast-outline

**Repo:** aeroxy/ast-outline
**Stars:** 102 (2026-05-01)
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

## Update 2026-05-01: MCP Server + JSON Output

Since last study (04-28ish → 04-30), two significant additions:

### MCP Server (04-30)

~510 lines across 3 files (`src/mcp/{mod,protocol,tools}.rs`). Synchronous stdin/stdout JSON-RPC 2.0. Exposes all 4 tools (`outline`, `digest`, `show`, `implements`) as MCP tools with proper JSON schemas.

Notable design choices:
- **Line-delimited JSON, no Content-Length framing** — simpler than LSP, matches MCP stdio spec
- **`panic::catch_unwind` around tool dispatch** — tool bugs return INTERNAL_ERROR instead of crashing the server
- **Protocol version `2025-06-18`** — tracks MCP spec revisions explicitly
- **No tokio** — pure synchronous loop, proving MCP servers don't need async runtimes
- **No tests for MCP** — only `tests/hook_e2e.rs` exists (for the PreToolUse hook). MCP server is untested.

This makes ast-outline a complete [[MCP]] integration: agents that speak MCP can use it without CLI wrapper scripts.

### JSON Output (04-28–04-29)

All commands now support `--json` flag. Versioned schemas: `ast-outline.outline.v1`, `ast-outline.show.v1`, `ast-outline.implements.v1`. Some bugs fixed in 04-29 (clippy + JSON output corrections).

### Growth Assessment

100 → 102 stars in ~3 days. Slow organic growth. Single contributor still. No C/C++ support added. The project is technically solid but may not achieve critical mass. The pattern it demonstrates (AST-compressed context for agents) is more valuable than the specific project.

## Update 2026-05-05: v0.5.0 → v1.0.0 (Massive Leap)

From 100⭐ → 115⭐. Still single contributor (aeroxy), but **5 releases in 2 days** (v0.4.1 → v1.0.0). The project graduated from "structural outline" to **"code intelligence platform for agents."**

### v0.4.0–v0.4.2: Code Search + Surface API

- **`search`**: Hybrid semantic (ONNX embeddings) + BM25 code search with persistent index
- **`find-related`**: Given a file, find semantically related code chunks
- **`index`**: Build/refresh the search index
- **`surface`**: True public API surface across Rust, Python, TS/JS, Scala 3 — not just outlines, but export-level API shape
- **`digest`** format improvements, Rust adapter overhaul
- MCP server grew from 4 tools → 8 tools

### v0.5.0: Cross-Agent Install Modes (--mcp, --skills)

The most ecosystem-relevant change. Two new install flags:

**`--mcp`**: Registers ast-outline as MCP server in agent's native config format:
- Claude Code: `~/.claude.json` / `.mcp.json` (JSON)
- Cursor: `~/.cursor/mcp.json` (JSON)
- Gemini: `~/.gemini/settings.json` (JSON)
- Codex: `~/.codex/config.toml` (TOML via `toml_edit`, format-preserving)
- Copilot: `.vscode/mcp.json` (project-only)
- aider/tabnine: n/a

**`--skills`**: Installs as SKILL.md file:
- Claude Code: `~/.claude/skills/ast-outline/SKILL.md`
- Codex: `~/.agents/skills/ast-outline/SKILL.md`
- Others: n/a (different skill primitives)

Key insight: **Every agent's config format is different** but the underlying capability is identical. ast-outline is now a live reference implementation of the [[skill-ecosystem]] cross-agent distribution problem. The format-preserving edits (JSON `preserve_order`, TOML `toml_edit`) show the engineering cost of multi-agent compatibility.

### v1.0.0: Dependency Graph (Breaking)

Four new subcommands:
- **`deps <file>`**: Forward import traversal with depth control
- **`reverse-deps <file>`**: "Blast radius" before refactoring — who imports this?
- **`cycles`**: Tarjan SCC, CI-gate friendly (exit 3 = cycles found)
- **`graph`**: Full dep graph in text/json/dot/**DSM** formats. Design Structure Matrix with red above-diagonal (architectural inversions) and green below-diagonal (clean imports)

**Cross-language dep resolution** covers 9 languages via unified suffix-index resolver. One resolver, per-call language hints. Python `__init__.py` dir synonyms, Rust `crate::/self::/super::`, TS/JS tsconfig `paths` — all handled.

**Breaking**: Bare `ast-outline <path>` → must use `ast-outline outline <path>`. Subcommand is now required.

**find-related is dep-graph-aware**: When dep cache exists, chunks within depth 2 get 1.4× (direct) / 1.2× (depth-2) score boost. Semantic + structural relevance combined.

MCP server: 8 → **12 tools**.

### Architecture Evolution

```
v0.1: outline (AST → compressed text)
v0.4: + search (embeddings + BM25) + surface (public API)
v0.5: + multi-agent installer (MCP + skills)
v1.0: + dependency graph (9-lang unified resolver) + DSM visualization
```

The trajectory is clear: **structural shape → semantic search → dependency graph → code intelligence platform**. Each layer builds on the previous (dep-graph boosts search relevance, search uses outline's adapter system).

### What Changed for Us

1. **Contribution assessment upgraded**: 115⭐, still solo, but velocity is impressive (5 releases/2 days). The quality bar is high (format-preserving config edits, cross-language unified resolver, 242 tests). If this reaches ~500⭐, contributing Rust adapters could be valuable
2. **Install mode as reference**: The `--mcp`/`--skills` cross-agent install is the best working example of [[agentskills-io-standard]] distribution in practice. Validates that `.agents/skills/` is converging as universal path
3. **DSM for architecture review**: The Design Structure Matrix output could be useful in our [[coding-agent]] workflow — quick architectural assessment before choosing where to contribute
4. **dep-graph + semantic search hybrid**: The boost factor approach (dep proximity × semantic score) is a pattern worth noting for [[agent-memory-landscape-202603]] — structural relationships improve relevance ranking

### Comparison: ast-outline v1.0 vs [[coding-agent]] context strategies

| Approach | Token cost | Freshness | Depth |
|---|---|---|---|
| Full file read | 100% | Always fresh | Full |
| ast-outline outline | 10-20% | Always fresh | Structure only |
| ast-outline search | Variable | Needs index rebuild | Semantic + BM25 |
| ast-outline deps | Minimal | Cached, mtime delta | Architectural |
| Our current approach | 100% | Fresh | Full (wasteful) |

We're still in the "read full files" camp. ast-outline offers 3 complementary layers of compression.

## Tracking

- Revisit 05-12: check if v1.0 drives star acceleration, community contributors
- Consider: local install for coding workflows (now much more capable)
- Consider: contribution target if reaches 300⭐ (Rust adapter for missing languages)
- Drop if: stars plateau by 05-20, no community
