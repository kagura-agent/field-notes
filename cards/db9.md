---
title: "DB9 — Brain Adapter Architecture"
created: 2026-05-10
tags: [project, memory, architecture]
---

# DB9

A brain adapter concept from the wanman.ai ecosystem — a pluggable interface layer between agent memory and storage backends.

## Key Ideas
- Abstracts memory storage behind a unified interface
- Supports multiple backends (file, SQLite, vector DB)
- Enables memory operations (store, retrieve, forget, consolidate) independent of storage engine
- Part of the broader "agent brain" pattern where memory is a first-class subsystem

## Relevance
- Studied as part of [[brain-git-memory]] and wanman skill evolution research
- The adapter pattern is useful for agents that need to switch between local file memory and hosted memory services
- Contrasts with our approach of plain markdown files as memory (simpler but less structured)

See also: [[brain-git-memory]], [[self-evolving-agent-landscape]]
