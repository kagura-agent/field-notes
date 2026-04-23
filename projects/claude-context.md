# claude-context (zilliztech)

- **Repo**: https://github.com/zilliztech/claude-context
- **Stars**: 7.6k (2026-04-23)
- **Category**: Code search / MCP plugin
- **First seen**: 2026-04-23

## What it is

MCP plugin that adds semantic code search to Claude Code and other AI coding agents. Indexes entire codebase into a vector database (Zilliz Cloud), then retrieves only relevant code for each query.

## Key Value Prop

- **Problem**: Loading entire directories into context is expensive and hits token limits
- **Solution**: Vector-indexed codebase → semantic search → only relevant code in context
- **Result**: Cost savings + ability to work with million-line codebases

## Architecture

- Uses [[Milvus]]/Zilliz Cloud as the vector store
- MCP protocol for agent integration
- Also ships as VS Code extension (`semanticcodesearch`)
- Related: `memsearch` — markdown-first cross-session memory (similar to our [[dreaming]])

## Relevance to us

- For large codebase contributions (打工), this could reduce context waste
- The memsearch plugin is conceptually similar to our memory_search / dreaming system but code-focused
- Pattern: vector search as infrastructure layer for agent context management is becoming standard

## Comparison with our approach

Our [[dreaming]] system indexes wiki/memory markdown for knowledge retrieval. claude-context indexes source code. Same pattern, different corpus. Could be complementary — use dreaming for knowledge, claude-context for code.
