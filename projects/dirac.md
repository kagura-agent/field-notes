# Dirac

**What:** Open-source coding agent focused on token efficiency and context curation. Fork of [[cline]] with radical re-engineering of the edit and read pipeline.

**Repo:** `dirac-run/dirac` | ⭐665 (2026-04-28) | Apache 2.0 | TypeScript
**Created:** 2026-04-05 | Active daily pushes
**Author:** Max Trivedi (Dirac Delta Labs)

## Why It Matters

Core thesis: **model reasoning degrades with context length**, so aggressively curating context improves both accuracy AND cost. This is well-studied but rarely operationalized this thoroughly in a coding agent.

Result: 8/8 accuracy on their eval suite at **64.8% lower cost** ($0.18 avg vs $0.49 for Cline). Topped TerminalBench-2 leaderboard with Gemini-3-flash-preview at 65.2% (vs Google's own 47.6% baseline).

## Key Innovations

### 1. Hash-Anchored Edits

Instead of line numbers (which shift after edits), each line gets a **stable word-pair anchor** (e.g., `AppleBanana│def process(data):`). Anchors are:
- Generated from a dictionary of common words, combined into unique pairs
- Managed by `AnchorStateManager` — tracks per-file, per-task anchor state
- Uses FNV-1a hashing to detect line content changes
- Survives insertions/deletions elsewhere in the file

This solves the "lost in translation" problem where line-number-based edits break when the file has changed since last read. Similar concept to [[content-addressable-editing]] but simpler — words are more LLM-friendly than hex hashes.

### 2. AST-Native Tools

Surgical tools that reduce context size:
- `get_file_skeleton` — extracts class/function definitions, strips implementation
- `get_function` — extracts specific function bodies by dotted path (e.g., `Foo.calculateSum`)
- `find_symbol_references` — IDE-like "find all references"
- `rename_symbol` — structural rename across files
- `replace_symbol` — structural find-and-replace

These let the model read structure first, then drill into specific functions, instead of loading entire files. Less context = better reasoning = lower cost.

### 3. Multi-File Batching

`edit_file` accepts an array of file objects, each with multiple edits. All non-overlapping edits in a single LLM roundtrip. Reduces latency AND API calls.

### 4. Context Curation Pipeline

- `FileContextTracker` — watches files with chokidar, detects user edits outside agent, marks context as stale
- `ContextManager` — compacts context window when approaching limits, uses token-based threshold
- `ModelContextTracker` — tracks what the model has "seen" to avoid redundant reads

### 5. No MCP

Deliberately rejects MCP in favor of native tool calling only. Claim: maximum reliability and performance. Tradeoff: less extensible, but tighter control.

## Architecture Notes

- Fork of Cline — inherits VS Code extension + CLI structure
- `AnchorStateManager` is stateful per-task, per-file — uses `Map<taskId, Map<filePath, TrackedDocument>>`
- Dictionary-based anchor words (`.hash_anchors` file) — two random words concatenated for uniqueness
- Supports subagents (`new_task`, `subagent.ts`) with configurable timeout and max_turns
- Has its own skill system (`list_skills`, `use_skill`) — reads from `.ai`, `.claude`, `.agents` directories + `AGENTS.md`

## Relation to Our Stack

| Aspect | Dirac | OpenClaw/Our approach |
|--------|-------|----------------------|
| Edit model | Hash-anchored, stable | Traditional line-based |
| Context strategy | Aggressive curation | Full context, rely on model |
| Tool design | AST-native surgical reads | File-level reads |
| Extensibility | No MCP, native only | MCP + native |
| Target | Coding only | General agent |

**Borrowable ideas:**
1. **File skeleton tool** — `get_file_skeleton` is a great pattern for any coding agent. Read structure first, drill into specifics. Could benefit our coding subagent prompts.
2. **Batch edits** — multiple files in one tool call reduces roundtrips. Our edit patterns could benefit.
3. **Stale context detection** — `FileContextTracker` watching for external edits prevents silent failures.

**Not borrowable:**
- Hash-anchored edits require deep integration into the edit pipeline. Heavy lift, unclear payoff for non-coding agents.
- No-MCP stance conflicts with our ecosystem approach.

## Open Questions

- How do anchors handle very large files (>50k lines)? `MAX_TRACKED_LINES = 50000` suggests a hard limit.
- Performance impact of FNV-1a hashing on every line read?
- Dictionary collision rate with only two-word combinations?

## Connections

- [[conciseness-accuracy-paradox]] — Dirac's thesis directly validates: less context → better reasoning
- [[reasonix]] — Also focuses on cost reduction but via caching, not context curation. Different strategies, same goal.
- [[agentic-stack]] — Portable agent config (.agent/) concept overlaps with Dirac's AGENTS.md support
- [[model-native-vs-model-agnostic]] — Dirac is model-agnostic (supports many providers) but tool-native (no MCP)

---

*Deep read: 2026-04-28. Source: GitHub repo + README + key source files.*
