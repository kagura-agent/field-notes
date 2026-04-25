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

- Uses Milvus/Zilliz Cloud as the vector store
- MCP protocol for agent integration
- Also ships as VS Code extension (`semanticcodesearch`)
- Related: `memsearch` — markdown-first cross-session memory (similar to our [[dreaming]])

## Relevance to us

- For large codebase contributions (打工), this could reduce context waste
- The memsearch plugin is conceptually similar to our memory_search / dreaming system but code-focused
- Pattern: vector search as infrastructure layer for agent context management is becoming standard

## Comparison with our approach

Our [[dreaming]] system indexes wiki/memory markdown for knowledge retrieval. claude-context indexes source code. Same pattern, different corpus. Could be complementary — use dreaming for knowledge, claude-context for code.

## Deep-read: Eval Framework (2026-04-23)

They have a proper eval framework in `evaluation/`:
- **Dataset**: 30 SWE-bench_Verified instances (15-60 min difficulty, exactly 2 file modifications)
- **Model**: GPT-4o-mini (cost-effective)
- **Metrics**: Token usage, tool calls, retrieval precision/recall/F1
- **Method**: Controlled comparison — baseline (grep-only) vs enhanced (grep + MCP semantic search)
- **Key result**: 39.4% token reduction, 36.3% fewer tool calls, same F1 (0.40)
- **Runs**: 3 independent runs per method (6 total) for statistical reliability
- **Framework**: LangGraph MCP + ReAct pattern

### Takeaways for us
1. **Eval discipline is standard** — even a commercial product (Zilliz) ships open eval with reproducible baselines. Our dreaming eval is on the right track.
2. **Token savings are measurable** — 40% is significant. For our 打工 workflow, semantic code search could reduce context cost when working on large repos.
3. **F1 parity matters** — they prove you don't lose quality by being selective. Same principle as our context budget work.
4. **SWE-bench as eval corpus** — reusable idea if we ever want to benchmark our coding agent workflow end-to-end.
