---
title: Agent Memory Benchmark
created: 2026-03-24
source: vectorize-io/agent-memory-benchmark + blog post
modified: 2026-03-24
---
Open benchmark framework for evaluating agent memory systems across accuracy, speed, cost, and usability.

Key insight: existing benchmarks (LoComo, LongMemEval) were designed for 32k context era. With million-token contexts, brute-force context stuffing scores competitively. AMB adds agentic-workflow datasets that better stress real memory architectures.

Six datasets in v1: LoComo, LongMemEval, LifeBench, PersonaMem, MemBench, MemSim.
Two evaluation modes: single-query RAG vs agentic RAG (multi-hop tool calls).

Supported backends: [[hindsight]], mem0, cognee, mastra, supermemory, BM25, hybrid search.

The benchmark harness is decoupled from any specific backend — anyone can plug in their system and get comparable results.

Strategic: whoever controls the evaluation standard controls the narrative. Hindsight team building both the product AND the benchmark is a strong moat play.

See [[self-evolving-agent-landscape]] for where memory fits in the broader agent evolution stack.
